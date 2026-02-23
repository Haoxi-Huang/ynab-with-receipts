class MatchesController < ApplicationController
  before_action :set_receipt

  def new
    ynab = YnabService.new
    linked_ids = current_user.receipts.linked.pluck(:ynab_transaction_id)
    @suggestions = ynab.suggest_matches(@receipt, linked_transaction_ids: linked_ids)
  rescue YnabService::ApiError => e
    @error = e.message
    @suggestions = []
  end

  def create
    ynab = YnabService.new
    transaction = ynab.get_transaction(params[:transaction_id])

    @receipt.update!(
      ynab_transaction_id: transaction.id,
      ynab_payee_name: transaction.payee_name,
      ynab_account_name: transaction.account_name,
      ynab_amount: transaction.amount,
      ynab_date: transaction.date
    )

    write_memo_to_ynab(ynab, transaction)

    redirect_to @receipt, notice: "Transaction linked successfully."
  rescue YnabService::ApiError => e
    redirect_to @receipt, alert: "Failed to link: #{e.message}"
  end

  def destroy
    if @receipt.linked?
      begin
        ynab = YnabService.new
        clear_memo_from_ynab(ynab, @receipt.ynab_transaction_id)
      rescue YnabService::ApiError
        # Best-effort memo cleanup
      end

      @receipt.update!(
        ynab_transaction_id: nil,
        ynab_payee_name: nil,
        ynab_account_name: nil,
        ynab_amount: nil,
        ynab_date: nil
      )
    end

    redirect_to @receipt, notice: "Transaction unlinked."
  end

  private

  def set_receipt
    @receipt = current_user.receipts.find(params[:receipt_id])
  end

  def receipt_url_for_memo
    host = AppConfig.app_host.presence || request.base_url
    "#{host}/receipts/#{@receipt.id}"
  end

  def write_memo_to_ynab(ynab, transaction)
    url = receipt_url_for_memo
    existing_memo = transaction.memo.to_s
    return if existing_memo.include?(url)

    new_memo = existing_memo.blank? ? url : "#{existing_memo} | #{url}"
    ynab.update_transaction_memo(transaction.id, new_memo)
  rescue YnabService::ApiError
    # Best-effort memo write
  end

  def clear_memo_from_ynab(ynab, transaction_id)
    transaction = ynab.get_transaction(transaction_id)
    url = receipt_url_for_memo
    cleaned = transaction.memo.to_s.gsub(/ \| #{Regexp.escape(url)}/, "").gsub(url, "").strip
    ynab.update_transaction_memo(transaction_id, cleaned)
  end
end
