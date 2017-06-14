module DMACServer
  module HttpAPI
    class MyFile
      property type : String
      property name : String
      property data_path : String
      property full_path : String
      property project : Project
      property size : UInt64
      property modified_at : Time

      raise "No root setup" unless ENV.has_key?("DMAC_ROOT")
      @@root = ENV["DMAC_ROOT"]

      def initialize(@project, @data_path)
        if @data_path == ""
          @full_path = @@root + "/" + @project.key.to_s
        else
          rel_path = @data_path.gsub("--", "/")
          @full_path = @@root + "/" + @project.key.to_s + "/" + rel_path
        end
        raise "No such path" unless File.exists?(@full_path)

        @type = "file"
        @type = "folder" if File.directory?(@full_path)

        @name = File.basename(@full_path)
        @size = File.size(@full_path)
        @modified_at = File.stat(@full_path).mtime
      end


      def to_json
        result = String.build do |str|
          str << "{"
          str << "\"projectId\":\"" << @project.id << "\","
          str << "\"type\":\"" << @type << "\","
          str << "\"name\":\"" << @name << "\","
          str << "\"dataPath\":\"" << @data_path << "\","
          str << "\"size\":\"" << @size << "\","
          str << "\"modifiedTime\":" << @modified_at.as(Time).epoch
          str << "}"
        end
        result
      end


      def self.collect_files(role, project)
        files = [] of MyFile
        dir = MyFile.new(project, "")
        files << dir
        Dir.foreach dir.full_path do |filename|
          if filename.to_s != "." && filename.to_s != ".."
            if filename.to_s[0] != '.'
              files << MyFile.new(project, filename.to_s)
            elsif role == "Owner" || role == "Admin"
              files << MyFile.new(project, filename.to_s)
            end
          end
        end
        return files
      end


      def self.collect_files(role, project, data_path)
        files = [] of MyFile
        dir = MyFile.new(project, data_path)
        files << dir
        Dir.foreach dir.full_path do |filename|
          if filename.to_s != "." && filename.to_s != ".."
            dp = data_path + "--" + filename
            if filename.to_s[0] != '.'
              files << MyFile.new(project, dp)
            elsif role == "Owner" || role == "Admin"
              files << MyFile.new(project, dp)
            end
          end
        end
        return files
      end

      def self.create_folder(project, data_path)
        full_path = @@root + "/" + project.key.to_s
        if data_path != ""
          full_path = full_path + "/" + data_path.gsub("--", "/")
        end
        Dir.mkdir(full_path)
      end

      def self.delete_folder(project, data_path)
        full_path = @@root + "/" + project.key.to_s
        if data_path != ""
          full_path = full_path + "/" + data_path.gsub("--", "/")
        end
        MyFile.delete_files(full_path)
      end


      def self.delete_files(path)
        return unless File.exists?(path)
        if File.file?(path)
          File.delete(path)
        else
          Dir.foreach path do |filename|
            if filename.to_s != "." && filename.to_s != ".."
              p = path + "/" + filename
              MyFile.delete_files(p)
            end
          end
          Dir.rmdir(path)
        end
      end

      def self.update_folder_file_name(project, data_path, name)
        full_path = @@root + "/" + project.key.to_s + "/" + data_path.gsub("--", "/")
        raise "Cannot find file" unless File.exists?(full_path)
        dirname = File.dirname(full_path)
        new_full_path = dirname.to_s + "/" + name
        File.rename(full_path, new_full_path)
      end

      def self.delete_folder_file(project, data_path)
        full_path = @@root + "/" + project.key.to_s + "/" + data_path.gsub("--", "/")
        MyFile.delete_files(full_path)
      end

      def self.upload_file(project, data_path, file)
        full_path = @@root + "/" + project.key.to_s
        full_path = full_path + "/" + data_path.gsub("--", "/") if data_path != "-root-"

        filename = file.filename
        raise "No filename included in upload" if !filename.is_a?(String)

        target_path = MyFile.make_target(full_path, filename)
        puts target_path
        File.open(target_path, "w") do |f|
          IO.copy(file.tmpfile, f)
        end
      end

      def self.make_target(path, name)
        new_name = String.build do |str|
          name.chars.each do |c|
            ord = c.ord
            if ord == 45
              str << c
            elsif ord == 46
              str << c
            elsif ord >= 48 && ord <= 57
              str << c
            elsif ord >= 65 && ord <= 90
              str << c
            elsif ord == 95
              str << c
            elsif ord >= 97 && ord <= 122
              str << c
            else
              str << "_"
            end
          end
        end
        raise "cannot make file name" if new_name == ""

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

        return path + "/" + new_name
      end

    end

  end
end
