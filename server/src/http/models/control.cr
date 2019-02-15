module DMACServer
  module HttpAPI
    class Control < Crecto::Model
      schema "controls" do
        field :project_id, Int32
        field :email, String
        field :role, String
        field :group_name, String
        belongs_to :project, Project
      end

      def to_json
        result = String.build do |str|
          str << "{"
          str << "\"id\":" << @id << ","
          str << "\"projectId\":" << @project_id << ","
          str << "\"email\":" << @email.to_json << ","
          str << "\"role\":" << @role.to_json << ","
          str << "\"group\":" << @group_name.to_json << ","
          str << "\"createdTime\":" << @created_at.as(Time).to_unix << ","
          str << "\"updatedTime\":" << @updated_at.as(Time).to_unix
          str << "}"
        end
        result
      end

      def self.get_controls_by_user(email : String)
        query = Query.where(email: email)
        controls = Repo.all(Control, query)
        result = {} of String => Control
        return result if controls.nil?
        controls = controls.as(Array)
        controls.each do |c|
          result[c.project_id.to_s] = c
        end
        return result
      end

      def self.get_controls_by_project_id(project_id)
        query = Query.where(project_id: project_id)
        controls = Repo.all(Control, query)
        return [] of Control if controls.nil?
        return controls.as(Array)
      end

      def self.get_project_owner(project)
        return Repo.get_by(Control, project_id: project.id, role: "Owner")
      end

      def self.get_control(email, project)
        Repo.get_by(Control, email: email, project_id: project.id)
      end

      def self.get_control!(email, project)
        control = Repo.get_by(Control, email: email, project_id: project.id)
        return control.as(Control) unless control.nil?
        raise "Project permission denied"
      end

      def self.get_control_by_id!(id)
        control = Repo.get(Control, id)
        raise "Cannot find control" if control.nil?
        control.as(Control)
      end

      def self.get_username_role_map(project)
        controls = Control.get_controls_by_project_id(project.id)
        emails = controls.map { |c| c.email.to_s }
        email_user_map = User.get_email_user_map(emails)
        result = {} of String => String
        controls.each do |c|
          if email_user_map.has_key? c.email.to_s
            user = email_user_map[c.email.to_s]
            result[user.username.to_s] = c.role.to_s
          end
        end
        result
      end

      def self.create_control(email, project, role, group)
        control = Control.new
        control.project_id = project.id
        control.email = email
        control.role = role
        control.group_name = group
        changeset = Repo.insert(control)
        raise changeset.errors.to_s unless changeset.valid?
        changeset.changes.each do |change|
          if (change.has_key?(:id))
            control.id = change[:id].as(Int32)
          end
        end
        return control
      end

      def self.delete_all_by_project(project)
        query = Query.where(project_id: project.id)
        Repo.delete_all(Control, query)
      end

      def self.update_control(project, id, email, role, group)
        control = Repo.get(Control, id)
        raise "Cannot find control" if control.nil?
        control = control.as(Control)
        control.email = email
        control.role = role
        control.group_name = group
        changeset = Repo.update(control)
        raise changeset.errors.to_s unless changeset.valid?
        return control
      end

      def self.delete_control(project, id)
        control = Repo.get(Control, id)
        raise "Cannot find control" if control.nil?
        control = control.as(Control)
        changeset = Repo.delete(control)
        raise changeset.errors.to_s unless changeset.valid?
        return control
      end

      def self.copy_controls(source, target, email)
        controls = Control.get_controls_by_project_id(source.id)
        controls.each do |c|
          next if c.email.to_s == email
          role = c.role.to_s
          role = "Admin" if role == "Owner"
          Control.create_control(c.email.to_s, target, role, c.group_name.to_s)
        end
      end
    end
  end
end
