require "./controller_base"

module DMACServer
  module HttpAPI
    module ProjectController
      include DMACServer::HttpAPI::ControllerBase
      extend self

      def get_projects(ctx)
        begin
          email = verify_token(ctx)
          controls = Control.get_controls_by_user(email)
          return "[]" if controls.size == 0
          project_ids = [] of Int32 | Int64 | Nil
          controls.each do |k, c|
            project_ids.push(c.project_id)
          end
          projects = Project.get_projects_by_ids(project_ids)

          arr = [] of String
          projects.each do |k, v|
            fields = {} of String => String
            fields["projectRole"] = controls[k].role.to_s if controls.has_key? k
            obj = v.to_json(fields)
            arr.push(obj)
          end
          json_array(arr)
        rescue ex : InsufficientParameters
          error(ctx, "Not all required parameters were present")
        rescue e : Exception
          error(ctx, e.message.to_s)
        end
      end


      def get_project(ctx)
        begin
          email = verify_token(ctx)
          project_id = get_param!(ctx, "project_id")

          project = Project.get_project!(project_id)
          control = Control.get_control!(email, project)
          owner = Control.get_project_owner(project)
          
          fields = {} of String => String
          fields["projectRole"] = control.role.to_s
          fields["owner"] = owner.email.to_s unless owner.nil?
          return project.to_json(fields)
        rescue ex : InsufficientParameters
          error(ctx, "Not all required parameters were present")
        rescue e : Exception
          error(ctx, e.message.to_s)
        end
      end


      def get_file(ctx)
        begin
          email = verify_token(ctx)
          project_id = get_param!(ctx, "project_id")
          data_path = get_param!(ctx, "data_path")

          project = Project.get_project!(project_id)
          control = Control.get_control!(email, project)
          files = MyFile.collect_files(control.role.to_s, project, data_path)

          paths = [] of String
          files.each do |f|
            paths << f.rel_path if f.type.to_s == "folder"
          end
          publics = Public.get_publics_by_paths(paths)

          arr = [] of String
          fields = {} of String => String
          fields["projectRole"] = control.role.to_s
          arr << project.to_json(fields)

          files.each_index do |i|
            f = files[i]
            read_text = i == 0 && f.fileType == "text"
            public_url = ""
            public_url = publics[f.rel_path] if publics.has_key? f.rel_path
            arr << f.to_json(read_text, public_url)
          end
          json_array(arr)
        rescue ex : InsufficientParameters
          error(ctx, "Not all required parameters were present")
        rescue e : Exception
          error(ctx, e.message.to_s)
        end
      end

      def create_project(ctx)
        begin
          email = verify_token(ctx)
          name = get_param!(ctx, "name")
          description = get_param!(ctx, "description")
          project = Project.create_project(name, description)
          Control.create_control(email, project, "Owner")
          MyFile.create_folder(project, "-root-")
          {"ok": true}.to_json
        rescue ex : InsufficientParameters
          error(ctx, "Not all required parameters were present")
        rescue e : Exception
          error(ctx, e.message.to_s)
        end
      end

      def update_project(ctx)
        begin
          email = verify_token(ctx)
          id = get_param!(ctx, "id")
          name = get_param!(ctx, "name")
          description = get_param!(ctx, "description")
          status = get_param!(ctx, "status")

          project = Project.get_project!(id)
          control = Control.get_control!(email, project)
          raise "Permission denied" if control.role.to_s == "Editor" || control.role.to_s == "Viewer"

          Project.update_project(project, name, description, status)
          {"ok": true}.to_json
        rescue ex : InsufficientParameters
          error(ctx, "Not all required parameters were present")
        rescue e : Exception
          error(ctx, e.message.to_s)
        end
      end

      def delete_project(ctx)
        begin
          email = verify_token(ctx)
          id = get_param!(ctx, "id")

          project = Project.get_project!(id)
          control = Control.get_control!(email, project)
          raise "Permission denied" if control.role.to_s == "Editor" || control.role.to_s == "Viewer"

          Control.delete_all_by_project(project)
          Project.delete_project(project)
          MyFile.delete_folder(project, "-root-")
          Public.delete_all_by_project(project)
          {"ok": true}.to_json
        rescue ex : InsufficientParameters
          error(ctx, "Not all required parameters were present")
        rescue e : Exception
          error(ctx, e.message.to_s)
        end
      end

      def create_folder(ctx)
        begin
          email = verify_token(ctx)
          project_id = get_param!(ctx, "projectId")
          data_path = get_param!(ctx, "dataPath")

          project = Project.get_project!(project_id)
          control = Control.get_control!(email, project)
          raise "Permission denied" if control.role.to_s == "Viewer"


          MyFile.create_folder(project, data_path)
          {"ok": true}.to_json
        rescue ex : InsufficientParameters
          error(ctx, "Not all required parameters were present")
        rescue e : Exception
          error(ctx, e.message.to_s)
        end
      end

      def create_file(ctx)
        begin
          email = verify_token(ctx)
          project_id = get_param!(ctx, "projectId")
          data_path = get_param!(ctx, "dataPath")

          project = Project.get_project!(project_id)
          control = Control.get_control!(email, project)
          raise "Permission denied" if control.role.to_s == "Viewer"


          MyFile.create_file(project, data_path)
          {"ok": true}.to_json
        rescue ex : InsufficientParameters
          error(ctx, "Not all required parameters were present")
        rescue e : Exception
          error(ctx, e.message.to_s)
        end
      end

      def update_folder_file_name(ctx)
        begin
          email = verify_token(ctx)
          project_id = get_param!(ctx, "projectId")
          data_path = get_param!(ctx, "dataPath")
          name = get_param!(ctx, "newName")

          project = Project.get_project!(project_id)
          control = Control.get_control!(email, project)
          raise "Permission denied" if control.role.to_s == "Viewer"

          MyFile.update_folder_file_name(project, data_path, name)
          {"ok": true}.to_json
        rescue ex : InsufficientParameters
          error(ctx, "Not all required parameters were present")
        rescue e : Exception
          error(ctx, e.message.to_s)
        end
      end

      def delete_folder_file(ctx)
        begin
          email = verify_token(ctx)
          project_id = get_param!(ctx, "projectId")
          data_path = get_param!(ctx, "dataPath")

          project = Project.get_project!(project_id)
          control = Control.get_control!(email, project)
          raise "Permission denied" if control.role.to_s == "Viewer"

          MyFile.delete_folder_file(project, data_path)
          {"ok": true}.to_json
        rescue ex : InsufficientParameters
          error(ctx, "Not all required parameters were present")
        rescue e : Exception
          error(ctx, e.message.to_s)
        end
      end

      def upload_file(ctx)
        begin
          email = verify_token(ctx)
          project_id = get_param!(ctx, "project_id")
          data_path = get_param!(ctx, "data_path")
          file = ctx.params.files["file"]

          project = Project.get_project!(project_id)
          control = Control.get_control!(email, project)
          raise "Permission denied" if control.role.to_s == "Viewer"

          MyFile.upload_file(project, data_path, file)
          {"ok": true}.to_json
        rescue ex : InsufficientParameters
          error(ctx, "Not all required parameters were present")
        rescue e : Exception
          error(ctx, e.message.to_s)
        end
      end

      def save_text_file(ctx)
        begin
          email = verify_token(ctx)
          project_id = get_param!(ctx, "projectId")
          data_path = get_param!(ctx, "dataPath")
          text = get_param!(ctx, "text")

          project = Project.get_project!(project_id)
          control = Control.get_control!(email, project)
          raise "Permission denied" if control.role.to_s == "Viewer"

          MyFile.save_text_file(project, data_path, text)
          {"ok": true}.to_json
        rescue ex : InsufficientParameters
          error(ctx, "Not all required parameters were present")
        rescue e : Exception
          error(ctx, e.message.to_s)
        end
      end

      def copy_folder_file(ctx)
        begin
          email = verify_token(ctx)
          source_project_id = get_param!(ctx, "sourceProjectId")
          source_data_paths = get_param!(ctx, "sourceDataPaths")
          target_project_id = get_param!(ctx, "targetProjectId")
          target_data_path = get_param!(ctx, "targetDataPath")

          source_project = Project.get_project!(source_project_id)
          source_control = Control.get_control!(email, source_project)
          target_project = Project.get_project!(target_project_id)
          target_control = Control.get_control!(email, target_project)
          raise "Permission denied" if target_control.role.to_s == "Viewer"

          source_files = [] of MyFile
          source_data_paths.split(",").each do |dp|
            f = MyFile.new(source_project, dp)
            if f.type == "file"
              source_files << f
            elsif target_control.role.to_s != "Editor"
              source_files << f
            end
          end
          target_file = MyFile.new(target_project, target_data_path)
          MyFile.copy_files(source_files, target_file)
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
