class PurchaseOrder < ApplicationRecord
  # Enum para el estado de Orden de compra
  enum state: { pending: 0,   # pendiente
                sent: 1,      # enviada
                finished: 2 } # finalizada

  ############################################################################################
  # ASSOCIATIONS
  ############################################################################################

  # Una orden de compra pertenece a un articulo
  belongs_to :article, -> { with_deleted }

  ############################################################################################
  # VALIDATIONS
  ############################################################################################

  validates :quantity, :state, presence: true

  ############################################################################################
  # SCOPES
  ############################################################################################

  # PurchaseOrder.active devuelve las ordenes de compra con estado pendiente o enviada
  scope :active, -> { where(state: %i[pending sent]) }

  ############################################################################################
  # CALLBACKS
  ############################################################################################

  # Si el estado de la orden de compra pasa a finalizada se incrementa el stock del articulo
  after_update :increase_article_stock, if: -> { state_previously_changed?(to: :finished) }

  # Actualiza el stock del articulo, sumandole la cantidad pedida en la orden de compra
  def increase_article_stock
    article.update!(stock: article.stock + quantity)
  end

  ############################################################################################
  # INSTANCE METHODS
  ############################################################################################

  ############################################################################################
  # CLASS METHODS
  ############################################################################################
end
