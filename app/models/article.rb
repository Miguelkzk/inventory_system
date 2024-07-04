class Article < ApplicationRecord
  include Articles::Demand

  # Enum para los tipos de modelos de inventario
  enum inventory_model: { fixed_lot: 0,       # lote fijo (revision continua)
                          fixed_interval: 1 } # intervalo fijo (revision periodica)

  # Enum para los metodos del calculo error
  enum demand_error_calculation_method: { absolute_deviation: 0,        # desviacion absoluta media
                                          quadratic: 1,                 # cuadratico
                                          absolute_percentage: 2 }      # porcentual absoluto

  # enum para guardar el tipo de periodo de los parametros generales de prediccion de la demanda
  enum demand_period_kind: { week: 0,
                             month: 1,
                             year: 2 }

  # esto es para implementar la baja logica
  # se agrega el atributo deleted_at a la tabla de articulos de la db
  acts_as_paranoid

  ############################################################################################
  # ASSOCIATIONS
  ############################################################################################

  has_many :purchase_orders

  has_many :article_sales # en la tabla intermedia guardamos la cantidad vendida
  has_many :sales, through: :article_sales

  has_many :article_providers # en la tabla intermedia guardamos algunos atributos
  has_many :providers, through: :article_providers
  accepts_nested_attributes_for :article_providers

  # si o si vamos a necesitar un default provider, para hacer los calculos de inventario sin problemas
  belongs_to :default_provider, class_name: 'Provider'

  ############################################################################################
  # VALIDATIONS
  ############################################################################################

  # Validacion para garantizar que el codigo del articulo sea unico
  validates :code, uniqueness: true, presence: true

  # Validacion para que el stock sea mayor o igual a cero
  validates :stock, numericality: { greater_than_or_equal_to: 0 }

  # para el modelo de intervalo fijo deben estar presentes:
  # - intervalo de revision (T)
  # - desviacion estandar de la demanda (sigma)
  validates :revision_interval_days_count, :annual_demand_standard_deviation, :stock_will_be_checked_at,
            presence: true,
            if: :fixed_interval?

  validates :stock,
            :annual_storage_cost,
            :inventory_model,
            presence: true

  ############################################################################################
  # SCOPES
  ############################################################################################

  ############################################################################################
  # CALLBACKS
  ############################################################################################

  after_update :generate_purchase_order!, if: :need_generate_purchase_order?
  before_destroy :check_active_purchase_order
  before_validation :set_stock_will_be_checked_at, if: -> { fixed_interval? && new_record? }

  ############################################################################################
  # INSTANCE METHODS
  ############################################################################################

  # Para que esto funcione debemos tener la demanda estimada para el proximo periodo
  def need_generate_purchase_order?
    estimated_demand.present? && fixed_lot? && stock_previously_changed? && !purchase_orders.active.exists? && stock <= reorder_point
  end

  # no se puede eliminar un articulo que tenga una orden de compra activa
  # solo se realiza una baja logica, usando la gema paranoia
  def check_active_purchase_order
    return unless purchase_orders.active.exists?

    errors.add(:base, :active_purchase_order)
    raise ActiveRecord::RecordNotDestroyed
  end

  def set_stock_will_be_checked_at
    self.stock_will_be_checked_at = Time.zone.now + revision_interval_days_count.days if revision_interval_days_count.present?
  end

  ############################################################################################
  # INVENTORY METHODS
  ############################################################################################

  # esto depende del proveedor, por lo que vamos a tener que pasarle el proveedor por parametro
  # si no le pasamos el proveedor entonces que use el proveedor por defecto
  def optimal_lot(provider_id: default_provider_id)
    case inventory_model.to_sym
    when :fixed_lot
      # periodo de la demanda estimada: mes
      # demanda estimada: 30 unidades/mes (el periodo de la demanda estimada fue cargado en los PARAMETROS GENERALES)
      # costo de pedido: $10
      # costo de almacenamiento: $50/año -> $4.16/mes
      Math.sqrt(2 * estimated_demand * order_cost(provider_id:) / storage_cost)
    when :fixed_interval
      i_max(provider_id:) - stock
    end.round
  end

  # Cantidad de stock que se debe tener para satisfacer la demanda
  # hasta el proximo pedido dado un determinado nivel de servicio
  def i_max(provider_id: default_provider_id, period: demand_period_kind)
    # (Demanda media durante T+L) + z * (desviacion estandar durante T+L)
    (estimated_demand * (revision_interval(period:) + lead_time(provider_id:, period:)) + z_value * Math.sqrt(revision_interval(period:) + lead_time(provider_id:, period:)) * demand_standard_deviation(period:)).round
  end

  # Punto de pedido (Modelo de lote fijo)
  def reorder_point(provider_id: default_provider_id, period: demand_period_kind)
    case inventory_model.to_sym
    when :fixed_lot
      estimated_demand * lead_time(provider_id:, period:) + security_stock(provider_id:)
    end.round
  end

  # provider_id: Si no le pasamos el proveedor usa el proveedor por defecto
  def security_stock(provider_id: default_provider_id, period: demand_period_kind)
    case inventory_model.to_sym
    when :fixed_lot
      z_value * demand_standard_deviation(period:) * Math.sqrt(lead_time(provider_id:, period:))
    when :fixed_interval
      z_value * demand_standard_deviation(period:) * Math.sqrt(revision_interval(period:) + lead_time(provider_id:, period:))
    end.round
  end

  # CALCULO DEL CGI: Costo de Gestion de Inventario
  # CGI = Costo compra + costo almacenamiento + costo pedido
  # - Costo de compra: precio de compra * demanda
  # - Costo de almacenamiento: costo de almacenamiento * lote optimo / demanda
  # - Costo de pedido: costo de pedido * demanda / lote optimo
  #
  # provider_id: Si no le pasamos el proveedor usa el proveedor por defecto
  def calculate_cgi(provider_id: default_provider_id)
    (cgi_purchase_cost(provider_id:) + cgi_order_cost(provider_id:) + cgi_storage_cost(provider_id:)).round(2)
  end

  def cgi_purchase_cost(provider_id: default_provider_id)
    case inventory_model.to_sym
    when :fixed_lot
      purchase_cost(provider_id:) * estimated_demand / optimal_lot(provider_id:)
    when :fixed_interval
      purchase_cost(provider_id:) / revision_interval
    end
  end

  def cgi_order_cost(provider_id: default_provider_id)
    order_cost(provider_id:) * estimated_demand / optimal_lot(provider_id:)
  end

  def cgi_storage_cost(provider_id: default_provider_id)
    case inventory_model.to_sym
    when :fixed_lot
      (optimal_lot(provider_id:) / 2 + security_stock(provider_id:)) * storage_cost.to_f
    when :fixed_interval
      ((estimated_demand * revision_interval / 2) + security_stock(provider_id:)) * storage_cost.to_f
    end
  end

  # valor de z redondeado con 3 decimales
  def z_value
    Distribution::Normal.p_value(service_level.to_f / 100).round(3)
  end

  def replenish?
    return if fixed_interval?

    stock <= reorder_point if estimated_demand.present? && purchase_orders.active.blank?
  end

  def missing?
    stock <= security_stock if estimated_demand.present?
  end

  ############################################################################################
  # PERIOD UNIT CHANGES AND PROVIDER DEPENDENT METHODS
  ############################################################################################

  # tiempo de demora del proveedor que le pasamos por parametro
  # si no le pasamos ninguno, toma el proveedor por defecto
  # el lead time se encuentra persistido en dias
  def lead_time(provider_id: default_provider_id, period: demand_period_kind)
    result = article_providers.find_by(provider_id:).lead_time.to_f

    case period.to_sym
    when :week
      result / 7
    when :month
      result / 30
    when :year
      result / 365
    end.to_f.round(2)
  end

  # se guarda el costo de almacenamiento anual, luego se convierte segun las necesidades
  def storage_cost(period: demand_period_kind)
    case period.to_sym
    when :week
      annual_storage_cost.to_f / 12 / 4
    when :month
      annual_storage_cost.to_f / 12
    when :year
      annual_storage_cost.to_f
    end.round(2)
  end

  # el intervalo de revision se persiste en dias
  def revision_interval(period: demand_period_kind)
    case period.to_sym
    when :week
      revision_interval_days_count.to_f / 7
    when :month
      revision_interval_days_count.to_f / 30
    when :year
      revision_interval_days_count.to_f / 365
    end.round(2)
  end

  # la desviacion estandar de la demanda se encuentra persistida en años
  def demand_standard_deviation(period: demand_period_kind)
    case period.to_sym
    when :week
      annual_demand_standard_deviation / 12 / 4
    when :month
      annual_demand_standard_deviation / 12
    when :year
      annual_demand_standard_deviation
    end.to_f.round(2)
  end

  # costo de compra del proveedor que le pasamos por parametro
  # si no le pasamos ninguno, toma el proveedor por defecto
  def purchase_cost(provider_id: default_provider_id)
    article_providers.find_by(provider_id:).purchase_cost.to_f
  end

  # costo de pedido del proveedor que le pasamos por parametro
  # si no le pasamos ninguno, toma el proveedor por defecto
  def order_cost(provider_id: default_provider_id)
    article_providers.find_by(provider_id:).order_cost.to_f
  end

  def default_provider_name
    default_provider.name
  end

  ############################################################################################
  # PURCHASE ORDERS METHODS
  ############################################################################################

  # Se utiliza cuando se crea una venta que reduzca el
  # stock de un articulo por debajo del Punto de Pedido
  def generate_purchase_order!(provider_id: default_provider_id)
    purchase_orders.create!(quantity: optimal_lot(provider_id:), state: :pending)
  end

  ############################################################################################
  # CLASS METHODS
  ############################################################################################

  # LISTADO DE PRODUCTOS A REPONER
  # listado de articulos que tengan stock igual o menor al punto pedido
  # que no tengan orden de compra pendiente
  def self.with_stock_lower_than_requested_point
    # TODO: implementar
  end

  # LISTADO DE PRODUCTOS FALTANTES
  # listado de articulos que tengan stock igual o menor al stock de seguridad
  def self.with_stock_lower_than_security_stock
    # TODO: implementar
  end
end
