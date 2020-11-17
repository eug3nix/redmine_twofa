module TwofaHelper
  def require_active_twofa
    Setting.twofa? ? true : deny_access
  end

  def my_account_form_method
      begin
        Rails.application.routes.recognize_path('/my/account', method: 'PUT')
        return 'put'
      rescue ActionController::RoutingError
        return 'post'
      end
  end
end
