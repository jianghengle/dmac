require "./controller_base"

module DMACServer
  module HttpAPI
    module ControlController
      include DMACServer::HttpAPI::ControllerBase
      extend self

      def get_project_controls(ctx)
        begin
          email = verify_token(ctx)
          project_id = get_param!(ctx, "project_id")

          controls = Control.get_controls_by_project_id(project_id)
          return "[]" if controls.size == 0

          arr = [] of String
          controls.each do |c|
            obj = c.to_json
            if c.email == email
              raise "Permission denied" unless c.role.to_s == "Owner" || c.role.to_s == "Admin"
            end
            arr.push(obj)
          end
          json_array(arr)
        rescue ex : InsufficientParameters
          error(ctx, "Not all required parameters were present")
        rescue e : Exception
          error(ctx, e.message.to_s)
        end
      end

      def add_project_control(ctx)
        begin
          email = verify_token(ctx)
          project_id = get_param!(ctx, "projectId")
          newEmail = get_param!(ctx, "email")
          newRole = get_param!(ctx, "role")
          newGroup = get_param!(ctx, "group")

          project = Project.get_project!(project_id)
          control = Control.get_control!(email, project)
          raise "Permission denied" unless control.role.to_s == "Owner" || control.role.to_s == "Admin"

          new_control = Control.create_control(newEmail, project, newRole, newGroup)
          new_control.to_json
        rescue ex : InsufficientParameters
          error(ctx, "Not all required parameters were present")
        rescue e : Exception
          error(ctx, e.message.to_s)
        end
      end

      def update_project_control(ctx)
        begin
          email = verify_token(ctx)
          project_id = get_param!(ctx, "projectId")
          id = get_param!(ctx, "id")
          newEmail = get_param!(ctx, "email")
          newRole = get_param!(ctx, "role")
          newGroup = get_param!(ctx, "group")

          project = Project.get_project!(project_id)
          control = Control.get_control!(email, project)
          raise "Permission denied" unless control.role.to_s == "Owner" || control.role.to_s == "Admin"
          new_control = Control.update_control(id, newEmail, newRole, newGroup)
          new_control.to_json
        rescue ex : InsufficientParameters
          error(ctx, "Not all required parameters were present")
        rescue e : Exception
          error(ctx, e.message.to_s)
        end
      end

      def delete_project_control(ctx)
        begin
          email = verify_token(ctx)
          project_id = get_param!(ctx, "projectId")
          id = get_param!(ctx, "id")

          project = Project.get_project!(project_id)
          control = Control.get_control!(email, project)
          raise "Permission denied" unless control.role.to_s == "Owner" || control.role.to_s == "Admin"

          Control.delete_control(id)
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
