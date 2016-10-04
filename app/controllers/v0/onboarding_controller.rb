module V0
  class OnboardingController < ActionController::Base

      def new_session
        render json: {"SUCCESS" => Orphan.get_new_key }
      end

      def push_session
        if validate_key
          Orphan.post_data!(params)
          render json: {"SUCCESS" => "worked"}
        else
          render json: {"ERROR" => "Key not found"}
        end
      end

      def finish_onboarding
        params[:user]
        ##get data from orphan to real data
      end

      private

      def validate_key
        val = Orphan.where(session_key: params[:key])
        val ? val : false
      end
  end
end

