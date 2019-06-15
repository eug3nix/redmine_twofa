module RedmineTwofa
  module SettingPatch
    def self.included(base)
      base.extend(InstanceMethods)
      base.instance_eval do
        def load_available_settings
          YAML::load(File.open("#{Rails.root}/config/settings.yml")).each do |name, options|
            define_setting name, options
          end
          define_setting 'twofa', {"dafault" => 1, "security_notifications" => 1}
          available_settings
        end
        load_available_settings
      end
    end

    module InstanceMethods

      def twofa_from_params(params)
        # unpair all current 2FA pairings when switching off 2FA
        Redmine::Twofa.unpair_all! if params == '0' && self.twofa?
        params
      end
    end
  end
end
