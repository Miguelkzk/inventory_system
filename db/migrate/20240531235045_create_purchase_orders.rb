class CreatePurchaseOrders < ActiveRecord::Migration[7.1]
  def change
    create_table :purchase_orders do |t|
      t.integer :state
      t.integer :quantity
      t.belongs_to :article

      t.timestamps
    end
  end
end
