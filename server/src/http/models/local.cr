module DMACServer
  module HttpAPI
    class Local
      @@enabled = false
      if ENV.has_key?("DMAC_PERMISSION")
        @@enabled = ENV["DMAC_PERMISSION"] == "local"
      end

      raise "No root setup" unless ENV.has_key?("DMAC_ROOT")
      @@dmac_root = ENV["DMAC_ROOT"]

      def self.run(command)
        io = IO::Memory.new
        Process.run(command, shell: true, output: io)
        io.to_s
      end

      def self.create_user(email, password)
        index = email.index("@")
        raise "invalid email" if index.nil?
        name = email[0...index]
        return name unless @@enabled

        io = Local.run("cat /etc/passwd | cut -d \":\" -f1")
        names = [] of String
        io.each_line do |l|
          names << l unless l.empty?
        end

        i = 0
        new_name = name
        while names.includes? new_name
          i += 1
          new_name = name + i.to_s
        end

        Local.run("useradd -d " + @@dmac_root + " -g dmac " + new_name)
        Local.run("echo " + password + " | passwd --stdin " + new_name)

        return new_name
      end
    end
  end
end
