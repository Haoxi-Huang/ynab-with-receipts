class User < ApplicationRecord
  has_many :receipts, dependent: :destroy

  validates :email, presence: true, uniqueness: true
  validates :google_uid, presence: true, uniqueness: true
end
