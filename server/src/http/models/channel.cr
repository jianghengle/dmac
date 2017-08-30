module DMACServer
  module HttpAPI
    class Channel < Crecto::Model
      raise "No root setup" unless ENV.has_key?("DMAC_ROOT")
      @@root = ENV["DMAC_ROOT"]

      schema "channels" do
        field :project_id, Int32
        field :path, String
        field :meta_data, String
        field :instruction, String
        field :rename, Bool
        belongs_to :project, Project
      end

      def to_json()
        result = String.build do |str|
          str << "{"
          str << "\"id\":" << @id << ","
          str << "\"projectId\":" << @project_id << ","
          str << "\"path\":" << @path.to_json << ","
          str << "\"metaData\":" << @meta_data.to_json << ","
          str << "\"instruction\":" << @instruction.to_json << ","
          str << "\"rename\":" << @rename.to_s
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
        project_root = root + "/" + project.key.to_s
        directories = Channel.get_directories(project_root, project_root)
        return directories
      end

      def self.get_directories(path, project_root)
        directories = [] of String
        Dir.foreach path do |filename|
          if filename.to_s != "." && filename.to_s != ".." && filename.to_s != ".git" && filename.to_s != "__MACOSX"
            full_path = path + "/" + filename
            if File.directory? full_path
              size = project_root.size
              directories << full_path[size + 1..-1] + "/"
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
        project_root = root + "/" + project.key.to_s
        full_path = project_root + "/" + path.gsub("--", "/")
        files = [] of String
        Dir.foreach full_path do |filename|
          if filename.to_s != "." && filename.to_s != ".." && filename.to_s != ".gitignore" && filename.to_s != ".DS_Store"
            file_path = full_path + "/" + filename
            if File.file? file_path
              files << filename
            end
          end
        end
        return files
      end

      def self.create_channel(project, path, meta_data, instruction, rename)
        channel = Channel.new
        channel.project_id = project.id
        channel.path = path
        channel.meta_data = meta_data
        channel.instruction = instruction
        channel.rename = rename == "true"
        changeset = Repo.insert(channel)
        raise changeset.errors.to_s unless changeset.valid?
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
          changeset = Repo.insert(channel)
          raise changeset.errors.to_s unless changeset.valid?
        end
      end

      def self.get_metadata(project, id)
        channel = Repo.get_by(Channel, id: id)
        raise "cannot find channel" if channel.nil?
        channel = channel.as(Channel)
        root = ENV["DMAC_ROOT"]
        project_root = root + "/" + project.key.to_s
        full_path = project_root + "/" + channel.path.to_s.gsub("--", '/') + channel.meta_data.to_s
        lines = File.read_lines(full_path)
        fields = [] of String
        if(lines.size > 0)
          line = lines[0]
          line.split('\t') do |s|
            fields << s
          end
        end
        return fields
      end

      def self.upload_data(project, id, file, new_name, meta_data)
        channel = Repo.get_by(Channel, id: id)
        raise "cannot find channel" if channel.nil?
        channel = channel.as(Channel)

        root = ENV["DMAC_ROOT"]
        project_root = root + "/" + project.key.to_s
        full_path = project_root + "/" + channel.path.to_s.gsub("--", '/')

        filename = file.filename
        raise "No filename included in upload" if !filename.is_a?(String)

        filename = new_name if channel.rename

        target_path = full_path + Channel.make_name(full_path, filename)
        File.open(target_path, "w") do |f|
          IO.copy(file.tmpfile, f)
        end

        meta_data_file = full_path + channel.meta_data.to_s
        Channel.save_metadata(meta_data_file, meta_data) unless channel.meta_data.to_s.empty?

        return target_path[(project_root.size+1)..-1]
      end

      def self.save_metadata(meta_data_file, meta_data)
        puts meta_data_file
        puts meta_data
        lines = File.read_lines(meta_data_file)
        result = String.build do |str|
          lines.each do |line|
            str << line << "\n" unless line.strip.empty?
          end
          str << meta_data << "\n"
        end
        puts result
        File.write(meta_data_file, result)
      end

      def self.make_name(path, name)
        new_name = String.build do |str|
          name.chars.each do |c|
            ord = c.ord
            if ord == 46
              str << c
            elsif ord >= 48 && ord <= 57
              str << c
            elsif ord >= 65 && ord <= 90
              str << c
            elsif ord == 95
              str << c
            elsif ord >= 97 && ord <= 122
              str << c
            elsif ord == 126
              str << c
            else
              str << "_"
            end
          end
        end
        raise "cannot make file name" if new_name == ""

        if((new_name.starts_with? '.') || (new_name.starts_with? '~'))
          new_name = "_" + new_name.lchop
        end
        if(new_name.starts_with? '-')
          new_name = "_" + new_name.lchop
        end
        if((new_name.ends_with? '.') || (new_name.ends_with? '-'))
          new_name = new_name.rchop + "_"
        end

        filenames = {} of String => Bool
        Dir.foreach path do |filename|
          filenames[filename.to_s] = true
        end

        i = 0
        ext = File.extname(new_name)
        base = File.basename(new_name, ext)
        while filenames.has_key?(new_name)
          i = i + 1
          new_name = base + "_" + i.to_s + ext
        end

        return new_name
      end

    end
  end
end
