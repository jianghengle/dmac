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
      property file_type : String
      property access : Int32
      property true_access : Int32

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
      @@typeMap[".doc"] = "pdf"
      @@typeMap[".docx"] = "pdf"
      @@typeMap[".xls"] = "pdf"
      @@typeMap[".xlsx"] = "pdf"
      @@typeMap[".ppt"] = "pdf"
      @@typeMap[".pptx"] = "pdf"
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

      def initialize(@project, @data_path, parent = nil)
        @full_path = @@root + "/" + @project.path.to_s + @data_path
        @rel_path = @project.path.to_s + @data_path
        raise "No such path" unless File.exists?(@full_path)

        @type = "folder"
        @file_type = "folder"
        if File.file?(@full_path)
          @type = "file"
          @file_type = "unknown"
          base = File.basename(full_path).downcase
          ext = File.extname(full_path).downcase
          if @@typeMap.has_key?(base)
            @file_type = @@typeMap[base]
          elsif @@typeMap.has_key?(ext)
            @file_type = @@typeMap[ext]
          end
          @size = File.size(@full_path)
        else
          @size = UInt64.new 0
        end

        @name = File.basename(@full_path)
        @modified_at = File.stat(@full_path).mtime

        @access = MyFile.get_access(@project, @data_path)
        @true_access = 0
        @true_access = get_true_access(parent)
      end

      def to_json(read_text = false, public_url = "")
        result = String.build do |str|
          str << "{"
          str << "\"projectId\":\"" << @project.id << "\","
          str << "\"type\":\"" << @type << "\","
          str << "\"fileType\":\"" << @file_type << "\","
          str << "\"name\":\"" << @name << "\","
          str << "\"dataPath\":\"" << @data_path << "\","
          str << "\"publicUrl\":\"" << public_url << "\","
          str << "\"size\":\"" << @size << "\","
          str << "\"access\":" << @access << ","
          str << "\"trueAccess\":" << @true_access << ","
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

      def get_true_access(parent)
        return 2 if @access == 2
        access = 0
        if parent.nil?
          dp = ""
          @data_path.split("/") do |s|
            dp += "/" + s
            a = MyFile.get_access(@project, dp)
            access = Math.max(access, a)
            break if access == 2
          end
        else
          access = parent.true_access
        end
        return Math.max(access, @access)
      end

      def viewable?(control)
        role = control.role.to_s
        return true if role == "Owner" || role == "Admin"
        return @true_access != 2
      end

      def editable?(control)
        role = control.role.to_s
        return true if role == "Owner" || role == "Admin"
        return false if role == "Viewer"
        return false if @file_type == "folder"
        return @true_access == 0
      end

      def can_add_file?(control, filename)
        role = control.role.to_s
        return false unless @file_type == "folder"
        return true if role == "Owner" || role == "Admin"
        return false if role == "Viewer"
        return false if @true_access > 0
        target_path = @full_path + "/" + filename
        return true unless File.exists?(target_path)
        target_data_path = @data_path + "/" + filename
        target_file = MyFile.new(@project, target_data_path, self)
        return target_file.editable?(control)
      end

      def self.get_access(project, data_path)
        return 0
      end

      def self.collect_files(control, project, data_path)
        files = [] of MyFile
        dir = MyFile.new(project, data_path)
        raise "You do not have permission" unless dir.viewable?(control)
        files << dir
        return files if dir.type.to_s == "file"
        Dir.foreach dir.full_path do |filename|
          next if @@ignore.has_key? filename.to_s
          dp = "/" + filename
          dp = data_path + dp unless data_path == "/"
          file = MyFile.new(project, dp, dir)
          files << file if file.viewable?(control)
        end
        return files
      end

      def self.get_parent_data_path(data_path)
        index = data_path.rindex("/")
        parent_data_path = "/"
        parent_data_path = data_path[0, index] unless index.nil? || data_path == "/"
        return parent_data_path
      end

      def self.create_folder(project, data_path)
        full_path = @@root + "/" + project.path.to_s + data_path
        Dir.mkdir(full_path)
      end

      def self.create_project_folder!(user, project_name)
        full_path = @@root + "/" + user.username.to_s + "/" + project_name
        Dir.mkdir(full_path)
      end

      def self.create_file(project, data_path, control)
        full_path = @@root + "/" + project.path.to_s + data_path
        raise "Already exist" if File.exists?(full_path)
        role = control.role.to_s
        if role == "Editor"
          parent_data_path = MyFile.get_parent_data_path(data_path)
          parent_file = MyFile.new(project, parent_data_path)
          raise "File permission denied" if parent_file.true_access > 0
        end
        File.write(full_path, "")
      end

      def self.delete_project_folder(project)
        full_path = @@root + "/" + project.path.to_s
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
        full_path = @@root + "/" + project.path.to_s
        prefix_length = full_path.size + 1
        full_path = full_path + data_path

        filename = file.filename
        raise "No filename included in upload" if !filename.is_a?(String)

        dir = MyFile.new(project, data_path)
        raise "No file permission" unless dir.can_add_file?(control, filename)

        target_path = full_path + "/" + filename
        File.open(target_path, "w") do |f|
          IO.copy(file.tmpfile, f)
        end

        return target_path[prefix_length..-1]
      end

      def self.get_download_path(project, download)
        key = download.key.to_s
        project_path = project.path.to_s
        data_path = download.data_path.to_s
        full_path = @@root + "/" + project_path + data_path
        raise "No such path" unless File.exists?(full_path)
        return full_path if File.file? full_path
        return @@tmp + "/" + key + "/" + key + ".zip"
      end

      def self.save_text_file(project, data_path, text, control)
        file = MyFile.new(project, data_path)
        raise "No permission" unless file.editable?(control)
        raise "Not text file" unless file.file_type == "text" || file.file_type == "code"
        file.save_text(text)
      end

      def self.copy_files(source_files, target_path, target_control)
        new_folders = {} of String => Bool
        source_files.each do |f|
          if f.type == "file"
            MyFile.copy_file(f.full_path, target_path, target_control)
          else
            MyFile.copy_folder(f.full_path, target_path, target_control, new_folders)
          end
        end
      end

      def self.copy_file(source_full_path, target_path, target_control)
        return unless MyFile.check_copy(source_full_path, target_path, target_control)
        filename = File.basename(source_full_path)
        new_full_path = target_path.full_path + "/" + filename
        File.open(new_full_path, "w") do |tf|
          File.open(source_full_path) do |sf|
            IO.copy(sf, tf)
          end
        end
      end

      def self.copy_folder(source_full_path, target_path, target_control, new_folders)
        return unless MyFile.check_copy(source_full_path, target_path, target_control)
        folder_name = File.basename(source_full_path)
        new_target_full_path = target_path.full_path + "/" + folder_name
        Dir.mkdir(new_target_full_path) unless File.exists? new_target_full_path
        new_target_data_path = target_path.data_path + "/" + folder_name
        new_target_path = MyFile.new(target_path.project, new_target_data_path, target_path)
        new_folders[new_target_path.full_path] = true

        Dir.foreach source_full_path do |filename|
          next if @@ignore.has_key? filename.to_s
          new_source_full_path = source_full_path + "/" + filename
          if File.file? new_source_full_path
            MyFile.copy_file(new_source_full_path, new_target_path, target_control)
          elsif (File.directory? new_source_full_path) && (!new_folders.has_key?(new_source_full_path))
            MyFile.copy_folder(new_source_full_path, new_target_path, target_control, new_folders)
          end
        end
      end

      def self.check_copy(source_full_path, target_path, target_control)
        return false unless target_control.role.to_s != "Editor" || File.file? source_full_path

        filename = File.basename(source_full_path)
        new_full_path = target_path.full_path + "/" + filename
        return true unless File.exists? new_full_path

        new_data_path = target_path.data_path + "/" + filename
        new_file = MyFile.new(target_path.project, new_data_path, target_path)
        return new_file.editable? target_control
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
        command = "unzip \"" + source + "\" -d " + temp_path
        io = IO::Memory.new
        Process.run(command, shell: true, output: io)
        return temp_path
      end

      def self.copy_file_from_outside(source, target)
        name = File.basename(source)
        target_path = target + "/" + name
        return if ((File.exists? target_path) && (File.directory? target_path))
        File.open(target_path, "w") do |tf|
          File.open(source) do |sf|
            IO.copy(sf, tf)
          end
        end
      end

      def self.copy_folder_from_outside(source, target)
        name = File.basename(source)
        new_target = target + "/" + name
        return if ((File.exists? new_target) && (File.file? new_target))
        Dir.mkdir(new_target) unless File.exists? new_target
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
        raise "No permission" unless file.viewable?(control)
        return if file.type == "file"

        key = download.key.to_s
        temp_path = @@tmp + "/" + key
        Dir.mkdir(temp_path)
        new_folders = {} of String => Bool
        MyFile.copy_folder_to_outside(file, control, temp_path, new_folders)
        command = "cd " + temp_path + " && zip -r " + key + " *"
        io = IO::Memory.new
        Process.run(command, shell: true, output: io)
      end

      def self.copy_folder_to_outside(file, control, path, new_folders)
        raise "No permission" unless file.viewable?(control)
        new_full_path = path + "/" + file.name
        Dir.mkdir(new_full_path) unless File.exists? new_full_path
        new_folders[new_full_path] = true

        Dir.foreach file.full_path do |filename|
          next if @@ignore.has_key? filename.to_s
          new_data_path = file.data_path + "/" + filename
          new_file = MyFile.new(file.project, new_data_path, file)
          if new_file.type == "file"
            MyFile.copy_file_to_outside(new_file, control, new_full_path)
          elsif !new_folders.has_key?(new_file.full_path)
            MyFile.copy_folder_to_outside(new_file, control, new_full_path, new_folders)
          end
        end
      end

      def self.copy_file_to_outside(file, control, path)
        raise "No permission" unless file.viewable?(control)
        new_full_path = path + "/" + file.name
        File.open(new_full_path, "w") do |tf|
          File.open(file.full_path) do |sf|
            IO.copy(sf, tf)
          end
        end
      end

      def self.copy_project_files(source, target)
        source_path = @@root + "/" + source.path.to_s
        target_path = @@root + "/" + target.path.to_s
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
