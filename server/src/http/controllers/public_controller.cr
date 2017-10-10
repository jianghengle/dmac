require "./controller_base"

module DMACServer
  module HttpAPI
    module PublicController
      include DMACServer::HttpAPI::ControllerBase
      extend self

      def make_folder_public(ctx)
        begin
          email = verify_token(ctx)
          project_id = get_param!(ctx, "projectId")
          data_path = get_param!(ctx, "dataPath")

          project = Project.get_project!(project_id)
          control = Control.get_control!(email, project)
          raise "Permission denied" unless control.role.to_s == "Owner" || control.role.to_s == "Admin"

          public = Public.get_public_by_project_path(project, data_path)
          raise "Already public" unless public.nil?

          public = Public.create_public(project, data_path)
          {"ok": true}.to_json
        rescue ex : InsufficientParameters
          error(ctx, "Not all required parameters were present")
        rescue e : Exception
          error(ctx, e.message.to_s)
        end
      end

      def get_public_file(ctx)
        begin
          public_key = get_param!(ctx, "public_key")
          data_path = get_param!(ctx, "data_path")
          data_path = URI.unescape(data_path)

          public = Public.get_public!(public_key)
          raise "Wrong header" unless data_path.starts_with? public.data_path.to_s

          project_id = public.project_id
          project = Project.get_project!(project_id)
          control = Control.new
          control.role = "Viewer"
          control.group_name = ""
          files = MyFile.collect_files(control, project, data_path)

          arr = [] of String
          arr << public.to_json
          files.each_index do |i|
            f = files[i]
            read_text = i == 0 && (f.file_type == "text" || f.file_type == "csv")
            arr << f.to_json(read_text)
          end
          json_array(arr)
        rescue ex : InsufficientParameters
          error(ctx, "Not all required parameters were present")
        rescue e : Exception
          error(ctx, e.message.to_s)
        end
      end

      def get_publics(ctx)
        begin
          email = verify_token(ctx)
          project_id = get_param!(ctx, "project_id")

          project = Project.get_project!(project_id)
          control = Control.get_control!(email, project)
          raise "Permission denied" unless control.role.to_s == "Owner" || control.role.to_s == "Admin"

          publics = Public.get_publics_by_project(project)
          arr = [] of String
          publics.each do |p|
            arr << p.to_json
          end
          json_array(arr)
        rescue ex : InsufficientParameters
          error(ctx, "Not all required parameters were present")
        rescue e : Exception
          error(ctx, e.message.to_s)
        end
      end

      def remove_folder_public(ctx)
        begin
          email = verify_token(ctx)
          project_id = get_param!(ctx, "projectId")
          public_key = get_param!(ctx, "publicKey")

          project = Project.get_project!(project_id)
          control = Control.get_control!(email, project)
          raise "Permission denied" unless control.role.to_s == "Owner" || control.role.to_s == "Admin"

          Public.delete_public(public_key)
          {"ok": true}.to_json
        rescue ex : InsufficientParameters
          error(ctx, "Not all required parameters were present")
        rescue e : Exception
          error(ctx, e.message.to_s)
        end
      end
    end
  end
end
