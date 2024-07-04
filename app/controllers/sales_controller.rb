class SalesController < ApplicationController
  before_action :set_sale, only: %i[show update destroy]

  # Metodo para listar todas las ventas
  def index
    render json: Sale.as_json_with_articles_details
  end

  # Metodo para crear una nueva venta
  def create
    sale = Sale.new(sale_params)

    if sale.save_and_decrease_articles_stock
      render json: sale, status: :created
    else
      render json: sale.errors.details, status: :unprocessable_entity
    end
  end

  # Metodo para mostrar una venta especifica con sus articulos
  def show
    render json: @sale.as_json(methods: :articles_details)
  end

  # Metodo para actualizar los atributos de una venta
  def update
    if @sale.update(sale_params)
      render json: @sale
    else
      render json: @sale.errors.details, status: :unprocessable_entity
    end
  end

  # Metodo para eliminar una venta
  def destroy
    if @sale.destroy
      render json: @sale
    else
      render json: @sale.errors.details, status: :unprocessable_entity
    end
  end

  private

  # Metodo para permitir los parametros de entrada de una venta y sus articulos asociados
  def sale_params
    params.require(:sale).permit(:sold_at,
                                 article_sales_attributes: %i[article_id
                                                              quantity])
  end

  # Metodo para buscar una venta por su ID
  def set_sale
    @sale = Sale.find_by(id: params[:id])
    return if @sale.present?

    render status: :not_found
  end
end
