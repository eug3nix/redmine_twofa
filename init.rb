require 'redmine'

Redmine::Plugin.register :redmine_twofa do
  name 'Redmine Two Factor Auth  Plugin'
  author 'Eugene Dubinin, CommandPrompt, Inc. <eugend@commandprompt.com>'
  description 'Redmine two factor authentication. Based on the original work by Felix Schäfer. https://www.redmine.org/issues/1237'
  version '0.1.0'
  author_url 'https://www.commandprompt.com'
  requires_redmine :version_or_higher => '3.0.x'

  settings default: {
    'twofa': 1,
    'security_notifications': 1
  }

end

prepare_block = Proc.new do
  ApplicationController.send(:include, RedmineTwofa::ApplicationControllerPatch)
  AccountController.send(:include, RedmineTwofa::AccountControllerPatch)
  Setting.send(:include, RedmineTwofa::SettingPatch)
  Token.send(:include, RedmineTwofa::TokenPatch)
  User.send(:include, RedmineTwofa::UserPatch)
end

if Rails.env.development?
  ActionDispatch::Reloader.to_prepare { prepare_block.call }
else
  prepare_block.call
end
