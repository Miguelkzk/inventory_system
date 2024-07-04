class CreateArticles < ActiveRecord::Migration[7.1]
  def change
    create_table :articles do |t|
      t.string :name
      t.string :code
      t.decimal :annual_storage_cost # costo de almacenamiento anual
      t.integer :stock
      t.integer :inventory_model # modelo de inventario
      t.integer :default_provider_id # proveedor por defecto para este articulo

      # intervalo de revision para modelo de intervalo fijo
      t.integer :revision_interval_days_count # en dias

      t.integer :estimated_demand # demanda estimada para el proximo periodo

      # desviacion estandar de la demanda: cuanto varia la cantidad demandada
      # respecto a su media en un periodo de tiempo especifico
      t.integer :annual_demand_standard_deviation

      # parametros generales por defecto para la prediccion de la demanda
      t.integer :demand_period_count # cantidad de periodos a utilizar
      t.integer :demand_period_kind # tipo de periodo: week, month, year
      t.integer :demand_error_calculation_method # metodo de calculo de error
      t.decimal :demand_acceptable_error # error aceptable

      # nivel de servicio (porcentaje)
      # probabilidad de que el stock sea suficiente para cubrir el tiempo de demora del proveedor
      t.integer :service_level

      # fecha de la proxima revision del stock
      # sirve para que el cron vea si se debe generar la orden de compra
      t.datetime :stock_will_be_checked_at

      t.datetime :deleted_at, index: true

      t.timestamps
    end
  end
end
