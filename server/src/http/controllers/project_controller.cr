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
          root = project_root(project)
          files = collect_files(root)
          puts files.to_s
          
        rescue ex : InsufficientParameters
          error(ctx, "Not all required parameters were present")
        rescue e : Exception
          error(ctx, e.message.to_s)
        end
      end



      private def project_root(project)
        raise "No root setup" unless ENV.has_key?("DMAC_ROOT")
        root = ENV["DMAC_ROOT"]
        root = root + "/" + project.key.to_s
        raise "No such path" unless File.exists? root
        return root
      end

      private def collect_files(path)
        files = [] of String
        files.push(path)
        if File.directory? path
          Dir.foreach path do |filename|
            if filename.to_s != "." && filename.to_s != ".."
              files.push(path + "/" + filename)
            end
          end
        end
        return files
      end


    end
  end
end
