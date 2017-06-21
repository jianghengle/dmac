require "./controller_base"

module DMACServer
  module HttpAPI
    module DownloadController
      include DMACServer::HttpAPI::ControllerBase
      extend self

      def get_download_url(ctx)
        begin
          email = verify_token(ctx)
          project_id = get_param!(ctx, "project_id")
          data_path = get_param!(ctx, "data_path")

          project = Project.get_project!(project_id)
          control = Control.get_control!(email, project)

          download = Download.create_download(project.key.to_s, data_path)
          download.to_url.to_json
        rescue ex : InsufficientParameters
          error(ctx, "Not all required parameters were present")
        rescue e : Exception
          error(ctx, e.message.to_s)
        end
      end

      def get_public_download_url(ctx)
        begin
          public_key = get_param!(ctx, "public_key")
          project_id = get_param!(ctx, "project_id")
          data_path = get_param!(ctx, "data_path")

          project = Project.get_project!(project_id)
          public = Public.get_public!(public_key)
          raise "Wrong header" unless data_path.starts_with? public.data_path.to_s

          download = Download.create_download(project.key.to_s, data_path)
          download.to_url.to_json
        rescue ex : InsufficientParameters
          error(ctx, "Not all required parameters were present")
        rescue e : Exception
          error(ctx, e.message.to_s)
        end
      end

      def download_file(ctx)
        begin
          key = get_param!(ctx, "key")
          download = Download.get_download(key)
          project_key = download.project_key.to_s
          data_path = download.data_path.to_s
          full_path = MyFile.get_full_path(project_key, data_path)
          filename = File.basename(full_path)
          ext= File.extname(full_path)
          ctx.response.headers["Content-Disposition"] =  "attachment; filename=\"" + filename + "\""
          if ext.downcase == ".pdf"
            send_file ctx, full_path, "application/pdf"
          else
            send_file ctx, full_path
          end
          return
        rescue ex : InsufficientParameters
          error(ctx, "Not all required parameters were present")
        rescue e : Exception
          error(ctx, e.message.to_s)
        end
      end

    end
  end
end
