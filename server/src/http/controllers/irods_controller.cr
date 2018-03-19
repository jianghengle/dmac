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

      def transfer_to_irods(ctx)
        begin
          email = verify_token(ctx)

          username = get_param!(ctx, "username")
          password = get_param!(ctx, "password")
          path = get_param!(ctx, "path")
          project_id = get_param!(ctx, "projectId")
          data_paths_json = get_param!(ctx, "dataPaths")
          data_paths = [] of String
          JSON.parse(data_paths_json).each { |p| data_paths << p.to_s }

          project = Project.get_project!(project_id)
          control = Control.get_control!(email, project)
          data_paths.each do |dp|
            mf = MyFile.new(project, dp)
            next unless mf.viewable?(control)
            if mf.type == "file"
              Irods.transfer_file_to(username, password, mf.full_path, path)
            elsif mf.type == "folder"
              Irods.transfer_folder_to(username, password, mf.full_path, path)
            end
          end
          {"ok": true}.to_json
        rescue ex : InsufficientParameters
          error(ctx, "Not all required parameters were present")
        rescue e : Exception
          error(ctx, e.message.to_s)
        end
      end

      def transfer_from_irods(ctx)
        begin
          email = verify_token(ctx)

          username = get_param!(ctx, "username")
          password = get_param!(ctx, "password")
          data_path = get_param!(ctx, "dataPath")
          project_id = get_param!(ctx, "projectId")
          files_json = get_param!(ctx, "files")

          files = [] of Array(String)
          JSON.parse(files_json).each do |f|
            arr = [] of String
            JSON.parse(f.to_s).each { |a| arr << a.to_s }
            files << arr
          end

          project = Project.get_project!(project_id)
          control = Control.get_control!(email, project)
          role = control.role.to_s
          mf = MyFile.new(project, data_path)

          files.each do |f|
            next unless mf.can_add_file?(control, f[0])
            if f[1] == "file"
              Irods.transfer_file_from(username, password, f[2], mf.full_path)
            elsif f[1] == "folder"
              next unless role == "Owner" || role == "Admin"
              Irods.transfer_folder_from(username, password, f[2], mf.full_path)
            end
          end
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
