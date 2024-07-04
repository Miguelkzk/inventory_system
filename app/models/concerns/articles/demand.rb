module Articles::Demand
  extend ActiveSupport::Concern

  # periods_quantity: es la cantidad de periodos que se van a tener en cuenta
  # period:
  # - week (semanal)
  # - month (mensual)
  # - year (anual)
  def historical_demand(periods_quantity: demand_period_count, period: demand_period_kind)
    period ||= :month
    article_sales.group_by_period(period, :sold_at, last: periods_quantity, current: true).sum(:quantity)
  end

  ############################################################################################
  # PROMEDIO MOVIL
  ############################################################################################

  # Promedio movil
  def moving_average(periods_quantity: nil, period: demand_period_kind, real_demands: nil)
    real_demands ||= historical_demand(periods_quantity:, period:).values
    (real_demands.sum / periods_quantity).round
  end

  # Historico de predicciones usando promedio movil
  def moving_average_historical_predictions(periods_quantity:, period: demand_period_kind)
    # real_demands = [10, 20, 30, 40, 50, 60]
    real_demands = historical_demand(periods_quantity: periods_quantity * 2, period:).values.delete_if(&:zero?) # [10, 20, 30, 40, 50, 60]
    return if real_demands.size / 2 < periods_quantity

    # (1..3).to_a = [1, 2, 3]
    (1..periods_quantity).to_a.map do
      # real_demands = [10, 20, 30, 40, 50]
      result = moving_average(periods_quantity:, period:, real_demands: real_demands.last(periods_quantity))

      real_demands.pop # real_demands = [10, 20, 30, 40]

      result
    end.reverse
  end

  # Desviacion absoluta media usando promedio movil
  def moving_average_absolute_deviation(periods_quantity:, period: demand_period_kind)
    predictions = moving_average_historical_predictions(periods_quantity:, period:)
    return if predictions.blank?

    absolute_deviation_error(real_demands: historical_demand(periods_quantity:, period:).values, predictions:)
  end

  ############################################################################################
  # PROMEDIO MOVIL PONDERADO
  ############################################################################################

  # Promedio movil ponderado
  # weightings: [{ period: 1, weight: 3 }, { period: 2, weight: 4 }, ...]
  def weighted_moving_average(weightings:, period: demand_period_kind, real_demands: nil)
    # array de ponderaciones ordenadas desde el periodo mas viejo al mas nuevo: [3, 4]
    weightings_values = weightings.sort_by { |weighting| weighting[:period] }.map { |weighting| weighting[:weight].to_f }

    # si el valor de la demanda por cada periodo es:
    # - periodo 1 => demanda 70
    # - periodo 2 => demanda 85
    # product_demands_weightings es el producto uno a uno entre el array del historico
    # de demanda y el array de ponderaciones ordenado: [3, 4] x [70, 85] => [3 x 70, 4 x 85] => [210, 340]
    real_demands ||= historical_demand(periods_quantity: weightings.size, period:).values
    product_demands_weightings = real_demands.zip(weightings_values).map { |demand, pond| demand * pond }

    (product_demands_weightings.sum / weightings_values.sum).round
  end

  # Historico de predicciones usando promedio movil ponderado
  def weighted_moving_average_historical_predictions(weightings:, periods_quantity: demand_period_count, period: demand_period_kind)
    # [{ period: 1, weight: 1 }, { period: 2, weight: 2 }, { period: 3, weight: 3 }].size
    weightings_size = weightings.size

    # real_demands = [10, 12, 13, 16, 19, 23, 26, 30, 28, 18, 16, 14] # 12 elementos
    real_demands = historical_demand(periods_quantity: periods_quantity + weightings_size, period:).values.delete_if(&:zero?)

    return if real_demands.size + weightings_size < periods_quantity

    # (1..12).to_a = [1, 2, 3, 4, ..., 12]
    (1..periods_quantity).to_a.map do
      result = weighted_moving_average(weightings:, period:, real_demands: real_demands.last(weightings_size))

      real_demands.pop # real_demands = [10, 20, 30, 40]

      result
    end.reverse
  end

  # Desviacion absoluta media usando promedio movil ponderado
  def weighted_moving_average_absolute_deviation(weightings:, periods_quantity: demand_period_count, period: demand_period_kind)
    # predictions =    [14, 17, 21, 24, 28, 28, 23, 19, 15]
    predictions = weighted_moving_average_historical_predictions(weightings:, periods_quantity:, period:)
    return if predictions.blank?

    # real_demands = [16, 19, 23, 26, 30, 28, 18, 16, 14]
    real_demands = historical_demand(periods_quantity:, period:).values

    absolute_deviation_error(real_demands:, predictions:)
  end

  ############################################################################################
  # SUAVIZACION EXPONENCIAL
  ############################################################################################

  # Suavizacion exponencial
  def exponential_smoothing(predicted_demand_for_first_period:, periods_quantity: demand_period_count, alpha: 0.5, period: demand_period_kind)
    exponential_smoothing_historical_predictions(predicted_demand_for_first_period:, periods_quantity:, alpha:, period:).last
  end

  # historico de predicciones usando suavizacion exponencial
  def exponential_smoothing_historical_predictions(predicted_demand_for_first_period:, periods_quantity: demand_period_count, alpha: 0.5, period: demand_period_kind)
    real_demands = historical_demand(periods_quantity:, period:).values
    # real_demands = [180, 168, 159, 175, 190, 205, 180, 182] # 8 periodos

    pronosticos = [predicted_demand_for_first_period] # size va a ser de 9

    real_demands.each_with_index do |demand, index|
      pronosticos << (alpha * demand + (1 - alpha) * pronosticos[index]).round
    end

    pronosticos
  end

  # Desviacion absoluta media usando suavizacion exponencial
  def exponential_smoothing_absolute_deviation(predicted_demand_for_first_period:, periods_quantity: demand_period_count, alpha: 0.5, period: demand_period_kind)
    # real_demands = [180, 168, 159, 175, 190, 205, 180, 182] # 8 periodos
    # predictions = [175, 178, 173, 166, 171, 181, 193, 187, 185] # 9 periodos (contiene la prediccion para el proximo)

    real_demands = historical_demand(periods_quantity:, period:).values
    predictions = exponential_smoothing_historical_predictions(predicted_demand_for_first_period:, periods_quantity:, alpha:, period:)
    return if predictions.blank?

    predictions.pop # elimina el ultimo elemento porque es la prediccion para el proximo periodo

    absolute_deviation_error(real_demands:, predictions:)
  end

  ############################################################################################
  # REGRESION LINEAL
  ############################################################################################

  def linear_regression(periods_quantity: nil, period: demand_period_kind, ys: [])
    xs = (1..periods_quantity).to_a
    ys = historical_demand(periods_quantity:, period:).values if ys.empty?
    # ys = [74, 79, 80, 90, 105, 142, 122] # ejercicio 5 del tp

    prom_x = xs.sum / periods_quantity.to_f
    prom_y = ys.sum / periods_quantity.to_f

    return ys.first if periods_quantity == 1

    sum_x_y = xs.zip(ys).map { |x, y| x * y }.sum
    sum_x_cuadrado = xs.map { |x| x**2 }.sum

    b = (sum_x_y - periods_quantity * prom_x * prom_y) / (sum_x_cuadrado - periods_quantity * prom_x**2)
    a = prom_y - b * prom_x

    (b * (periods_quantity + 1) + a).round
  end

  # Historico de predicciones usando regresion lineal
  def linear_regression_historical_predictions(periods_quantity: demand_period_count, period: demand_period_kind)
    # real_demands = [74, 79, 80, 90, 105, 142, 122]
    real_demands = historical_demand(periods_quantity: periods_quantity * 2, period:).values.delete_if(&:zero?)
    return if real_demands.size / 2 < periods_quantity

    # (1..7).to_a = [1, 2, 3, 4, 5, 6, 7]
    (1..periods_quantity).to_a.map do
      # real_demands = [45, 48, 49, 50, 55, 58, 60, 74, 79, 80, 90, 105, 142, 122]
      result = linear_regression(periods_quantity:, period:, ys: real_demands.last(periods_quantity))

      real_demands.pop # real_demands = [10, 20, 30, 40]

      result
    end.reverse
  end

  # Desviacion absoluta media usando regresion lineal
  def linear_regression_absolute_deviation(periods_quantity: demand_period_count, period: demand_period_kind)
    # real_demands = [74, 79, 80, 90, 105, 142, 122] # 7 periodos
    # predictions =  [75, 79, 82, 93, 110, 140, 121, 185] # 8 periodos (contiene la prediccion para el proximo)

    real_demands = historical_demand(periods_quantity:, period:).values
    predictions = linear_regression_historical_predictions(periods_quantity:, period:)
    return if predictions.blank?

    absolute_deviation_error(real_demands:, predictions:)
  end

  def absolute_deviation_error(real_demands:, predictions:)
    result = real_demands.zip(predictions).map do |real_demand, prediction|
      (real_demand - prediction).abs
    end.sum / real_demands.size.to_f

    result.round(2)
  end

  ############################################################################################
  # PREDICCION
  ############################################################################################

  def predict_demand(args)
    result = {}

    args[:prediction_methods].each do |prediction_method|
      value, error = case prediction_method.to_sym
                     when :moving_average
                       params = args.slice(:periods_quantity, :period)
                       [moving_average(**params), moving_average_absolute_deviation(**params)]
                     when :weighted_moving_average
                       [weighted_moving_average(**args.slice(:weightings, :period)),
                        weighted_moving_average_absolute_deviation(**args.slice(:weightings, :period, :periods_quantity))]
                     when :exponential_smoothing
                       params = args.slice(:predicted_demand_for_first_period, :periods_quantity, :alpha, :period)
                       [exponential_smoothing(**params), exponential_smoothing_absolute_deviation(**params)]
                     when :linear_regression
                       params = args.slice(:periods_quantity, :period)
                       [linear_regression(**params), linear_regression_absolute_deviation(**params)]
                     end

      result[prediction_method.to_sym] = { value:, error: }
    end

    result
  end
end
