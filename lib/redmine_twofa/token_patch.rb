module RedmineTwofa
  module TokenPatch

    def self.included(base)
      base.class_eval do
        add_action :twofa_backup_code, max_instances: 10, validity_time: nil
      end
    end
  end
end
