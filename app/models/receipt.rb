class Receipt < ApplicationRecord
  belongs_to :user
  has_one_attached :image

  validates :image, presence: true
  validates :receipt_date, presence: true

  scope :linked,   -> { where.not(ynab_transaction_id: nil) }
  scope :unlinked, -> { where(ynab_transaction_id: nil) }
  scope :recent,   -> { order(receipt_date: :desc) }

  def linked?
    ynab_transaction_id.present?
  end

  def ynab_amount_dollars
    return nil unless ynab_amount
    ynab_amount / 1000.0
  end
end
