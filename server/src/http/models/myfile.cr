module DMACServer
  module HttpAPI
    class MyFile
      property type : String
      property name : String
      property data_path : String
      property full_path : String
      property rel_path : String
      property project : Project
      property size : UInt64
      property modified_at : Time
      property fileType : String

      raise "No root setup" unless ENV.has_key?("DMAC_ROOT")
      @@root = ENV["DMAC_ROOT"]
      @@typeMap = {} of String => String
      @@typeMap[".png"] = "image"
      @@typeMap[".jpg"] = "image"
      @@typeMap[".jpeg"] = "image"
      @@typeMap[".gif"] = "image"
      @@typeMap[".bmp"] = "image"
      @@typeMap[".pdf"] = "pdf"
      @@typeMap[".txt"] = "text"
      @@typeMap[".md"] = "text"
      @@typeMap[".r"] = "text"
      @@typeMap[".m"] = "text"
      @@typeMap[".py"] = "text"
      @@typeMap[".rb"] = "text"
      @@typeMap[".sh"] = "text"
      @@typeMap["makefile"] = "text"
      @@typeMap[".c"] = "text"
      @@typeMap[".h"] = "text"
      @@typeMap[".cpp"] = "text"
      @@typeMap[".hpp"] = "text"
      @@typeMap[".sh"] = "text"
      @@typeMap[".js"] = "text"
      @@typeMap[".json"] = "text"
      @@typeMap[".cr"] = "text"
      @@typeMap[".html"] = "text"
      @@typeMap[".css"] = "text"
      @@typeMap[".vue"] = "text"
      @@typeMap[".csv"] = "text"

      def initialize(@project, @data_path)
        if @data_path == "-root-"
          @full_path = @@root + "/" + @project.key.to_s
          @rel_path = @project.key.to_s
        else
          rel_path = @data_path.gsub("--", "/")
          @full_path = @@root + "/" + @project.key.to_s + "/" + rel_path
          @rel_path = @project.key.to_s + "/" + rel_path
        end
        raise "No such path" unless File.exists?(@full_path)

        @type = "folder"
        @fileType = "folder"
        if File.file?(@full_path)
          @type = "file"
          @fileType = "unknown"
          base = File.basename(full_path).downcase
          ext = File.extname(full_path).downcase
          if @@typeMap.has_key?(base)
            @fileType = @@typeMap[base]
          elsif @@typeMap.has_key?(ext)
            @fileType = @@typeMap[ext]
          end
          @size = File.size(@full_path)
        else
          @size = UInt64.new 0
        end

        @name = File.basename(@full_path)
        @modified_at = File.stat(@full_path).mtime
      end


      def to_json(read_text=false, public_url="")
        result = String.build do |str|
          str << "{"
          str << "\"projectId\":\"" << @project.id << "\","
          str << "\"type\":\"" << @type << "\","
          str << "\"fileType\":\"" << @fileType << "\","
          str << "\"name\":\"" << @name << "\","
          str << "\"dataPath\":\"" << @data_path << "\","
          str << "\"publicUrl\":\"" << public_url << "\","
          str << "\"size\":\"" << @size << "\","
          if read_text
            str << "\"text\":" << get_text.to_json << ","
          else
            str << "\"text\":\"\","
          end
          str << "\"modifiedTime\":" << @modified_at.as(Time).epoch
          str << "}"
        end
        result
      end

      def get_text
        return File.read(@full_path)
      end

      def save_text(text)
        File.write(@full_path, text)
      end

      def self.collect_files(role, project, data_path)
        files = [] of MyFile
        dir = MyFile.new(project, data_path)
        files << dir
        return files if dir.type.to_s == "file"
        Dir.foreach dir.full_path do |filename|
          if filename.to_s != "." && filename.to_s != ".." && filename.to_s != ".git"
            dp = filename
            dp = data_path + "--" + dp unless data_path == "-root-"
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
        if data_path != "-root-"
          full_path = full_path + "/" + data_path.gsub("--", "/")
        end
        Dir.mkdir(full_path)
      end

      def self.create_file(project, data_path)
        full_path = @@root + "/" + project.key.to_s
        if data_path != "-root-"
          full_path = full_path + "/" + data_path.gsub("--", "/")
        end
        raise "Already exist" if File.exists?(full_path)
        File.write(full_path, "")
      end

      def self.delete_folder(project, data_path)
        full_path = @@root + "/" + project.key.to_s
        if data_path != "-root-"
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
        prefix_length = full_path.size + 1
        full_path = full_path + "/" + data_path.gsub("--", "/") if data_path != "-root-"

        filename = file.filename
        raise "No filename included in upload" if !filename.is_a?(String)

        target_path = MyFile.make_target(full_path, filename)
        File.open(target_path, "w") do |f|
          IO.copy(file.tmpfile, f)
        end

        return target_path[prefix_length..-1]
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

      def self.get_full_path(project_key, data_path)
        full_path = @@root + "/" + project_key.to_s + "/" + data_path.gsub("--", "/")
        raise "No such path" unless File.exists?(full_path)
        return full_path
      end

      def self.save_text_file(project, data_path, text)
        file = MyFile.new(project, data_path)
        raise "No such file" unless file.fileType == "text"
        file.save_text(text)
      end

      def self.copy_files(source_files, target_file)
        new_folders = {} of String => Bool
        source_files.each do |f|
          if f.type == "file"
            MyFile.copy_file(f.full_path, target_file.full_path)
          else
            MyFile.copy_folder(f.full_path, target_file.full_path, new_folders)
          end
        end
      end

      def self.copy_file(source_full_path, target_full_path)
        new_full_path = MyFile.make_name(source_full_path, target_full_path)
        File.open(new_full_path, "w") do |tf|
          File.open(source_full_path) do |sf|
            IO.copy(sf, tf)
          end
        end
      end

      def self.copy_folder(source_full_path, target_full_path, new_folders)
        new_target_full_path = MyFile.make_name(source_full_path, target_full_path)
        Dir.mkdir(new_target_full_path)
        new_folders[new_target_full_path] = true
        Dir.foreach source_full_path do |filename|
          if filename.to_s != "." && filename.to_s != ".."
            new_source_full_path = source_full_path + "/" + filename
            if File.file? new_source_full_path
              MyFile.copy_file(new_source_full_path, new_target_full_path)
            elsif (File.directory? new_source_full_path) && (!new_folders.has_key?(new_source_full_path))
              MyFile.copy_folder(new_source_full_path, new_target_full_path, new_folders)
            end
          end
        end
      end

      def self.make_name(source_name, target_path)
        filenames = {} of String => Bool
        Dir.foreach target_path do |filename|
          filenames[filename.to_s] = true
        end

        i = 0
        new_name = File.basename(source_name)
        ext = File.extname(source_name)
        base = File.basename(source_name, ext)
        while filenames.has_key?(new_name)
          i = i + 1
          new_name = base + "_" + i.to_s + ext
        end

        return target_path + "/" + new_name
      end

    end

  end
end
