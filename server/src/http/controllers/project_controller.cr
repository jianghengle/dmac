require "./controller_base"

module DMACServer
  module HttpAPI
    module ProjectController
      include DMACServer::HttpAPI::ControllerBase
      extend self

      def get_projects(ctx)
        begin
          email = verify_token(ctx)
          user = User.get_user_by_email!(email)
          if user.role.to_s == "Admin"
            projects = Project.get_all_projects

            return "[\"Admin\", " + (projects.join(", ") { |i| i.to_json }) + "]"
          end

          controls = Control.get_controls_by_user(email)
          arr = [] of String
          arr.push(user.role.to_s.to_json)
          if controls.size > 0
            project_ids = [] of Int8 | Int16 | Int32 | Int64 | String | Nil
            controls.each do |k, c|
              project_ids.push(c.project_id)
            end
            projects = Project.get_projects_by_ids(project_ids)

            projects.each do |k, v|
              fields = {} of String => String
              control = controls[k] if controls.has_key? k
              control = control.as(Control)
              role = control.role.to_s
              next unless role == "Owner" || role == "Admin" || v.status == "Active"
              fields["projectRole"] = control.role.to_s
              obj = v.to_json(fields)
              arr.push(obj)
            end
          end
          json_array(arr)
        rescue ex : InsufficientParameters
          error(ctx, "Not all required parameters were present")
        rescue e : Exception
          error(ctx, e.message.to_s)
        end
      end

      def get_public_templates(ctx)
        begin
          email = verify_token(ctx)
          arr = [] of String
          projects = Project.get_public_templates
          projects.each do |p|
            obj = p.to_json
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
          role = control.role.to_s
          raise "Permission denied" unless role == "Owner" || role == "Admin" || project.status == "Active"

          fields = {} of String => String
          fields["projectUser"] = control.email.to_s
          fields["projectRole"] = control.role.to_s
          fields["projectGroup"] = control.group_name.to_s
          owner = Control.get_project_owner(project)
          unless owner.nil?
            owner = owner.as(Control)
            user = User.get_user_by_email(owner.email.to_s)
            if user.nil?
              fields["owner"] = owner.email.to_s
            else
              user = user.as(User)
              fields["owner"] = user.username.to_s + " <" + owner.email.to_s + ">"
            end
          end
          project.to_json(fields)
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
          data_path = URI.unescape(data_path)

          project = Project.get_project!(project_id)
          control = Control.get_control!(email, project)
          role = control.role.to_s
          raise "Permission denied" unless role == "Owner" || role == "Admin" || project.status == "Active"

          files = MyFile.collect_files(control, project, data_path)

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
            read_text = i == 0 && (f.file_type == "text" || f.file_type == "code" || f.file_type == "csv")
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
          user = User.get_user_by_email!(email)
          raise "Permission denied" if user.role.to_s == "Subscriber"

          name = get_param!(ctx, "name")
          description = get_param!(ctx, "description")
          template_id = get_param!(ctx, "templateId")
          meta_data = get_param!(ctx, "metaData")
          copy_users = get_param!(ctx, "copyUsers")

          MyFile.create_project_folder!(user, name)
          project = Project.create_project(name, description, user)
          Local.init_project(project)
          Control.create_control(email, project, "Owner", "")
          if template_id != ""
            template = Project.get_project!(template_id)
            templateControl = Control.get_control(email, template)
            template_role = template.access_as_template(templateControl)
            unless template_role.empty?
              MyFile.copy_project_files(template, project)
              Channel.copy_channels(template, project)
              Public.copy_publics(template, project)
              if copy_users == "true" && template_role == "member"
                Control.copy_controls(template, project, email)
              end
              Project.update_meta_data(project, meta_data)
            end
          end
          Local.init_project_controls(project)
          Git.init(project, email)
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
          auto_history = get_param!(ctx, "autoHistory")
          meta_data_file = get_param!(ctx, "metaDataFile")
          meta_data = get_param!(ctx, "metaData")

          project = Project.get_project!(id)
          control = Control.get_control!(email, project)
          role = control.role.to_s
          raise "Permission denied" unless role == "Owner" || role == "Admin"
          if project.status.to_s != status
            Local.change_project_status(project, status)
          end
          Project.update_project(project, name, description, status, auto_history, meta_data_file, meta_data)
          Git.commit(project, email + " update project") if (project.auto_history && meta_data_file != "")
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
          raise "Permission denied" unless control.role.to_s == "Owner"

          Control.delete_all_by_project(project)
          MyFile.mark_project_folder_deleted(project)
          Public.delete_all_by_project(project)
          Channel.delete_all_by_project(project)
          Project.delete_project(project)
          Local.delete_project(project)
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
          permission = get_param!(ctx, "permission")
          copy_from_data_path = get_param!(ctx, "copyFromDataPath")
          meta_data = get_param!(ctx, "metaData")

          project = Project.get_project!(project_id)
          control = Control.get_control!(email, project)
          role = control.role.to_s
          raise "Permission denied" unless role == "Owner" || role == "Admin"

          full_path = MyFile.create_folder(project, data_path)
          Local.set_file_permission(project, full_path, permission) if permission != "Normal"
          unless copy_from_data_path == ""
            MyFile.copy_directory_files(project, copy_from_data_path, data_path, meta_data)
            Channel.copy_directory_channels(project, copy_from_data_path, data_path)
          end
          Git.commit(project, email + " created folder " + data_path) if project.auto_history
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
          permission = get_param!(ctx, "permission")
          copy_from_data_path = get_param!(ctx, "copyFromDataPath")

          content = get_param(ctx, "content")
          content = "" if content.nil?

          project = Project.get_project!(project_id)
          control = Control.get_control!(email, project)
          role = control.role.to_s
          raise "Permission denied" if role == "Viewer"
          raise "Permission denied" unless role == "Owner" || role == "Admin" || project.status == "Active"

          full_path = MyFile.create_file(project, data_path, control, content, copy_from_data_path)
          Local.set_file_permission(project, full_path, permission) if permission != "Normal"
          Git.commit(project, email + " created file " + data_path) if project.auto_history
          {"ok": true}.to_json
        rescue ex : InsufficientParameters
          error(ctx, "Not all required parameters were present")
        rescue e : Exception
          error(ctx, e.message.to_s)
        end
      end

      def update_folder(ctx)
        begin
          email = verify_token(ctx)
          project_id = get_param!(ctx, "projectId")
          data_path = get_param!(ctx, "dataPath")
          name = get_param!(ctx, "newName")
          old_permission = get_param!(ctx, "oldPermission")
          new_permission = get_param!(ctx, "newPermission")
          meta_data_file = get_param!(ctx, "metaDataFile")
          meta_data = get_param!(ctx, "metaData")

          project = Project.get_project!(project_id)
          control = Control.get_control!(email, project)
          role = control.role.to_s
          raise "Permission denied" if role == "Viewer"
          raise "Permission denied" unless role == "Owner" || role == "Admin" || project.status == "Active"

          new_full_path = MyFile.update_folder_file_name(project, data_path, name, control)
          Local.set_file_permission(project, new_full_path, new_permission) if old_permission != new_permission

          unless meta_data_file.empty?
            meta_full_path = new_full_path + "/" + meta_data_file
            raise "cannot find meta data file" unless File.file? meta_full_path
            lines = File.read_lines(meta_full_path)
            result = String.build do |str|
              str << lines[0] << "\n" unless lines.empty?
              str << meta_data << "\n"
            end
            File.write(meta_full_path, result)
          end

          Git.commit(project, email + " updated " + data_path) if project.auto_history

          {"ok": true}.to_json
        rescue ex : InsufficientParameters
          error(ctx, "Not all required parameters were present")
        rescue e : Exception
          error(ctx, e.message.to_s)
        end
      end

      def update_file(ctx)
        begin
          email = verify_token(ctx)
          project_id = get_param!(ctx, "projectId")
          data_path = get_param!(ctx, "dataPath")
          name = get_param!(ctx, "newName")
          old_permission = get_param!(ctx, "oldPermission")
          new_permission = get_param!(ctx, "newPermission")

          project = Project.get_project!(project_id)
          control = Control.get_control!(email, project)
          role = control.role.to_s
          raise "Permission denied" if role == "Viewer"
          raise "Permission denied" unless role == "Owner" || role == "Admin" || project.status == "Active"

          new_full_path = MyFile.update_folder_file_name(project, data_path, name, control)
          Local.set_file_permission(project, new_full_path, new_permission) if old_permission != new_permission

          rel_path = data_path
          Git.commit(project, email + " renamed " + rel_path + " to " + name) if project.auto_history

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
          role = control.role.to_s
          raise "Permission denied" if role == "Viewer"
          raise "Permission denied" unless role == "Owner" || role == "Admin" || project.status == "Active"

          MyFile.delete_folder_file(project, data_path, control)

          rel_path = data_path
          Git.commit(project, email + " deleted " + rel_path) if project.auto_history

          {"ok": true}.to_json
        rescue ex : InsufficientParameters
          error(ctx, "Not all required parameters were present")
        rescue e : Exception
          error(ctx, e.message.to_s)
        end
      end

      def delete_multiple(ctx)
        begin
          email = verify_token(ctx)
          project_id = get_param!(ctx, "projectId")
          data_paths = get_param!(ctx, "dataPaths")

          project = Project.get_project!(project_id)
          control = Control.get_control!(email, project)
          role = control.role.to_s
          raise "Permission denied" unless role == "Owner" || role == "Admin"

          data_paths.split(",") do |dp|
            MyFile.delete_folder_file(project, dp, control)
          end

          Git.commit(project, email + " deleted multiple items") if project.auto_history
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
          data_path = URI.unescape(data_path)

          project = Project.get_project!(project_id)
          control = Control.get_control!(email, project)
          role = control.role.to_s
          raise "Permission denied" if role == "Viewer"
          raise "Permission denied" unless role == "Owner" || role == "Admin" || project.status == "Active"

          rel_path = MyFile.upload_file(project, data_path, ctx, control)
          Git.commit(project, email + " uploaded " + rel_path) if project.auto_history

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
          role = control.role.to_s
          raise "Permission denied" if role == "Viewer"
          raise "Permission denied" unless role == "Owner" || role == "Admin" || project.status == "Active"

          MyFile.save_text_file(project, data_path, text, control)

          rel_path = data_path
          Git.commit(project, email + " save file " + rel_path) if project.auto_history

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
          source_role = source_control.role.to_s
          target_project = Project.get_project!(target_project_id)
          target_control = Control.get_control!(email, target_project)
          target_role = target_control.role.to_s

          raise "Permission denied" unless source_role == "Owner" || source_role == "Admin" || source_project.status == "Active"
          source_files = [] of MyFile
          source_data_paths.split(",") do |dp|
            f = MyFile.new(source_project, dp)
            if source_role == "Owner" || source_role == "Admin"
              source_files << f
            elsif f.access != 2
              source_files << f
            end
          end

          raise "Permission denied" if target_role == "Viewer"
          raise "Permission denied" unless target_role == "Owner" || target_role == "Admin" || target_project.status == "Active"
          target_path = MyFile.new(target_project, target_data_path)
          raise "Target is not a folder" unless target_path.type == "folder"

          MyFile.copy_files(source_files, target_path, target_control)

          rel_path = target_data_path
          Git.commit(target_project, email + " copy something into " + rel_path) if target_project.auto_history

          {"ok": true}.to_json
        rescue ex : InsufficientParameters
          error(ctx, "Not all required parameters were present")
        rescue e : Exception
          error(ctx, e.message.to_s)
        end
      end

      def unzip_file(ctx)
        begin
          email = verify_token(ctx)
          project_id = get_param!(ctx, "projectId")
          data_path = get_param!(ctx, "dataPath")

          project = Project.get_project!(project_id)
          control = Control.get_control!(email, project)
          raise "Permission denied" unless control.role.to_s == "Owner" || control.role.to_s == "Admin"

          MyFile.unzip_file(project, data_path)

          rel_path = data_path
          Git.commit(project, email + " extract " + rel_path) if project.auto_history

          {"ok": true}.to_json
        rescue ex : InsufficientParameters
          error(ctx, "Not all required parameters were present")
        rescue e : Exception
          error(ctx, e.message.to_s)
        end
      end

      def get_meta_by_data_path(ctx)
        begin
          email = verify_token(ctx)
          project_id = get_param!(ctx, "project_id")
          data_path = get_param!(ctx, "data_path")
          data_path = URI.unescape(data_path)

          project = Project.get_project!(project_id)
          control = Control.get_control!(email, project)
          raise "Permission denied" unless control.role.to_s == "Owner" || control.role.to_s == "Admin"

          Project.get_meta(project, data_path)
        rescue ex : InsufficientParameters
          error(ctx, "Not all required parameters were present")
        rescue e : Exception
          error(ctx, e.message.to_s)
        end
      end

      def get_meta_by_template(ctx)
        begin
          email = verify_token(ctx)
          project_id = get_param!(ctx, "project_id")

          project = Project.get_project!(project_id)
          control = Control.get_control(email, project)
          raise "Permission denied" if project.access_as_template(control).empty?

          Project.get_meta(project, "")
        rescue ex : InsufficientParameters
          error(ctx, "Not all required parameters were present")
        rescue e : Exception
          error(ctx, e.message.to_s)
        end
      end

      def search_files(ctx)
        begin
          email = verify_token(ctx)
          project_id = get_param!(ctx, "projectId")
          data_path = get_param!(ctx, "dataPath")
          pattern = get_param!(ctx, "pattern")

          project = Project.get_project!(project_id)
          control = Control.get_control!(email, project)
          role = control.role.to_s
          raise "Permission denied" unless role == "Owner" || role == "Admin" || project.status == "Active"

          files = MyFile.search_files(control, project, data_path, pattern)

          arr = [] of String
          files.each do |f|
            arr << f.to_json
          end
          json_array(arr)
        rescue ex : InsufficientParameters
          error(ctx, "Not all required parameters were present")
        rescue e : Exception
          error(ctx, e.message.to_s)
        end
      end

      def search_in_file(ctx)
        begin
          email = verify_token(ctx)
          project_id = get_param!(ctx, "projectId")
          data_path = get_param!(ctx, "dataPath")
          pattern = get_param!(ctx, "pattern")

          project = Project.get_project!(project_id)
          control = Control.get_control!(email, project)
          role = control.role.to_s
          raise "Permission denied" unless role == "Owner" || role == "Admin" || project.status == "Active"

          lines = MyFile.search_in_file(control, project, data_path, pattern)
          lines.to_json
        rescue ex : InsufficientParameters
          error(ctx, "Not all required parameters were present")
        rescue e : Exception
          error(ctx, e.message.to_s)
        end
      end
    end
  end
end
