module RedmineTwofa
  module SettingPatch
    def self.included(base)
      base.extend(InstanceMethods)
    end

    module InstanceMethods
      def plugin_redmine_twofa_from_params(params)
        # unpair all current 2FA pairings when switching off 2FA
        Redmine::Twofa.unpair_all! if params == '0' && self.twofa?
        params
      end
      def twofa?
        Setting['plugin_redmine_twofa'].to_i > 0
      end
      def twofa
        Setting['plugin_redmine_twofa'].to_i
      end
    end
  end
end
