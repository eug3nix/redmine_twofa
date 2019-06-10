module RedmineTwofa
  module AccountControllerPatch

    def self.included(base)
      base.send(:prepend, InstanceMethods)
      base.class_eval do
        before_action :require_active_twofa, :twofa_setup, only: [:twofa_resend, :twofa_confirm, :twofa]
        before_action :prevent_twofa_session_replay, only: [:twofa_resend, :twofa]
      end
    end

    module InstanceMethods
      def twofa_resend
        # otp resends count toward the maximum of 3 otp entry tries per password entry
        if session[:twofa_tries_counter] > 3
          destroy_twofa_session
          flash[:error] = l('twofa_too_many_tries')
          redirect_to home_url
        else
          if @twofa.send_code(controller: 'account', action: 'twofa')
            flash[:notice] = l('twofa_code_sent')
          end
          redirect_to account_twofa_confirm_path
        end
      end

      def twofa_confirm
        @twofa_view = @twofa.otp_confirm_view_variables
      end

      def twofa
        if @twofa.verify!(params[:twofa_code].to_s)
          destroy_twofa_session
          handle_active_user(@user)
        # allow at most 3 otp entry tries per successfull password entry
        # this allows using anti brute force techniques on the password entry to also
        # prevent brute force attacks on the one-time password
        elsif session[:twofa_tries_counter] > 3
          destroy_twofa_session
          flash[:error] = l('twofa_too_many_tries')
          redirect_to home_url
        else
          flash[:error] = l('twofa_invalid_code')
          redirect_to account_twofa_confirm_path
        end
      end

      private
        def prevent_twofa_session_replay
          renew_twofa_session(@user)
        end

        def twofa_setup
          # twofa sessions are only valid 2 minutes at a time
          twomind = 0.0014 # a little more than 2 minutes in days
          @user = Token.find_active_user('twofa_session', session[:twofa_session_token].to_s, twomind)
          unless @user.present?
            destroy_twofa_session
            redirect_to home_url
            return
          end

          # copy back_url, autologin back to params where they are expected
          params[:back_url] ||= session[:twofa_back_url]
          params[:autologin] ||= session[:twofa_autologin]

          # set locale for the twofa user
          set_localization(@user)

          # set the requesting IP of the twofa user (e.g. for security notifications)
          @user.remote_ip = request.remote_ip

          @twofa = Redmine::Twofa.for_user(@user)
        end

        def require_active_twofa
          Setting.twofa? ? true : deny_access
        end

        def setup_twofa_session(user, previous_tries=1)
          token = Token.create(user: user, action: 'twofa_session')
          session[:twofa_session_token] = token.value
          session[:twofa_tries_counter] = previous_tries
          session[:twofa_back_url] = params[:back_url]
          session[:twofa_autologin] = params[:autologin]
        end

        # Prevent replay attacks by using each twofa_session_token only for exactly one request
        def renew_twofa_session(user)
          twofa_tries = session[:twofa_tries_counter].to_i + 1
          destroy_twofa_session
          setup_twofa_session(user, twofa_tries)
        end

        def destroy_twofa_session
          # make sure tokens can only be used once server-side to prevent replay attacks
          Token.find_token('twofa_session', session[:twofa_session_token].to_s).try(:delete)
          session[:twofa_session_token] = nil
          session[:twofa_tries_counter] = nil
          session[:twofa_back_url] = nil
          session[:twofa_autologin] = nil
        end

        def handle_active_user(user)
          successful_authentication(user)
          update_sudo_timestamp! # activate Sudo Mode
        end

        def password_authentication
          user = User.try_to_login(params[:username], params[:password], false)

          if user.nil?
            invalid_credentials
          elsif user.new_record?
            onthefly_creation_failed(user, {:login => user.login, :auth_source_id => user.auth_source_id })
          else
            # Valid user
            if user.active?
              if user.twofa_active?
                setup_twofa_session user
                twofa = Redmine::Twofa.for_user(user)
                if twofa.send_code(controller: 'account', action: 'twofa')
                  flash[:notice] = l('twofa_code_sent')
                end
                redirect_to account_twofa_confirm_path
              else
                handle_active_user(user)
              end
            else
              handle_inactive_user(user)
            end
          end
        end


    end
  end
end
