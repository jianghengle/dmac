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
      property hidden : Bool
      property readonly : Bool
      property group : String


      raise "No root setup" unless ENV.has_key?("DMAC_ROOT")
      @@root = ENV["DMAC_ROOT"]

      @@tmp : String
      @@tmp = @@root + "/tmp"
      raise "No temp folder" unless File.directory? @@tmp

      @@typeMap = {} of String => String
      @@typeMap[".png"] = "image"
      @@typeMap[".jpg"] = "image"
      @@typeMap[".jpeg"] = "image"
      @@typeMap[".gif"] = "image"
      @@typeMap[".bmp"] = "image"
      @@typeMap[".pdf"] = "pdf"
      @@typeMap[".txt"] = "text"
      @@typeMap[".md"] = "text"
      @@typeMap[".r"] = "code"
      @@typeMap[".m"] = "code"
      @@typeMap[".py"] = "code"
      @@typeMap[".rb"] = "code"
      @@typeMap[".sh"] = "code"
      @@typeMap["makefile"] = "code"
      @@typeMap[".c"] = "code"
      @@typeMap[".h"] = "code"
      @@typeMap[".cpp"] = "code"
      @@typeMap[".hpp"] = "code"
      @@typeMap[".js"] = "code"
      @@typeMap[".json"] = "code"
      @@typeMap[".cr"] = "code"
      @@typeMap[".html"] = "code"
      @@typeMap[".css"] = "code"
      @@typeMap[".vue"] = "code"
      @@typeMap[".csv"] = "csv"
      @@typeMap[".tsv"] = "csv"
      @@typeMap[".zip"] = "zip"

      @@ignore = {} of String => Bool
      @@ignore["."] = true
      @@ignore[".."] = true
      @@ignore[".git"] = true
      @@ignore[".gitignore"] = true


      def initialize(@project, @data_path)
        @full_path = @@root + "/" + @project.key.to_s + "/" + @data_path
        @rel_path = @project.key.to_s + "/" + @data_path
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

        @hidden = false
        @readonly = false
        @group = ""
        return

        chain = @data_path.split("/")
        chain.each do |s|
          if s[0] == '.'
            @hidden = true
          elsif s[0] == '~'
            @readonly = true
          elsif @group == "" && @type == "folder"
            ss = s.split("_")
            next if ss.size < 3 || ss[0] != ""
            @group = ss[1]
          end
        end

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
          str << "\"readonly\":" << @readonly << ","
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

      def viewable?(control)
        role = control.role.to_s
        group = control.group_name.to_s
        return true if role == "Owner" || role == "Admin"
        return false if @hidden
        return true if group == "" || @group == ""
        return group == @group
      end

      def editable?(control)
        role = control.role.to_s
        return true if role == "Owner" || role == "Admin"
        return false if role == "Viewer"
        return false if !viewable?(control)
        return !@readonly
      end

      def self.collect_files(control, project, data_path)
        files = [] of MyFile
        dir = MyFile.new(project, data_path)
        raise "You do not have permission" unless dir.viewable?(control)
        files << dir
        return files if dir.type.to_s == "file"
        Dir.foreach dir.full_path do |filename|
          next if @@ignore.has_key? filename.to_s
          dp = filename
          dp = data_path + "/" + dp if data_path.size > 0 
          file = MyFile.new(project, dp)
          files << file if file.viewable?(control)
        end
        return files
      end

      def self.create_folder(project, data_path)
        full_path = @@root + "/" + project.key.to_s + "/" + data_path
        Dir.mkdir(full_path)
      end

      def self.create_file(project, data_path, control)
        raise "No permission" unless MyFile.check_parent(project, data_path, control)
        full_path = @@root + "/" + project.key.to_s
        full_path = full_path + "/" + data_path
        raise "Already exist" if File.exists?(full_path)
        File.write(full_path, "")
      end

      def self.check_parent(project, data_path, control)
        index = data_path.rindex("/")
        parent_data_path = ""
        parent_data_path = data_path[0, index] unless index.nil?
        file = MyFile.new(project, parent_data_path)
        return file.editable?(control)
      end

      def self.delete_folder(project, data_path)
        full_path = @@root + "/" + project.key.to_s + "/" + data_path
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

      def self.update_folder_file_name(project, data_path, name, control)
        file = MyFile.new(project, data_path)
        raise "No permission" unless file.editable?(control)
        full_path = file.full_path
        dirname = File.dirname(full_path)
        new_full_path = dirname.to_s + "/" + name
        File.rename(full_path, new_full_path)
      end

      def self.delete_folder_file(project, data_path, control)
        file = MyFile.new(project, data_path)
        raise "No permission" unless file.editable?(control)
        MyFile.delete_files(file.full_path)
      end

      def self.upload_file(project, data_path, file, control)
        dir = MyFile.new(project, data_path)
        raise "Target is not a folder" unless dir.type == "folder"
        raise "No permission" unless dir.editable?(control)

        full_path = @@root + "/" + project.key.to_s
        prefix_length = full_path.size + 1
        full_path = full_path + "/" + data_path

        filename = file.filename
        raise "No filename included in upload" if !filename.is_a?(String)

        target_path = MyFile.make_target(full_path, filename, true)
        File.open(target_path, "w") do |f|
          IO.copy(file.tmpfile, f)
        end

        return target_path[prefix_length..-1]
      end

      def self.make_target(path, name, upload)
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

        if(upload && ((new_name.starts_with? '.') || (new_name.starts_with? '~')))
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

        return path + "/" + new_name
      end

      def self.get_download_path(download)
        key = download.key.to_s
        project_key = download.project_key.to_s
        data_path = download.data_path.to_s
        full_path = @@root + "/" + project_key + "/" + data_path
        raise "No such path" unless File.exists?(full_path)
        return full_path if File.file? full_path
        return @@tmp + "/" + key + "/" + key + ".zip"
      end

      def self.save_text_file(project, data_path, text, control)
        file = MyFile.new(project, data_path)
        raise "No permission" unless file.editable?(control)
        raise "Not text file" unless file.fileType == "text" || file.fileType == "code"
        file.save_text(text)
      end

      def self.copy_files(source_files, target_file, source_control, target_control)
        raise "Target is not a folder" unless target_file.type == "folder"
        raise "No permission" unless target_file.editable?(target_control)
        new_folders = {} of String => Bool
        source_files.each do |f|
          source_project = f.project
          if f.type == "file"
            MyFile.copy_file(f.full_path, target_file.full_path, source_control, source_project)
          else
            MyFile.copy_folder(f.full_path, target_file.full_path, new_folders, source_control, source_project)
          end
        end
      end

      def self.copy_file(source_full_path, target_full_path, control, project)
        return unless MyFile.check_source(control, project, source_full_path)
        new_full_path = MyFile.make_name(source_full_path, target_full_path)
        File.open(new_full_path, "w") do |tf|
          File.open(source_full_path) do |sf|
            IO.copy(sf, tf)
          end
        end
      end

      def self.copy_folder(source_full_path, target_full_path, new_folders, control, project)
        return unless MyFile.check_source(control, project, source_full_path)
        new_target_full_path = MyFile.make_name(source_full_path, target_full_path)
        Dir.mkdir(new_target_full_path)
        new_folders[new_target_full_path] = true
        Dir.foreach source_full_path do |filename|
          next if @@ignore.has_key? filename.to_s
          new_source_full_path = source_full_path + "/" + filename
          if File.file? new_source_full_path
            MyFile.copy_file(new_source_full_path, new_target_full_path, control, project)
          elsif (File.directory? new_source_full_path) && (!new_folders.has_key?(new_source_full_path))
            MyFile.copy_folder(new_source_full_path, new_target_full_path, new_folders, control, project)
          end
        end
      end

      def self.check_source(control, project, full_path)
        project_root = @@root + "/" + project.key.to_s
        rel_path = full_path[(project_root.size+1)..-1]
        data_path = rel_path
        file = MyFile.new(project, data_path)
        return file.viewable?(control)
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

      def self.unzip_file(project, data_path)
        file = MyFile.new(project, data_path)
        temp_path = MyFile.unzip_to_temp(file.full_path)

        target_path = ""
        file.full_path.split('/') do |s|
          target_path = target_path + "/" + s if s != file.name
        end

        Dir.foreach temp_path do |filename|
          next if filename.to_s == "." || filename.to_s == ".."
          source = temp_path + "/" + filename
          if File.file? source
            MyFile.copy_file_from_outside(source, target_path)
          else
            MyFile.copy_folder_from_outside(source, target_path)
          end
        end
      end

      def self.unzip_to_temp(source)
        temp_path = @@tmp + "/" + SecureRandom.hex(32).to_s
        Dir.mkdir(temp_path)
        command = "unzip " + source + " -d " + temp_path
        io = IO::Memory.new
        Process.run(command, shell: true, output: io)
        return temp_path
      end

      def self.copy_file_from_outside(source, target)
        name = File.basename(source)
        target_path = MyFile.make_target(target, name, false)
        File.open(target_path, "w") do |tf|
          File.open(source) do |sf|
            IO.copy(sf, tf)
          end
        end
      end

      def self.copy_folder_from_outside(source, target)
        name = File.basename(source)
        new_target = MyFile.make_target(target, name, false)
        Dir.mkdir(new_target)
        Dir.foreach source do |filename|
          next if @@ignore.has_key? filename.to_s
          new_source = source + "/" + filename
          if File.file? new_source
            MyFile.copy_file_from_outside(new_source, new_target)
          else
            MyFile.copy_folder_from_outside(new_source, new_target)
          end
        end
      end

      def self.prepare_download(download, project, data_path, control)
        file = MyFile.new(project, data_path)
        return if file.type == "file"
        key = download.key.to_s
        temp_path = @@tmp + "/" + key
        Dir.mkdir(temp_path)
        new_folders = {} of String => Bool
        MyFile.copy_folder(file.full_path, temp_path, new_folders, control, project)
        command = "cd " + temp_path + " && zip -r " + key + " *"
        io = IO::Memory.new
        Process.run(command, shell: true, output: io)
      end

      def self.copy_project_files(source, target)
        source_path = @@root + "/" + source.key.to_s
        target_path = @@root + "/" + target.key.to_s
        Dir.foreach source_path do |filename|
          next if @@ignore.has_key? filename.to_s
          path = source_path + "/" + filename
          if File.file? path
            MyFile.copy_file_from_outside(path, target_path)
          else
            MyFile.copy_folder_from_outside(path, target_path)
          end
        end
      end

      def self.clean_temp
        now = Time.now
        Dir.foreach @@tmp do |filename|
          next if filename.to_s == "." || filename.to_s == ".."
          path = @@tmp + "/" + filename
          created_at = File.stat(path).ctime
          span = now - created_at.as(Time)
          next if span.total_minutes < 60
          MyFile.delete_files(path)
        end
      end

    end

  end
end
