module DMACServer
  module HttpAPI
    class Irods
      @@script = ""
      if ENV.has_key?("IRODS_SCRIPT")
        @@script = ENV["IRODS_SCRIPT"]
      end

      def self.run(command)
        io = IO::Memory.new
        Process.run(command, shell: true, output: io)
        io.to_s
      end

      def self.list_path(username, password, path)
        raise "no IRODS_SCRIPT variable" if @@script == ""

        command = "python #{@@script} list \"#{username}\" \"#{password}\" \"#{path}\""

        puts command
        io = Local.run(command)
        raise "something wrong" if io == ""
        io
      end
    end
  end
end
