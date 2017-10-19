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

      def self.init_project(project)
        return unless @@enabled

        admin_group = "dmac-" + project.key.to_s + "-admin"
        editor_group = "dmac-" + project.key.to_s + "-editor"
        viewer_group = "dmac-" + project.key.to_s + "-viewer"
        Local.run("groupadd " + admin_group)
        Local.run("groupadd " + editor_group)
        Local.run("groupadd " + viewer_group)

        controls = Control.get_controls_by_project_id(project.id)
        controls.each do |c|
          role = c.role.to_s
          email = c.email.to_s
          user = User.get_user_by_email(email)
          next if user.nil?
          user = user.as(User)
          username = user.username.to_s
          if role == "Viewer"
            Local.set_project_group(project, username, viewer_group)
          elsif role == "Editor"
            Local.set_project_group(project, username, editor_group)
          else
            Local.set_project_group(project, username, admin_group)
          end
        end

        project_root = @@dmac_root + "/" + project.path.to_s
        Local.run("setfacl -m \"g:" + admin_group + ":rwx\" \"" + project_root + "\"")
        Local.run("setfacl -dm \"g:" + admin_group + ":rwx\" \"" + project_root + "\"")
        Local.run("setfacl -m \"g:" + editor_group + ":rwx\" \"" + project_root + "\"")
        Local.run("setfacl -dm \"g:" + editor_group + ":rwx\" \"" + project_root + "\"")
        Local.run("setfacl -m \"g:" + viewer_group + ":rx\" \"" + project_root + "\"")
        Local.run("setfacl -dm \"g:" + viewer_group + ":rx\" \"" + project_root + "\"")
      end

      def self.set_project_group(project, username, group)
        prefix = "dmac-" + project.key.to_s + "-"
        groups = Local.find_user_groups(username)
        groups.each do |g|
          next if g == group
          if g.starts_with?(prefix)
            Local.run("gpasswd -d " + username + " " + g)
          end
        end
        Local.run("usermod -a -G " + group + " " + username)
      end

      def self.find_user_groups(username)
        groups = [] of String
        io = Local.run("groups " + username)
        index = io.index(":")
        return groups if index.nil?
        io[(index + 1)..-1].split(" ") do |s|
          group = s.strip
          groups << group unless group.empty?
        end
        return groups
      end

      def self.delete_project(project)
        return unless @@enabled

        admin_group = "dmac-" + project.key.to_s + "-admin"
        editor_group = "dmac-" + project.key.to_s + "-editor"
        viewer_group = "dmac-" + project.key.to_s + "-viewer"
        Local.run("groupmems -p -g " + viewer_group)
        Local.run("groupmems -p -g " + editor_group)
        Local.run("groupmems -p -g " + admin_group)
        Local.run("groupdel " + viewer_group)
        Local.run("groupdel " + editor_group)
        Local.run("groupdel " + admin_group)
      end

      def self.change_project_status(project, new_status)
        return unless @@enabled

        project_root = @@dmac_root + "/" + project.path.to_s
        editor_group = "dmac-" + project.key.to_s + "-editor"
        viewer_group = "dmac-" + project.key.to_s + "-viewer"
        old_status = project.status.to_s
        if old_status == "Active"
          if new_status != "Active"
            Local.run("setfacl -m \"g:" + editor_group + ":-\" \"" + project_root + "\"")
            Local.run("setfacl -m \"g:" + viewer_group + ":-\" \"" + project_root + "\"")
          end
        elsif new_status == "Active"
          Local.run("setfacl -m \"g:" + editor_group + ":rwx\" \"" + project_root + "\"")
          Local.run("setfacl -m \"g:" + viewer_group + ":rx\" \"" + project_root + "\"")
        end
      end
    end
  end
end
