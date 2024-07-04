class CreateArticleSales < ActiveRecord::Migration[7.1]
  def change
    create_table :article_sales do |t|
      t.belongs_to :article
      t.belongs_to :sale

      t.integer :quantity # cantidad vendida del articulo
      t.datetime :sold_at # fecha de la venta

      t.timestamps
    end
  end
end
