module DMACServer
  module HttpAPI
    class Project < Crecto::Model
      schema "projects" do
        field :name, String
        field :description, String
        field :status, String
        field :key, String
      end

      def to_json(fields = {} of String => String)
        result = String.build do |str|
          str << "{"
          str << "\"id\":\"" << @id << "\","
          str << "\"name\":" << @name.to_json << ","
          str << "\"description\":" << @description.to_json << ","
          str << "\"status\":\"" << @status << "\","
          str << "\"key\":\"" << @key << "\","
          fields.each do |k, v|
            str << "\"" << k << "\":\"" << v << "\","
          end
          str << "\"createdTime\":" << @created_at.as(Time).epoch << ","
          str << "\"updatedTime\":" << @updated_at.as(Time).epoch
          str << "}"
        end
        result
      end


      def self.get_projects_by_ids(ids)
        query = Query.where(:id, ids)
        projects = Repo.all(Project, query)
        result = {} of String => Project
        return result if projects.nil?
        projects = projects.as(Array)
        projects.each do |p|
          result[p.id.to_s] = p
        end
        return result
      end


      def self.get_project!(id)
        project = Repo.get(Project, id)
        return project.as(Project) unless project.nil?
        raise "Cannot find project in database"
      end

    end

  end
end
