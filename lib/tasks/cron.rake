namespace :cron do
  # este cron se debe ejecutar una vez por dia
  desc 'Generar ordenes de compra para los articulos con modelo de inventario de intervalo fijo'
  task generate_purchase_orders: :environment do
    time_zone_now = Time.zone.now

    # sin la prediccion de la demanda no se puede hacer nada
    Article.fixed_interval.where.not(estimated_demand: nil).each do |article|
      puts('##################################################################################')
      puts("Article -> #{article.name} (#{article.id})")
      puts("Fecha actual: #{time_zone_now}")
      puts("Fecha de la proxima revision: #{article.stock_will_be_checked_at}\n\n")

      # si hoy no es la fecha de revision entonces se pasa al siguiente articulo
      next unless article.stock_will_be_checked_at.today?

      # se genera la orden de compra
      purchase_order = article.generate_purchase_order!
      puts('Orden de compra generada:')
      puts("- id: #{purchase_order.id}")
      puts("- cantidad: #{purchase_order.quantity}")
      puts("- estado: #{purchase_order.state}\n\n")

      # se actualiza la fecha stock_will_be_checked_at, que indica la fecha de la proxima revision de stock
      # el intervalo de revision se persiste en dias, por ejemplo: 7 dias
      article.update!(stock_will_be_checked_at: time_zone_now + article.revision_interval_days_count.days)
      puts("Fecha de la proxima revision actualizada: #{article.stock_will_be_checked_at}\n\n")
    end
  end
end
