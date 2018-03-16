require "./controller_base"

module DMACServer
  module HttpAPI
    module IrodsController
      include DMACServer::HttpAPI::ControllerBase
      extend self

      def list_irods_path(ctx)
        begin
          verify_token(ctx)

          username = get_param!(ctx, "username")
          password = get_param!(ctx, "password")
          path = get_param!(ctx, "path")
          Irods.list_path(username, password, path)
        rescue ex : InsufficientParameters
          error(ctx, "Not all required parameters were present")
        rescue e : Exception
          error(ctx, e.message.to_s)
        end
      end
    end
  end
end
