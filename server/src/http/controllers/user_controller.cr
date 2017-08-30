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
        begin
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
            puts authorize_uri
            ctx.redirect authorize_uri
            return
          end

          puts "callback"

          raw = {} of String => Array(String)
          params = HTTP::Params.new raw
          params.add("grant_type", "authorization_code")
          params.add("code", code)
          params.add("redirect_uri", redirect_uri)
          params.add("client_id", client_id)
          credential = Base64.strict_encode(client_id + ":" + client_secret)
          response = HTTP::Client.post("https://auth.globus.org/v2/oauth2/token" + "?" + params.to_s,
            headers: HTTP::Headers{"Authorization" => "Basic " + credential})
          resp = JSON.parse(response.body)
          id_token = resp["id_token"].to_s
          puts id_token
          email = retrieve_email(id_token)
          puts email
          puts "back"
        rescue e : Exception
          error(ctx, e.message.to_s)
        end
      end

      def retrieve_email(id_token)
        email = ""
        id_token.split('.').each do |s|
          begin
            d = Base64.decode_string(s)
            puts d
            tokens = JSON.parse(d).as_h
            email = tokens["email"].to_s if tokens.has_key? "email"
          rescue e : Exception
            puts e.message.to_s
          end
        end
        return email.downcase
      end

    end
  end
end
