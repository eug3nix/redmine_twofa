module TwofaHelper
  def require_active_twofa
    Setting.twofa? ? true : deny_access
  end
end
