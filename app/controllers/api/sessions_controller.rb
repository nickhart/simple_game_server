module Api
  class SessionsController < BaseController
    skip_before_action :authenticate_user!, only: %i[create refresh]

    def create
    session_params = params.require(:session).permit(:email, :password)
    user = User.find_by(email: session_params[:email])
    if user&.valid_password?(session_params[:password])
        access_token = Token.create_access_token(user)
        refresh_token = Token.create_refresh_token(user)

        render json: {
          access_token: generate_token(access_token),
          refresh_token: generate_token(refresh_token),
          user: {
            id: user.id,
            email: user.email
          }
        }
      else
        render_error("Invalid email or password", status: :unauthorized)
      end
    end

    def refresh
    refresh_params = params.require(:session).permit(:refresh_token)
    payload = JWT.decode(refresh_params[:refresh_token], Rails.application.credentials.secret_key_base).first
      refresh_token = Token.find_by(jti: payload["jti"])
      user = User.find(payload["user_id"])

      if refresh_token&.active? && user.token_version == payload["token_version"]
        access_token = Token.create_access_token(user)
        render json: {
          access_token: generate_token(access_token)
        }
      else
        render_error("Invalid refresh token", status: :unauthorized)
      end
    rescue JWT::DecodeError, ActiveRecord::RecordNotFound
      render_error("Invalid refresh token", status: :unauthorized)
    end

    def destroy
      current_user.invalidate_token!
      head :no_content
    end

    private

    def generate_token(token)
      payload = {
        jti: token.jti,
        user_id: token.user.id,
        token_version: token.user.token_version,
        exp: token.expires_at.to_i
      }
      JWT.encode(payload, Rails.application.credentials.secret_key_base)
    end
  end
end
