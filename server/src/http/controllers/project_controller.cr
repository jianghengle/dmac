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
          
          project_ids = [] of Int32 | Int64 | Nil
          controls.each do |c|
            project_ids.push(c.project_id)
          end

          projects = Project.get_projects_by_ids(project_ids)
          owners = Control.get_owners_by_project_ids(project_ids)

          arr = [] of String
          projects.each do |k, v|
            fields = {} of String => String
            fields["owner"] = owners[k] if owners.has_key? k
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


      def get_folder(ctx)
        begin
          email = verify_token(ctx)
          project_id = get_param!(ctx, "project_id")
          path = get_param!(ctx, "path")


          project = Project.get_project!(project_id)
          control = Control.get_control!(email, project)
          files = MyFile.collect_files(project, path)
          
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


    end
  end
end
