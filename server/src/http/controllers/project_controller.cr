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
          owners = Control.get_owners_by_project_ids(project_ids)
          arr = [] of String
          projects.each do |k, v|
            fields = {} of String => String
            fields["owner"] = owners[k] if owners.has_key? k
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
          files = MyFile.collect_files(project)
          
          arr = [] of String
          arr << project.to_json
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


      def get_file(ctx)
        begin
          email = verify_token(ctx)
          project_id = get_param!(ctx, "project_id")
          data_path = get_param!(ctx, "data_path")


          project = Project.get_project!(project_id)
          control = Control.get_control!(email, project)
          files = MyFile.collect_files(project, data_path)
          
          arr = [] of String
          arr << project.to_json
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

      def create_project(ctx)
        begin
          email = verify_token(ctx)
          name = get_param!(ctx, "name")
          description = get_param!(ctx, "description")
          project = Project.create_project(name, description)
          Control.create_control(email, project, "Owner")
          MyFile.create_folder(project, "/")
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
          MyFile.delete_folder(project, "/")
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
