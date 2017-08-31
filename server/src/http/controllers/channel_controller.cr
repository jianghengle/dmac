require "./controller_base"

module DMACServer
  module HttpAPI
    module ChannelController
      include DMACServer::HttpAPI::ControllerBase
      extend self

      def get_channels(ctx)
        begin
          email = verify_token(ctx)
          project_id = get_param!(ctx, "project_id")

          project = Project.get_project!(project_id)
          control = Control.get_control!(email, project)
          raise "Permission denied" if control.role.to_s == "Viewer"

          channels = Channel.get_channels_by_project(project)
          arr = [] of String
          channels.each do |p|
            arr << p.to_json
          end
          json_array(arr)
        rescue ex : InsufficientParameters
          error(ctx, "Not all required parameters were present")
        rescue e : Exception
          error(ctx, e.message.to_s)
        end
      end

      def get_directories(ctx)
        begin
          email = verify_token(ctx)
          project_id = get_param!(ctx, "project_id")

          project = Project.get_project!(project_id)
          control = Control.get_control!(email, project)
          raise "Permission denied" unless control.role.to_s == "Owner" || control.role.to_s == "Admin"

          directories = Channel.get_directories_by_project(project)
          directories.to_json
        rescue ex : InsufficientParameters
          error(ctx, "Not all required parameters were present")
        rescue e : Exception
          error(ctx, e.message.to_s)
        end
      end

      def get_files(ctx)
        begin
          email = verify_token(ctx)
          project_id = get_param!(ctx, "project_id")
          path = get_param!(ctx, "path")

          project = Project.get_project!(project_id)
          control = Control.get_control!(email, project)
          raise "Permission denied" unless control.role.to_s == "Owner" || control.role.to_s == "Admin"

          files = Channel.get_files_by_path(project, path)
          files.to_json
        rescue ex : InsufficientParameters
          error(ctx, "Not all required parameters were present")
        rescue e : Exception
          error(ctx, e.message.to_s)
        end
      end

      def create_channel(ctx)
        begin
          email = verify_token(ctx)
          project_id = get_param!(ctx, "projectId")
          path = get_param!(ctx, "path")
          meta_data = get_param!(ctx, "metaData")
          instruction = get_param!(ctx, "instruction")
          rename = get_param!(ctx, "rename")

          project = Project.get_project!(project_id)
          control = Control.get_control!(email, project)
          raise "Permission denied" unless control.role.to_s == "Owner" || control.role.to_s == "Admin"

          Channel.create_channel(project, path, meta_data, instruction, rename)
          {"ok": true}.to_json
        rescue ex : InsufficientParameters
          error(ctx, "Not all required parameters were present")
        rescue e : Exception
          error(ctx, e.message.to_s)
        end
      end

      def update_channel(ctx)
        begin
          email = verify_token(ctx)
          project_id = get_param!(ctx, "projectId")
          id = get_param!(ctx, "id")
          path = get_param!(ctx, "path")
          meta_data = get_param!(ctx, "metaData")
          instruction = get_param!(ctx, "instruction")
          rename = get_param!(ctx, "rename")

          project = Project.get_project!(project_id)
          control = Control.get_control!(email, project)
          raise "Permission denied" unless control.role.to_s == "Owner" || control.role.to_s == "Admin"

          Channel.update_channel(id, path, meta_data, instruction, rename)
          {"ok": true}.to_json
        rescue ex : InsufficientParameters
          error(ctx, "Not all required parameters were present")
        rescue e : Exception
          error(ctx, e.message.to_s)
        end
      end

      def delete_channel(ctx)
        begin
          email = verify_token(ctx)
          project_id = get_param!(ctx, "projectId")
          id = get_param!(ctx, "id")

          project = Project.get_project!(project_id)
          control = Control.get_control!(email, project)
          raise "Permission denied" unless control.role.to_s == "Owner" || control.role.to_s == "Admin"

          Channel.delete_channel(id)
          {"ok": true}.to_json
        rescue ex : InsufficientParameters
          error(ctx, "Not all required parameters were present")
        rescue e : Exception
          error(ctx, e.message.to_s)
        end
      end

      def get_metadata(ctx)
        begin
          email = verify_token(ctx)
          project_id = get_param!(ctx, "project_id")
          id = get_param!(ctx, "id")

          project = Project.get_project!(project_id)
          control = Control.get_control!(email, project)
          raise "Permission denied" if control.role.to_s == "Viewer"

          metadata = Channel.get_metadata(project, id)
          metadata.to_json
        rescue ex : InsufficientParameters
          error(ctx, "Not all required parameters were present")
        rescue e : Exception
          error(ctx, e.message.to_s)
        end
      end

      def upload_channel(ctx)
        begin
          email = verify_token(ctx)
          project_id = get_param!(ctx, "project_id")
          id = get_param!(ctx, "id")
          file = ctx.params.files["file"]
          new_name = get_body!(ctx, "newName")
          meta_data = get_body!(ctx, "metaData")

          project = Project.get_project!(project_id)
          control = Control.get_control!(email, project)
          raise "Permission denied" if control.role.to_s == "Viewer"
          raise "Permission denied" if (control.role.to_s == "Editor" && project.status != "Active")

          rel_path = Channel.upload_data(project, id, file, new_name, meta_data)
          Git.commit(project, email + " uploaded " + rel_path + " by channel")

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
