class OauthsController < ApplicationController
  def oauth
    login_at(:line)
  end

  def callback
    provider = "line"
    if @user = login_from(provider)
      redirect_to root_path, notice: "#{provider.titleize}でログインしました。"
    else
      redirect_to root_path, alert: "ログインに失敗しました。"
    end
  end
  private

    def auth_params
        params.permit(:code, :provider, :error, :state)
    end
end