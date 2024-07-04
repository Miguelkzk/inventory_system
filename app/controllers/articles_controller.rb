class ArticlesController < ApplicationController
  before_action :set_article, only: %i[show
                                       update
                                       destroy
                                       optimal_lot
                                       historical_demand
                                       predict_demand
                                       providers
                                       cgi
                                       active_purchase_orders]

  # Método para listar todos los artículos
  def index
    render json: Article.all.as_json(methods: %i[default_provider_name replenish? missing? article_providers])
  end

  # Método para crear un nuevo artículo
  def create
    article = Article.new(article_params)

    if article.save
      render json: article, status: :created
    else
      render json: article.errors.details, status: :unprocessable_entity
    end
  end

  # Método para mostrar los detalles de un artículo específico
  def show
    render json: @article
  end

  # Método para actualizar los detalles de un artículo
  def update
    if @article.update(article_params)
      render json: @article
    else
      render json: @article.errors.details, status: :unprocessable_entity
    end
  end

  # Método para eliminar un artículo
  def destroy
    if @article.destroy
      render json: @article
    else
      render json: @article.errors.details, status: :unprocessable_entity
    end
  end

  def inventory_models
    render json: Article.inventory_models
  end

  def optimal_lot
    render json: @article.optimal_lot(provider_id: params[:provider_id])
  end

  def find_by_code
    article = Article.find_by(code: params[:code])

    if article.present?
      render json: article
    else
      render status: :not_found
    end
  end

  def historical_demand
    render json: @article.historical_demand(periods_quantity: params[:periods_quantity], period: params[:period])
  end

  def predict_demand
    render json: @article.predict_demand(predict_demand_params.to_h.deep_symbolize_keys)
  end

  def providers
    render json: @article.providers
  end

  def cgi
    render json: @article.calculate_cgi(provider_id: params[:provider_id])
  end

  def active_purchase_orders
    render json: @article.purchase_orders.active
  end

  private

  # Método para permitir los parámetros de entrada de un artículo
  def article_params
    params.require(:article).permit(:name,
                                    :code,
                                    :annual_storage_cost,
                                    :stock,
                                    :inventory_model,
                                    :default_provider_id,
                                    :service_level,
                                    :revision_interval_days_count,
                                    :estimated_demand,
                                    :annual_demand_standard_deviation,
                                    :demand_period_count,
                                    :demand_period_kind,
                                    :demand_error_calculation_method,
                                    :demand_acceptable_error,
                                    article_providers_attributes: %i[provider_id
                                                                     lead_time
                                                                     order_cost
                                                                     purchase_cost])
  end

  def predict_demand_params
    params.require(:demand_prediction).permit(:periods_quantity,
                                              :period,
                                              :predicted_demand_for_first_period,
                                              :alpha,
                                              weightings: %i[period weight],
                                              prediction_methods: [])
  end

  # Método para buscar un artículo por su ID
  def set_article
    @article = Article.find_by(id: params[:id])
    return if @article.present?

    render status: :not_found
  end
end
