module RedmineTwofa
  module ApplicationControllerPatch

    def self.included(base)
      base.send(:include, InstanceMethods)
      base.class_eval do
        helper TwofaHelper
        before_action :check_twofa_activation
        # alias_method_chain :start_user_session, :twofa
        alias_method :start_user_session_without_twofa, :start_user_session
        alias_method :start_user_session, :start_user_session_with_twofa
      end
    end

    module InstanceMethods
      def init_twofa_pairing_and_send_code_for(twofa)
        twofa.init_pairing!
        if twofa.send_code(controller: 'twofa', action: 'activate')
          flash[:notice] = l('twofa_code_sent')
        end
        redirect_to controller: 'twofa', action: 'activate_confirm', scheme: twofa.scheme_name
      end

      def check_twofa_activation
        if session[:must_activate_twofa]
          if User.current.must_activate_twofa?
            flash[:warning] = l('twofa_warning_require')
            if Redmine::Twofa.available_schemes.length == 1
              twofa_scheme = Redmine::Twofa.for_twofa_scheme(Redmine::Twofa.available_schemes.first)
              twofa = twofa_scheme.new(User.current)
              init_twofa_pairing_and_send_code_for(twofa)
            else
              redirect_to controller: 'twofa', action: 'select_scheme'
            end
          else
            session.delete(:must_activate_twofa)
          end
        end
      end

      def start_user_session_with_twofa(user)
        start_user_session_without_twofa(user)
        if user.must_activate_twofa?
          session[:must_activate_twofa] = '1'
        end
      end

      # private


    end
  end
end
