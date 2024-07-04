class PurchaseOrdersController < ApplicationController
  before_action :set_purchase_order, only: %i[show update destroy]

  # Metodo para listar todas las ordenes de compra
  def index
    render json: PurchaseOrder.all
  end

  # Metodo para crear una nueva orden de compra
  def create
    purchase_order = PurchaseOrder.new(purchase_order_params)

    if purchase_order.save
      render json: purchase_order, status: :created
    else
      render json: purchase_order.errors.details, status: :unprocessable_entity
    end
  end

  # Metodo para mostrar una orden de compra especifica con su articulo
  def show
    render json: @purchase_order.as_json(methods: :article)
  end

  # Metodo para actualizar los atributos de una orden de compra
  def update
    if @purchase_order.update(purchase_order_params)
      render json: @purchase_order
    else
      render json: @purchase_order.errors.details, status: :unprocessable_entity
    end
  end

  # Metodo para eliminar una orden de compra
  def destroy
    if @purchase_order.destroy
      render json: @purchase_order
    else
      render json: @purchase_order.errors.details, status: :unprocessable_entity
    end
  end

  private

  # Metodo para permitir los parametros de entrada de una orden de compra
  def purchase_order_params
    params.require(:purchase_order).permit(:state, :quantity, :article_id)
  end

  # Metodo para buscar una orden de compra por su ID
  def set_purchase_order
    @purchase_order = PurchaseOrder.find_by(id: params[:id])
    return if @purchase_order.present?

    render status: :not_found
  end
end
