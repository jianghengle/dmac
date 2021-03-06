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
          role = control.role.to_s
          raise "Permission denied" if role == "Viewer"

          channels = Channel.get_channels_by_project(project)
          arr = [] of String
          channels.each do |c|
            if role == "Owner" || role == "Admin"
              arr << c.to_json
            elsif c.status.to_s == "Open"
              arr << c.to_json
            elsif c.status.to_s.starts_with? "Open to:"
              channel_group = c.status.to_s[8..-1].strip
              arr << c.to_json if channel_group == control.group_name
            end
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
          path = URI.unescape(path)

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
          status = get_param!(ctx, "status")
          name = get_param!(ctx, "name")

          project = Project.get_project!(project_id)
          control = Control.get_control!(email, project)
          raise "Permission denied" unless control.role.to_s == "Owner" || control.role.to_s == "Admin"

          Channel.create_channel(project, path, meta_data, instruction, status, name)
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
          status = get_param!(ctx, "status")
          name = get_param!(ctx, "name")

          project = Project.get_project!(project_id)
          control = Control.get_control!(email, project)
          raise "Permission denied" unless control.role.to_s == "Owner" || control.role.to_s == "Admin"

          Channel.update_channel(id, path, meta_data, instruction, status, name)
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

      def get_meta_by_channel(ctx)
        begin
          email = verify_token(ctx)
          project_id = get_param!(ctx, "project_id")
          id = get_param!(ctx, "id")

          project = Project.get_project!(project_id)
          control = Control.get_control!(email, project)
          raise "Permission denied" if control.role.to_s == "Viewer"

          meta = Channel.get_meta(project, id)
          meta.to_json
        rescue ex : InsufficientParameters
          error(ctx, "Not all required parameters were present")
        rescue e : Exception
          error(ctx, e.message.to_s)
        end
      end

      def upload_file_by_channel(ctx)
        begin
          email = verify_token(ctx)
          project_id = get_param!(ctx, "project_id")
          id = get_param!(ctx, "id")

          project = Project.get_project!(project_id)
          control = Control.get_control!(email, project)
          role = control.role.to_s
          raise "Permission denied" if role == "Viewer"
          raise "Permission denied" if (role == "Editor" && project.status != "Active")

          rel_path = Channel.upload_file(project, id, ctx)
          root = ENV["DMAC_ROOT"]
          full_path = File.join(root, project.path.to_s, rel_path)
          user = User.get_user_by_email!(email)
          Local.set_folder_file_owner(full_path, role, user.username.to_s)
          if role != "Owner"
            Local.set_file_owner_permission(full_path, project, role)
          end

          Git.commit(project, email + " uploaded " + rel_path + " by channel") if project.auto_history

          {"ok": true}.to_json
        rescue ex : InsufficientParameters
          error(ctx, "Not all required parameters were present")
        rescue e : Exception
          error(ctx, e.message.to_s)
        end
      end

      def upload_meta_by_channel(ctx)
        begin
          email = verify_token(ctx)
          project_id = get_param!(ctx, "project_id")
          id = get_param!(ctx, "id")
          meta_data = get_param!(ctx, "metaData")

          project = Project.get_project!(project_id)
          control = Control.get_control!(email, project)
          raise "Permission denied" if control.role.to_s == "Viewer"
          raise "Permission denied" if (control.role.to_s == "Editor" && project.status != "Active")

          rel_path = Channel.upload_meta(project, id, meta_data)
          Git.commit(project, email + " uploaded meta data in " + rel_path + " by channel") if project.auto_history

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
