class CreateArticleProviders < ActiveRecord::Migration[7.1]
  def change
    create_table :article_providers do |t|
      t.belongs_to :article
      t.belongs_to :provider

      t.integer :lead_time # tiempo de demora del proveedor
      t.decimal :order_cost # costo de pedido
      t.decimal :purchase_cost # costo de compra
      # t.decimal :transfer_rate # tasa de transferencia i

      t.timestamps
    end
  end
end
