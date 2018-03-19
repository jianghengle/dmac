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
        io = Local.run(command)
        raise "something wrong" if io == ""
        io
      end

      def self.transfer_file_to(username, password, local_path, path)
        raise "no IRODS_SCRIPT variable" if @@script == ""

        command = "python #{@@script} putfile \"#{username}\" \"#{password}\" \"#{local_path}\" \"#{path}\""
        io = Local.run(command)
        raise "something wrong" if io == ""
        io
      end

      def self.transfer_folder_to(username, password, local_path, path)
        raise "no IRODS_SCRIPT variable" if @@script == ""

        command = "python #{@@script} putfolder \"#{username}\" \"#{password}\" \"#{local_path}\" \"#{path}\""
        io = Local.run(command)
        raise "something wrong" if io == ""
        io
      end

      def self.transfer_file_from(username, password, path, local_path)
        raise "no IRODS_SCRIPT variable" if @@script == ""

        command = "python #{@@script} getfile \"#{username}\" \"#{password}\" \"#{path}\" \"#{local_path}\""
        io = Local.run(command)
        raise "something wrong" if io == ""
        io
      end

      def self.transfer_folder_from(username, password, path, local_path)
        raise "no IRODS_SCRIPT variable" if @@script == ""

        command = "python #{@@script} getfolder \"#{username}\" \"#{password}\" \"#{path}\" \"#{local_path}\""
        io = Local.run(command)
        raise "something wrong" if io == ""
        io
      end
    end
  end
end
