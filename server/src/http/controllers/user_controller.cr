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

          account_server = ""
          if ENV.has_key?("ACCOUNT_SERVER")
            account_server = ENV["ACCOUNT_SERVER"].to_s
          end

          if account_server == ""
            {token: email.gsub("@", "--")}.to_json
          else
            response = HTTP::Client.post(account_server+"/get_token", headers: HTTP::Headers{"Content-Type" => "application/json"}, body: {email: email, password: password}.to_json)
            resp = JSON.parse(response.body)
            token = resp["token"].to_s
            {token: token}.to_json
          end

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

      def get_email(token : String)
        return verify_token(token)
      end

      def verify_token(token : String)
        account_server = ""
        if ENV.has_key?("ACCOUNT_SERVER")
          account_server = ENV["ACCOUNT_SERVER"].to_s
        end
        return token.gsub("--", "@") if account_server == ""

        response = HTTP::Client.post(account_server+"/get_user", headers: HTTP::Headers{"Content-Type" => "application/json"}, body: {token: token}.to_json)
        resp = JSON.parse(response.body)
        email = resp["email"].to_s
        return email
      end

    end
  end
end
