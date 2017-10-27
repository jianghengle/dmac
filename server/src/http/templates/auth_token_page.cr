require "./template_base"

module DMACServer
  module HttpAPI
    class AuthTokenPage
      def initialize(@email : String, @token : String, @username : String)
      end

      my_render "auth_token_page"
    end
  end
end
