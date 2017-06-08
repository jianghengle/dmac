module DMACServer
  module HttpAPI
    class Control < Crecto::Model
      schema "controls" do
        field :project_id, Int32
        field :email, String
        field :role, String
        belongs_to :project, Project
      end

      def self.get_controls_by_user(email : String)
        query = Query.where(email: email)
        controls = Repo.all(Control, query)
        return controls.as(Array) unless controls.nil?
        return [] of Control
      end

      def self.get_owners_by_project_ids(ids)
        query = Query.where(:project_id, ids).where(:role, "owner")
        controls = Repo.all(Control, query)
        result = {} of String => String
        return result if controls.nil?
        controls = controls.as(Array)
        controls.each do |c|
          result[c.project_id.to_s] = c.email.to_s
        end
        return result
      end

      def self.get_control!(email, project)
        control = Repo.get_by(Control, email: email, project_id: project.id)
        return control.as(Control) unless control.nil?
        raise "Project permission denied"
      end

    end
  end
end
