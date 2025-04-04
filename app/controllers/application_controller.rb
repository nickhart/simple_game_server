class ApplicationController < ActionController::Base
  # Skip CSRF protection for API requests
  skip_before_action :verify_authenticity_token, if: :json_request?

  before_action :set_current_user

  private

  def set_current_user
    Current.user = current_user
  end

  def json_request?
    request.format.json?
  end
end
