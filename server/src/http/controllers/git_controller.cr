require "./controller_base"

module DMACServer
  module HttpAPI
    module GitController
      include DMACServer::HttpAPI::ControllerBase
      extend self

      def get_logs(ctx)
        begin
          email = verify_token(ctx)
          project_id = get_param!(ctx, "project_id")

          project = Project.get_project!(project_id)
          control = Control.get_control!(email, project)
          raise "Permission denied" unless control.role.to_s == "Owner" || control.role.to_s == "Admin"

          commits = Git.get_logs(project)

          arr = [] of String
          commits.each do |c|
            obj = c.to_json
            arr.push(obj)
          end
          json_array(arr)
        rescue ex : InsufficientParameters
          error(ctx, "Not all required parameters were present")
        rescue e : Exception
          error(ctx, e.message.to_s)
        end
      end

      def get_commit(ctx)
        begin
          email = verify_token(ctx)
          project_id = get_param!(ctx, "project_id")
          hash = get_param!(ctx, "hash")

          project = Project.get_project!(project_id)
          control = Control.get_control!(email, project)
          raise "Permission denied" unless control.role.to_s == "Owner" || control.role.to_s == "Admin"

          Git.get_commit(project, hash)
        rescue ex : InsufficientParameters
          error(ctx, "Not all required parameters were present")
        rescue e : Exception
          error(ctx, e.message.to_s)
        end
      end

      def revert_commits(ctx)
        begin
          email = verify_token(ctx)
          project_id = get_param!(ctx, "projectId")
          hash = get_param!(ctx, "hash")

          project = Project.get_project!(project_id)
          control = Control.get_control!(email, project)
          raise "Permission denied" unless control.role.to_s == "Owner" || control.role.to_s == "Admin"

          Git.revert_commits(project, hash, email)
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
