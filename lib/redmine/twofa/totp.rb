module Redmine
  module Twofa
    class Totp < Base
      def init_pairing!
        @user.update!(twofa_totp_key: ROTP::Base32.random_base32)
        # reset the cached totp as the key might have changed
        @totp = nil
        super
      end

      def destroy_pairing_without_verify!
        @user.update!(twofa_totp_key: nil, twofa_totp_last_used_at: nil)
        # reset the cached totp as the key might have changed
        @totp = nil
        super
      end

      def verify_otp!(code)
        # topt codes are white-space-insensitive
        code = code.to_s.remove(/[[:space:]]/)
        last_verified_at = @user.twofa_totp_last_used_at
        verified_at = totp.verify_with_drift_and_prior(code.to_s, allowed_drift, last_verified_at)
        if verified_at
          @user.update!(twofa_totp_last_used_at: verified_at)
          return true
        else
          return false
        end
      end

      def provisioning_uri
        totp.provisioning_uri(@user.mail)
      end

      def init_pairing_view_variables
        super.merge({
          provisioning_uri: provisioning_uri,
          totp_key: @user.twofa_totp_key
        })
      end

      private

      def totp
        @totp ||= ROTP::TOTP.new(@user.twofa_totp_key, issuer: Setting.app_title)
      end
    end
  end
end
