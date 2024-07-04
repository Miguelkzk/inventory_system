class Sale < ApplicationRecord
  ############################################################################################
  # ASSOCIATIONS
  ############################################################################################

  # en la tabla intermedia guardamos la cantidad vendida de cada articulo
  has_many :article_sales
  has_many :articles, through: :article_sales
  accepts_nested_attributes_for :article_sales

  ############################################################################################
  # VALIDATIONS
  ############################################################################################

  validates :sold_at, presence: true # se valida que exista la fecha de venta
  validates :article_sales, presence: true # se valida que exista algun articulo asociado

  ############################################################################################
  # SCOPES
  ############################################################################################

  scope :as_json_with_articles_details, -> { includes(article_sales: :article).as_json(methods: :articles_details) }

  ############################################################################################
  # CALLBACKS
  ############################################################################################

  ############################################################################################
  # INSTANCE METHODS
  ############################################################################################

  def articles_details
    article_sales.as_json(only: :quantity, methods: :article)
  end

  # se guarda la venta y se disminuye el stock de los articulos relacionados en una db transaction
  def save_and_decrease_articles_stock
    transaction do
      save

      # disminuir el stock de los articulos uno por uno
      # si uno falla entonces se para la ejecucion de todo
      article_sales.each do |article_sale|
        article_sale.article.stock = article_sale.article.stock - article_sale.quantity

        if article_sale.article.valid?
          article_sale.article.save
        else
          errors.add(:base,
                     :negative_article_stock,
                     article_id: article_sale.article_id,
                     quantity: article_sale.quantity,
                     stock: article_sale.article.stock)
        end
      end

      raise ActiveRecord::Rollback if errors.present?
    end

    persisted?
  end

  ############################################################################################
  # CLASS METHODS
  ############################################################################################
end
