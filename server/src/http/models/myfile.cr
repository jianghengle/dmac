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


      def self.collect_files(project)
        files = [] of MyFile
        dir = MyFile.new(project, "")
        files << dir
        Dir.foreach dir.full_path do |filename|
          if filename.to_s != "." && filename.to_s != ".."
            files << MyFile.new(project, filename.to_s)
          end
        end
        return files
      end


      def self.collect_files(project, data_path)
        files = [] of MyFile
        dir = MyFile.new(project, data_path)
        files << dir
        Dir.foreach dir.full_path do |filename|
          if filename.to_s != "." && filename.to_s != ".."
            dp = data_path + "--" + filename
            files << MyFile.new(project, dp)
          end
        end
        return files
      end

    end

  end
end
