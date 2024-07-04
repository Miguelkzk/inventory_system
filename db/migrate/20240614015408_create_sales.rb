class CreateSales < ActiveRecord::Migration[7.1]
  def change
    create_table :sales do |t|
      t.datetime :sold_at # fecha de la venta

      t.timestamps
    end
  end
end
