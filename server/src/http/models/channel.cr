module DMACServer
  module HttpAPI
    class Channel < Crecto::Model
      raise "No root setup" unless ENV.has_key?("DMAC_ROOT")
      @@root = ENV["DMAC_ROOT"]

      schema "channels" do
        field :project_id, Int32
        field :name, String
        field :path, String
        field :meta_data, String
        field :instruction, String
        field :files, Int32
        field :rename, Bool
        field :status, String
        belongs_to :project, Project
      end

      def to_json
        result = String.build do |str|
          str << "{"
          str << "\"id\":" << @id << ","
          str << "\"projectId\":" << @project_id << ","
          str << "\"name\":" << @name.to_json << ","
          str << "\"path\":" << @path.to_json << ","
          str << "\"metaData\":" << @meta_data.to_json << ","
          str << "\"instruction\":" << @instruction.to_json << ","
          str << "\"files\":" << @files << ","
          str << "\"rename\":" << @rename.to_s << ","
          str << "\"status\":" << @status.to_json
          str << "}"
        end
        result
      end

      def self.get_channels_by_project(project)
        query = Query.where(project_id: project.id)
        channels = Repo.all(Channel, query)
        return channels.as(Array) unless channels.nil?
        return [] of Channel
      end

      def self.get_directories_by_project(project)
        raise "No root setup" unless ENV.has_key?("DMAC_ROOT")
        root = ENV["DMAC_ROOT"]
        project_root = root + "/" + project.path.to_s
        directories = Channel.get_directories(project_root, project_root)
        return directories
      end

      def self.get_directories(path, project_root)
        directories = [] of String
        Dir.each_entry path do |filename|
          if filename.to_s != "." && filename.to_s != ".." && filename.to_s != ".git" && filename.to_s != "__MACOSX"
            full_path = path + "/" + filename
            if File.directory? full_path
              size = project_root.size
              directories << full_path[size..-1]
              ds = Channel.get_directories(full_path, project_root)
              directories.concat(ds)
            end
          end
        end
        return directories
      end

      def self.get_files_by_path(project, path)
        raise "No root setup" unless ENV.has_key?("DMAC_ROOT")
        root = ENV["DMAC_ROOT"]
        project_root = root + "/" + project.path.to_s
        full_path = project_root + path
        files = [] of String
        Dir.each_entry full_path do |filename|
          if filename.to_s != "." && filename.to_s != ".." && filename.to_s != ".gitignore" && filename.to_s != ".DS_Store"
            file_path = full_path + "/" + filename
            if File.file? file_path
              files << filename
            end
          end
        end
        return files
      end

      def self.create_channel(project, path, meta_data, instruction, rename, files, status, name)
        channel = Channel.new
        channel.project_id = project.id
        channel.path = path
        channel.meta_data = meta_data
        channel.instruction = instruction
        channel.files = files.to_i
        channel.rename = rename == "true"
        channel.status = status
        channel.name = name
        changeset = Repo.insert(channel)
        raise changeset.errors.to_s unless changeset.valid?
      end

      def self.update_channel(id, path, meta_data, instruction, rename, files, status, name)
        channel = Repo.get(Channel, id)
        raise "Cannot find channel" if channel.nil?
        channel = channel.as(Channel)
        channel.path = path
        channel.meta_data = meta_data
        channel.instruction = instruction
        channel.rename = rename == "true"
        channel.files = files.to_i
        channel.status = status
        channel.name = name
        changeset = Repo.update(channel)
        raise changeset.errors.to_s unless changeset.valid?
        return channel
      end

      def self.delete_channel(id)
        channel = Repo.get_by(Channel, id: id)
        Repo.delete(channel) unless channel.nil?
      end

      def self.delete_all_by_project(project)
        query = Query.where(project_id: project.id)
        Repo.delete_all(Channel, query)
      end

      def self.copy_channels(template, project)
        query = Query.where(project_id: template.id)
        channels = Repo.all(Channel, query)
        channels.as(Array) unless channels.nil?
        channels.each do |c|
          channel = Channel.new
          channel.project_id = project.id
          channel.path = c.path
          channel.meta_data = c.meta_data
          channel.instruction = c.instruction
          channel.rename = c.rename
          channel.files = c.files
          channel.status = c.status
          channel.name = c.name
          changeset = Repo.insert(channel)
          raise changeset.errors.to_s unless changeset.valid?
        end
      end

      def self.copy_directory_channels(project, source_data_path, target_data_path)
        query = Query.where(project_id: project.id)
        channels = Repo.all(Channel, query)
        channels = channels.as(Array) unless channels.nil?
        channels.each do |c|
          path = c.path.to_s
          if path.starts_with?(source_data_path)
            channel = Channel.new
            channel.project_id = project.id
            channel.path = path.sub(source_data_path, target_data_path)
            channel.meta_data = c.meta_data
            channel.instruction = c.instruction
            channel.rename = c.rename
            channel.files = c.files
            channel.status = "Open"
            channel.name = c.name
            changeset = Repo.insert(channel)
            raise changeset.errors.to_s unless changeset.valid?
          end
        end
      end

      def self.delete_all_by_directory(project, data_path)
        query = Query.where(project_id: project.id)
        channels = Repo.all(Channel, query)
        channels = channels.as(Array) unless channels.nil?
        ids = [] of Int32 | Int64 | Nil
        channels.each do |c|
          path = c.path.to_s
          if path.starts_with?(data_path)
            ids << c.id
          end
        end
        query = Query.where(:id, ids)
        Repo.delete_all(Channel, query)
      end

      def self.get_meta(project, id)
        channel = Repo.get_by(Channel, id: id)
        raise "cannot find channel" if channel.nil?
        channel = channel.as(Channel)
        root = ENV["DMAC_ROOT"]
        project_root = root + "/" + project.path.to_s
        full_path = project_root + "/" + channel.path.to_s + "/" + channel.meta_data.to_s
        lines = File.read_lines(full_path)
        fields = [] of String
        if (lines.size > 0)
          line = lines[0]
          line.split('\t') do |s|
            fields << s
          end
        end
        return fields
      end

      def self.upload_file(project, id, file, new_name)
        channel = Repo.get_by(Channel, id: id)
        raise "cannot find channel" if channel.nil?
        channel = channel.as(Channel)

        root = ENV["DMAC_ROOT"]
        full_path = root + "/" + project.path.to_s + channel.path.to_s

        filename = new_name
        raise "No filename included in upload" if new_name.empty?

        target_path = full_path + "/" + filename
        if channel.rename
          raise "Filename " + filename + " exists" if File.exists?(target_path)
        else
          ext = File.extname(filename)
          base = File.basename(filename, ext)
          i = 1
          while File.exists?(target_path)
            filename = base + "_" + i.to_s + ext
            target_path = full_path + "/" + filename
            i += 1
          end
        end

        File.open(target_path, "w") do |f|
          IO.copy(file.tmpfile, f)
        end

        return channel.path.to_s + "/" + filename
      end

      def self.upload_meta(project, id, meta_data)
        channel = Repo.get_by(Channel, id: id)
        raise "cannot find channel" if channel.nil?
        channel = channel.as(Channel)
        raise "no channel meta data" if channel.meta_data.to_s.empty?

        root = ENV["DMAC_ROOT"]
        project_root = root + "/" + project.path.to_s
        meta_data_file = channel.path.to_s + "/" + channel.meta_data.to_s
        full_path = project_root + meta_data_file
        raise "cannot find meta data file" unless File.file?(full_path)

        lines = File.read_lines(full_path)
        result = String.build do |str|
          lines.each do |line|
            str << line << "\n" unless line.strip.empty?
          end
          str << meta_data << "\n"
        end
        File.write(full_path, result)
        return meta_data_file
      end
    end
  end
end
