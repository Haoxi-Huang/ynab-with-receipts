class CreateReceipts < ActiveRecord::Migration[7.0]
  def change
    create_table :receipts do |t|
      t.references :user, null: false, foreign_key: true
      t.string :store_name
      t.decimal :amount
      t.date :receipt_date
      t.text :notes
      t.string :ynab_transaction_id
      t.string :ynab_account_name
      t.string :ynab_payee_name
      t.integer :ynab_amount
      t.date :ynab_date

      t.timestamps
    end
  end
end
