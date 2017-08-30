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
          elsif account_server == "localhost"
            token = User.get_token(email, password)
            {token: token}.to_json
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


      def authcallback(ctx)
        client_id = ""
        if ENV.has_key?("GLOBUS_CLIENT_ID")
          client_id = ENV["GLOBUS_CLIENT_ID"].to_s
        end

        client_secret = ""
        if ENV.has_key?("GLOBUS_CLIENT_SECRET")
          client_secret = ENV["GLOBUS_CLIENT_SECRET"].to_s
        end

        auth_server_uri = "auth.globus.org/v2"
        redirect_uri = "https://34.212.66.157/authcallback"

        oauth2_client = OAuth2::Client.new(auth_server_uri, client_id, client_secret, redirect_uri: redirect_uri)

        code = get_param(ctx, "code")
        if code.nil?
          scope = "openid profile email urn:globus:auth:scope:transfer.api.globus.org:all"
          state = "_default"
          authorize_uri = oauth2_client.get_authorize_uri(scope: scope, state: state)
          ctx.redirect authorize_uri
          return
        end

        puts "callback"
        access_token = oauth2_client.get_access_token_using_authorization_code(code)
        puts access_token.to_json
        "back"
      end

    end
  end
end
