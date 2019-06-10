module Redmine
  module Twofa
    def self.register_scheme(name, klass)
      initialize_schemes
      @@schemes[name] = klass
    end

    def self.available_schemes
      schemes.keys
    end

    def self.for_twofa_scheme(name)
      schemes[name]
    end

    def self.for_user(user)
      for_twofa_scheme(user.twofa_scheme).try(:new, user)
    end

    def self.unpair_all!
      users = User.where.not(twofa_scheme: nil)
      users.each { |u| self.for_user(u).destroy_pairing_without_verify! }
    end

    private

    def self.schemes
      initialize_schemes
      @@schemes
    end

    def self.initialize_schemes
      @@schemes ||= { }
      scan_builtin_schemes if @@schemes.blank?
    end

    def self.scan_builtin_schemes
      bd = Pathname(File.expand_path("..", __FILE__))
      Dir[bd.join('twofa', '*.rb')].each do |file|
        require_dependency file
      end
    end
  end
end
