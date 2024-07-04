puts('############################## CREACION DE PROVEEDORES ##############################')

provider1 = Provider.create!(name: 'Proveedor 1')
provider2 = Provider.create!(name: 'Proveedor 2')

ap(provider1.as_json)
ap(provider2.as_json)

puts('############################## CREACION DE ARTICULOS ##############################')

article1 = Article.create!(name: 'Articulo 1',
                           code: 'COD1',
                           stock: 50,
                           annual_storage_cost: 50,
                           service_level: 95,
                           annual_demand_standard_deviation: 100,
                           inventory_model: :fixed_lot,
                           demand_error_calculation_method: :absolute_deviation,
                           default_provider: provider1,
                           estimated_demand: 140,
                           demand_period_kind: :month,
                           article_providers_attributes: [{ lead_time: 5, provider: provider1, order_cost: 30, purchase_cost: 40 },
                                                          { lead_time: 12, provider: provider2, order_cost: 10, purchase_cost: 45 }])

article2 = Article.create!(name: 'Articulo 2',
                           code: 'COD2',
                           stock: 10,
                           annual_storage_cost: 100,
                           service_level: 95,
                           annual_demand_standard_deviation: 100,
                           inventory_model: :fixed_interval,
                           revision_interval_days_count: 7,
                           demand_error_calculation_method: :absolute_deviation,
                           default_provider: provider1,
                           estimated_demand: 100,
                           demand_period_kind: :month,
                           article_providers_attributes: [{ lead_time: 8, provider: provider1, order_cost: 30, purchase_cost: 40 }])

article3 = Article.create!(name: 'Articulo 3',
                           code: 'COD3',
                           stock: 90,
                           annual_storage_cost: 200,
                           service_level: 95,
                           annual_demand_standard_deviation: 100,
                           inventory_model: :fixed_lot,
                           demand_error_calculation_method: :absolute_deviation,
                           default_provider: provider1,
                           estimated_demand: 50,
                           demand_period_kind: :month,
                           article_providers_attributes: [{ lead_time: 7, provider: provider1 }])

article4 = Article.create!(name: 'Articulo 4',
                           code: 'COD4',
                           stock: 60,
                           annual_storage_cost: 150,
                           service_level: 95,
                           annual_demand_standard_deviation: 100,
                           inventory_model: :fixed_lot,
                           demand_error_calculation_method: :absolute_deviation,
                           default_provider: provider2,
                           estimated_demand: 130,
                           demand_period_kind: :month,
                           article_providers_attributes: [{ lead_time: 4, provider: provider1 },
                                                          { lead_time: 2, provider: provider2 }])

article5 = Article.create!(name: 'Articulo 5',
                           code: 'COD5',
                           stock: 80,
                           annual_storage_cost: 150,
                           service_level: 95,
                           annual_demand_standard_deviation: 100,
                           inventory_model: :fixed_interval,
                           revision_interval_days_count: 2,
                           demand_error_calculation_method: :absolute_deviation,
                           default_provider: provider2,
                           estimated_demand: 130,
                           demand_period_kind: :month,
                           article_providers_attributes: [{ lead_time: 5, provider: provider2 },])


ap(article1.as_json(methods: :article_providers))
ap(article2.as_json(methods: :article_providers))
ap(article3.as_json(methods: :article_providers))
ap(article4.as_json(methods: :article_providers))
ap(article5.as_json(methods: :article_providers))

puts('############################## CREACION DE VENTAS ##############################')

sale1 = Sale.create!(
                    sold_at: Time.zone.now,
                    article_sales_attributes: [
                    { article_id: 1, quantity: 180 }
                    ]
)
sale2 = Sale.create!(
                    sold_at: Time.zone.now - 1.month,
                    article_sales_attributes: [
                    { article_id: 1, quantity: 168 }
                    ]
)

sale3 = Sale.create!(
                    sold_at: Time.zone.now - 2.month,
                    article_sales_attributes: [
                    { article_id: 1, quantity: 159 }
                    ]
)

sale4 = Sale.create!(
                    sold_at: Time.zone.now - 3.month,
                    article_sales_attributes: [
                    { article_id: 1, quantity: 175 }
                    ]
)

sale5 = Sale.create!(
                    sold_at: Time.zone.now - 4.month,
                    article_sales_attributes: [
                    { article_id: 1, quantity: 190 }
                    ]
)

sale6 = Sale.create!(
                    sold_at: Time.zone.now - 5.month,
                    article_sales_attributes: [
                    { article_id: 1, quantity: 205 }
                    ]
)

sale7 = Sale.create!(
                    sold_at: Time.zone.now - 6.month,
                    article_sales_attributes: [
                    { article_id: 1, quantity: 180 }
                    ]
)

sale8 = Sale.create!(
                    sold_at: Time.zone.now - 7.month,
                    article_sales_attributes: [
                    { article_id: 1, quantity: 182 }
                    ]
)
sale9 = Sale.create!(
                    sold_at: Time.zone.now,
                    article_sales_attributes: [
                    { article_id: 2, quantity: 122 }
                    ]
)

sale10 = Sale.create!(
                    sold_at: Time.zone.now - 1.month,
                    article_sales_attributes: [
                    { article_id: 2, quantity: 142 }
                    ]
)
sale11 = Sale.create!(
                    sold_at: Time.zone.now - 2.month,
                    article_sales_attributes: [
                    { article_id: 2, quantity: 105 }
                    ]
)
sale12 = Sale.create!(
                    sold_at: Time.zone.now - 3.month,
                    article_sales_attributes: [
                    { article_id: 2, quantity: 90 }
                    ]
)
sale13 = Sale.create!(
                    sold_at: Time.zone.now - 4.month,
                    article_sales_attributes: [
                    { article_id: 2, quantity: 80 }
                    ]
)
sale14 = Sale.create!(
                    sold_at: Time.zone.now - 5.month,
                    article_sales_attributes: [
                    { article_id: 2, quantity: 79 }
                    ]
)
sale14 = Sale.create!(
                    sold_at: Time.zone.now - 6.month,
                    article_sales_attributes: [
                    { article_id: 2, quantity: 74 }
                    ]
)

ap(sale1.as_json(methods: :article_sales))
ap(sale2.as_json(methods: :article_sales))
ap(sale3.as_json(methods: :article_sales))
ap(sale4.as_json(methods: :article_sales))
ap(sale5.as_json(methods: :article_sales))
ap(sale6.as_json(methods: :article_sales))
ap(sale7.as_json(methods: :article_sales))
ap(sale8.as_json(methods: :article_sales))
ap(sale9.as_json(methods: :article_sales))
ap(sale10.as_json(methods: :article_sales))
ap(sale11.as_json(methods: :article_sales))
ap(sale12.as_json(methods: :article_sales))
ap(sale13.as_json(methods: :article_sales))
ap(sale14.as_json(methods: :article_sales))

# desde ahora hasta 8 meses atras (32 semanas aproximadamente)
# (0..32).each do |week_number|
#   sale = Sale.create!(sold_at: Time.zone.now - week_number.weeks,
#                       article_sales_attributes: [{ quantity: rand(10..50), article: article1 },
#                                                  { quantity: rand(10..50), article: article2 },
#                                                  { quantity: rand(10..50), article: article3 }])

#   ap(sale.as_json(methods: :article_sales))
# end

puts('############################## CREACION DE ORDENES DE COMPRA ##############################')

purchase_order1 = PurchaseOrder.create!(state: :pending,
                                        quantity: 20,
                                        article: article1)

purchase_order2 = PurchaseOrder.create!(state: :finished,
                                        quantity: 30,
                                        article: article2)

ap(purchase_order1.as_json)
ap(purchase_order2.as_json)
