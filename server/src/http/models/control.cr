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

      def to_json()
        result = String.build do |str|
          str << "{"
          str << "\"id\":" << @id << ","
          str << "\"projectId\":" << @project_id << ","
          str << "\"email\":" << @email.to_json << ","
          str << "\"role\":" << @role.to_json << ","
          str << "\"group\":" << @group_name.to_json << ","
          str << "\"createdTime\":" << @created_at.as(Time).epoch << ","
          str << "\"updatedTime\":" << @updated_at.as(Time).epoch
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

      def self.get_control!(email, project)
        control = Repo.get_by(Control, email: email, project_id: project.id)
        return control.as(Control) unless control.nil?
        raise "Project permission denied"
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
          if(change.has_key?(:id))
            control.id = change[:id].as(Int32)
          end
        end
        return control
      end

      def self.delete_all_by_project(project)
        query = Query.where(project_id: project.id)
        Repo.delete_all(Control, query)
      end

      def self.update_control(id, email, role, group)
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

      def self.delete_control(id)
        control = Repo.get(Control, id)
        raise "Cannot find control" if control.nil?
        control = control.as(Control)
        changeset = Repo.delete(control)
        raise changeset.errors.to_s unless changeset.valid?
      end

    end
  end
end
