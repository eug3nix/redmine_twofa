module RedmineTwofa
  module UserPatch

    def self.included(base)
      base.send(:include, InstanceMethods)
      base.class_eval do
        include Redmine::Ciphering
      end
    end

    module InstanceMethods
      def twofa_active?
        twofa_scheme.present?
      end

      def must_activate_twofa?
        Setting.twofa == '2' && !twofa_active?
      end

      def twofa_totp_key
        read_ciphered_attribute(:twofa_totp_key)
      end

      def twofa_totp_key=(key)
        write_ciphered_attribute(:twofa_totp_key, key)
      end

    end
  end
end
