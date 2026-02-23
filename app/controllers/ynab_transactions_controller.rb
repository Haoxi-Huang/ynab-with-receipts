class YnabTransactionsController < ApplicationController
  def search
    ynab = YnabService.new
    since_date = params[:since_date].present? ? Date.parse(params[:since_date]) : 30.days.ago.to_date
    @transactions = ynab.search_transactions(params[:q], since_date: since_date)
    @receipt_id = params[:receipt_id]

    linked_ids = current_user.receipts.linked.pluck(:ynab_transaction_id)
    @transactions = @transactions.reject { |t| linked_ids.include?(t.id) }

    render partial: "matches/transaction_list", locals: {
      transactions: @transactions,
      receipt_id: @receipt_id
    }
  rescue YnabService::ApiError => e
    render partial: "matches/error", locals: { message: e.message }
  end
end
