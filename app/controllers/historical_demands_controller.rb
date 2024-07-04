class HistoricalDemandsController < ApplicationController
  # Metodo para crear una nueva demanda historica, que basicamente
  # es una venta nueva que no disminuye el stock del articulo
  def create
    historical_demand = Sale.new(historical_demand_params)

    if historical_demand.save
      render json: historical_demand, status: :created
    else
      render json: historical_demand.errors.details, status: :unprocessable_entity
    end
  end

  private

  # Metodo para permitir los parametros de entrada de una demanda historica
  def historical_demand_params
    params.require(:historical_demand).permit(:sold_at,
                                              article_sales_attributes: %i[article_id
                                                                           quantity])
  end
end
