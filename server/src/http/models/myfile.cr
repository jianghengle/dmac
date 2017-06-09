module DMACServer
  module HttpAPI
    class MyFile
      property type : String
      property name : String
      property path : String
      property full_path : String
      property project : Project
      property size : UInt64
      property modified_at : Time

      raise "No root setup" unless ENV.has_key?("DMAC_ROOT")
      @@root = ENV["DMAC_ROOT"]

      def initialize(@project, path)
        if path == ""
          @full_path = @@root + "/" + @project.key.to_s
          @path = "/" + project.id.to_s + "/-root-"
        else
          tail = ""
          path.split("/") { |s| tail = s }
          rel_path = tail.gsub("--", "/")
          @full_path = @@root + "/" + @project.key.to_s + "/" + rel_path
          @path = "/" + project.id.to_s + "/" + tail
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
          str << "\"project_id\":\"" << @project.id << "\","
          str << "\"type\":\"" << @type << "\","
          str << "\"name\":\"" << @name << "\","
          str << "\"path\":\"" << @path << "\","
          str << "\"size\":\"" << @size << "\","
          str << "\"modified_at\":" << @modified_at.as(Time).epoch
          str << "}"
        end
        result
      end


      def self.collect_files(project)
        files = [] of MyFile
        root_dir = MyFile.new(project, "")
        files << root_dir
        Dir.foreach root_dir.full_path do |filename|
          if filename.to_s != "." && filename.to_s != ".."
            path = "/" + project.id.to_s + "/" + filename
            files << MyFile.new(project, path)
          end
        end
        return files
      end


      def self.collect_files(project, path)
        files = [] of MyFile
        root_dir = MyFile.new(project, path)
        files << root_dir
        Dir.foreach root_dir.full_path do |filename|
          if filename.to_s != "." && filename.to_s != ".."
            path = root_dir.path + "--" + filename
            files << MyFile.new(project, path)
          end
        end
        return files
      end

    end

  end
end
