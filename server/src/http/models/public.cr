module DMACServer
  module HttpAPI
    class Public < Crecto::Model
      schema "publics" do
        field :project_id, Int32
        field :data_path, String
        field :key, String
        field :path, String
        belongs_to :project, Project
      end

      def to_json
        result = String.build do |str|
          str << "{"
          str << "\"id\":" << @id << ","
          str << "\"projectId\":" << @project_id << ","
          str << "\"dataPath\":" << @data_path.to_json << ","
          str << "\"key\":" << @key.to_json << ","
          str << "\"createdTime\":" << @created_at.as(Time).epoch << ","
          str << "\"updatedTime\":" << @updated_at.as(Time).epoch
          str << "}"
        end
        result
      end

      def self.get_public_by_project_path(project, data_path)
        path = project.path.to_s + data_path
        return Repo.get_by(Public, path: path)
      end

      def self.create_public(project, data_path)
        public = Public.new
        public.project_id = project.id
        public.data_path = data_path
        public.path = project.path.to_s
        public.path = public.path.to_s + data_path
        public.key = SecureRandom.uuid.to_s
        changeset = Repo.insert(public)
        raise changeset.errors.to_s unless changeset.valid?
        return public
      end

      def self.delete_all_by_project(project)
        query = Query.where(project_id: project.id)
        Repo.delete_all(Public, query)
      end

      def self.get_publics_by_paths(paths)
        result = {} of String => String
        return result if paths.size == 0
        query = Query.where(:path, paths)
        publics = Repo.all(Public, query)
        return result if publics.nil?
        publics = publics.as(Array)
        publics.each do |p|
          dp = URI.escape(p.data_path.to_s)
          result[p.path.to_s] = "/#/public/" + p.key.to_s + "/data/" + dp
        end
        return result
      end

      def self.get_public!(public_key)
        public = Repo.get_by(Public, key: public_key)
        return public.as(Public) unless public.nil?
        raise "Cannot find public key"
      end

      def self.delete_public(public_key)
        public = Repo.get_by(Public, key: public_key)
        Repo.delete(public) unless public.nil?
      end

      def self.get_publics_by_project(project)
        query = Query.where(project_id: project.id)
        publics = Repo.all(Public, query)
        return publics.as(Array) unless publics.nil?
        return [] of Public
      end

      def self.copy_publics(template, project)
        query = Query.where(project_id: template.id)
        publics = Repo.all(Public, query)
        publics.as(Array) unless publics.nil?
        publics.each do |p|
          public = Public.new
          public.project_id = project.id
          public.data_path = p.data_path
          public.key = SecureRandom.uuid.to_s
          public.path = project.path.to_s + p.data_path.to_s
          changeset = Repo.insert(public)
          raise changeset.errors.to_s unless changeset.valid?
        end
      end
    end
  end
end
