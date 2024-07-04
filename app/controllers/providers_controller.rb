class ProvidersController < ApplicationController
  before_action :set_provider, only: %i[show update destroy]

  # Método para listar todos los proveedores
  def index
    render json: Provider.all
  end

  # Método para crear un nuevo proveedor
  def create
    provider = Provider.new(provider_params)

    if provider.save
      render json: provider, status: :created
    else
      render json: provider.errors.details, status: :unprocessable_entity
    end
  end

  # Método para mostrar un proveedor específico
  def show
    render json: @provider
  end

  # Método para actualizar los atributos de un proveedor
  def update
    if @provider.update(provider_params)
      render json: @provider
    else
      render json: @provider.errors.details, status: :unprocessable_entity
    end
  end

  # Método para eliminar un proveedor
  def destroy
    if @provider.destroy
      render json: @provider
    else
      render json: @provider.errors.details, status: :unprocessable_entity
    end
  end

  private

  # Método para permitir los parámetros de entrada de un proveedor
  def provider_params
    params.require(:provider).permit(:name)
  end

  # Método para buscar un proveedor por su ID
  def set_provider
    @provider = Provider.find_by(id: params[:id])
    return if @provider.present?

    render status: :not_found
  end
end
