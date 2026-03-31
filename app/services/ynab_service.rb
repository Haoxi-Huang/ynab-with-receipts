class YnabService
  DATE_WINDOW_DAYS = 10
  MAX_FETCH_DAYS = 30

  class ApiError < StandardError; end

  def initialize
    @api = YNAB::API.new(AppConfig.ynab_access_token)
    @budget_id = AppConfig.ynab_budget_id
  end

  def fetch_transactions(since_date: MAX_FETCH_DAYS.days.ago.to_date)
    response = @api.transactions.get_transactions(@budget_id, since_date: since_date.to_s)
    response.data.transactions.reject(&:deleted)
  rescue YNAB::ApiError => e
    raise ApiError, "YNAB API error: #{e.message}"
  end

  def get_transaction(transaction_id)
    response = @api.transactions.get_transaction_by_id(@budget_id, transaction_id)
    response.data.transaction
  rescue YNAB::ApiError => e
    raise ApiError, "YNAB API error: #{e.message}"
  end

  def suggest_matches(receipt, linked_transaction_ids: [])
    transactions = fetch_transactions(
      since_date: (receipt.receipt_date - MAX_FETCH_DAYS.days).to_date
    )

    transactions
      .reject { |t| linked_transaction_ids.include?(t.id) }
      .map    { |t| { transaction: t, score: match_score(receipt, t) } }
      .sort_by { |m| -m[:score] }
  end

  def update_transaction_memo(transaction, memo)
    existing_txn = YNAB::ExistingTransaction.new(
      account_id: transaction.account_id,
      date: transaction.date,
      amount: transaction.amount,
      memo: memo
    )
    wrapper = YNAB::PutTransactionWrapper.new(transaction: existing_txn)
    @api.transactions.update_transaction(@budget_id, transaction.id, wrapper)
  rescue YNAB::ApiError => e
    raise ApiError, "YNAB API error updating memo: #{e.message}"
  end

  def search_transactions(query, since_date: MAX_FETCH_DAYS.days.ago.to_date)
    transactions = fetch_transactions(since_date: since_date)
    return transactions if query.blank?

    q = query.downcase
    transactions.select do |t|
      t.payee_name&.downcase&.include?(q) ||
        t.account_name&.downcase&.include?(q) ||
        t.memo&.downcase&.include?(q)
    end
  end

  private

  def match_score(receipt, transaction)
    score = 0.0

    if receipt.receipt_date && transaction.date
      txn_date = transaction.date.is_a?(String) ? Date.parse(transaction.date) : transaction.date
      day_diff = (receipt.receipt_date - txn_date).abs.to_f
      date_score = Math.exp(-0.3 * day_diff)
      score += date_score * 40
    end

    if receipt.amount && transaction.amount
      receipt_milliunits = (receipt.amount * -1000).to_i
      amount_diff = (receipt_milliunits - transaction.amount).abs.to_f
      receipt_abs = receipt_milliunits.abs.to_f
      if receipt_abs > 0
        amount_score = [1.0 - (amount_diff / receipt_abs), 0].max
      else
        amount_score = amount_diff == 0 ? 1.0 : 0.0
      end
      score += amount_score * 30
      score += 10 if amount_diff == 0
    end

    if receipt.store_name.present? && transaction.payee_name.present?
      score += name_similarity(receipt.store_name, transaction.payee_name) * 20
    end

    score
  end

  def name_similarity(a, b)
    a_tokens = normalize_name(a)
    b_tokens = normalize_name(b)
    return 0.0 if a_tokens.empty? || b_tokens.empty?

    matches = a_tokens.count { |t| b_tokens.any? { |bt| bt.include?(t) || t.include?(bt) } }
    matches.to_f / [a_tokens.size, b_tokens.size].max
  end

  def normalize_name(name)
    name.downcase.gsub(/[^a-z0-9\s]/, "").split.reject { |w| w.length < 2 }
  end
end
