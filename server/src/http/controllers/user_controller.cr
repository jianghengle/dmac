require "./controller_base"

module DMACServer
  module HttpAPI
    module UserController
      include DMACServer::HttpAPI::ControllerBase
      extend self

      def get_auth_token(ctx)
        begin
          email = get_param!(ctx, "email")
          password = get_param!(ctx, "password")
          token = User.get_token(email, password)
          {token: token}.to_json
        rescue ex : InsufficientParameters
          error(ctx, "Not all required parameters were present")
        rescue e : Exception
          error(ctx, e.message.to_s)
        end
      end

      def get_token(ctx)
        begin
          email = get_param!(ctx, "email")
          password = get_param!(ctx, "password")
          token = User.get_token(email, password)
          {token: token}.to_json
        rescue ex : InsufficientParameters
          error(ctx, "Not all required parameters were present")
        rescue e : Exception
          error(ctx, e.message.to_s)
        end
      end

      def get_user(ctx)
        begin
          token = get_param!(ctx, "token")
          user = User.get_user(token)
          {email: user.email.to_s}.to_json
        rescue ex : InsufficientParameters
          error(ctx, "Not all required parameters were present")
        rescue e : Exception
          error(ctx, e.message.to_s)
        end
      end

      def create_user(ctx)
        begin
          email = get_param!(ctx, "email")
          password = get_param!(ctx, "password")
          first_name = get_param!(ctx, "firstName")
          last_name = get_param!(ctx, "lastName")
          User.create_user(email, password, first_name, last_name)
          {ok: true}.to_json
        rescue ex : InsufficientParameters
          error(ctx, "Not all required parameters were present")
        rescue e : Exception
          error(ctx, e.message.to_s)
        end
      end

    end
  end
end
