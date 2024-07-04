class ApplicationController < ActionController::API
  def attributes_description
    render json: controller_path.classify.constantize.attributes_description
  end
end
