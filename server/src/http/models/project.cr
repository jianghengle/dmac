module DMACServer
  module HttpAPI
    class Project < Crecto::Model
      schema "projects" do
        field :name, String
        field :description, String
        field :status, String
        field :auto_history, Bool
        field :key, String
        field :path, String
      end

      def to_json(fields = {} of String => String)
        result = String.build do |str|
          str << "{"
          str << "\"id\":\"" << @id << "\","
          str << "\"name\":" << @name.to_json << ","
          str << "\"description\":" << @description.to_json << ","
          str << "\"status\":\"" << @status << "\","
          str << "\"projectSize\":\"" << project_size << "\","
          str << "\"autoHistory\":" << @auto_history.to_json << ","
          str << "\"key\":\"" << @key << "\","
          str << "\"path\":\"" << @path << "\","
          fields.each do |k, v|
            str << "\"" << k << "\":\"" << v << "\","
          end
          str << "\"createdTime\":" << @created_at.as(Time).to_unix << ","
          str << "\"updatedTime\":" << @updated_at.as(Time).to_unix
          str << "}"
        end
        result
      end

      def project_size
        root = ENV["DMAC_ROOT"]
        project_root = File.join(root, @path.to_s)
        Local.get_folder_size(project_root)
      end

      def access_as_template(control)
        return "" unless (@status == "Template" || @status == "Public Template")
        if @status == "Public Template"
          return "public" if control.nil?
          control = control.as(Control)
          role = control.role.to_s
          return "member" if role == "Owner" || role == "Admin"
        end
        return "" if control.nil?
        control = control.as(Control)
        role = control.role.to_s
        return "member" if role == "Owner" || role == "Admin"
        return ""
      end

      def self.get_all_projects
        projects = Repo.all(Project)
        result = [] of Project
        return result if projects.nil?
        projects.as(Array)
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

      def self.get_public_templates
        query = Query.where(status: "Public Template")
        projects = Repo.all(Project, query)
        return [] of Project if projects.nil?
        return projects.as(Array)
      end

      def self.get_project!(id)
        project = Repo.get(Project, id)
        return project.as(Project) unless project.nil?
        raise "Cannot find project in database"
      end

      def self.get_meta(project, data_path)
        root = ENV["DMAC_ROOT"]
        project_root = root + "/" + project.path.to_s
        full_path = project_root + data_path + "/meta.txt"
        raise "cannot find meta data file" unless File.file? full_path

        lines = File.read_lines(full_path)
        return lines[0..1].to_json
      end

      def self.get_project_by_key!(key)
        project = Repo.get_by(Project, key: key)
        return project.as(Project) unless project.nil?
        raise "Cannot find project in database"
      end

      def self.create_project(name, description, user)
        project = Project.new
        project.name = name
        project.description = description
        project.status = "Active"
        project.auto_history = false
        changeset = Repo.insert(project)
        raise changeset.errors.to_s unless changeset.valid?
        changeset.changes.each do |change|
          if (change.has_key?(:id))
            project.id = change[:id].as(Int32)
            project.key = change[:id].to_s
            project.path = user.username.to_s + "/" + project.name.to_s
          end
        end
        changeset = Repo.update(project)
        raise changeset.errors.to_s unless changeset.valid?
        return project
      end

      def self.update_project(project, name, description, status, auto_history, meta_data_file, meta_data)
        if project.name.to_s != name
          root = ENV["DMAC_ROOT"]
          old_path = project.path.to_s
          new_path = old_path.rchop(project.name.to_s) + name
          old_full_path = root + "/" + old_path
          new_full_path = root + "/" + new_path
          File.rename(old_full_path, new_full_path)
          project.path = new_path
        end
        project.name = name
        project.description = description
        project.status = status
        project.auto_history = auto_history == "true"
        changeset = Repo.update(project)
        raise changeset.errors.to_s unless changeset.valid?
        unless meta_data_file.empty?
          root = ENV["DMAC_ROOT"]
          project_root = root + "/" + project.path.to_s
          full_path = project_root + "/" + meta_data_file
          raise "cannot find meta data file" unless File.file? full_path

          lines = File.read_lines(full_path)
          result = String.build do |str|
            str << lines[0] << "\n" unless lines.empty?
            str << meta_data << "\n"
          end
          File.write(full_path, result)
        end
        return project
      end

      def self.update_meta_data(project, meta_data)
        root = ENV["DMAC_ROOT"]
        project_root = root + "/" + project.path.to_s
        full_path = project_root + "/meta.txt"
        return unless File.file? full_path

        lines = File.read_lines(full_path)
        result = String.build do |str|
          str << lines[0] << "\n" unless lines.empty?
          str << meta_data << "\n"
        end
        File.write(full_path, result)
      end

      def self.delete_project(project)
        changeset = Repo.delete(project)
        raise changeset.errors.to_s unless changeset.valid?
      end
    end
  end
end
