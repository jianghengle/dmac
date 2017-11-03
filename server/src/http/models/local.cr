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

        Local.makeup_controls(email, new_name)
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
        Local.run("chmod o=-  \"" + project_root + "\"")
        Local.run("setfacl -d -m g::- \"" + project_root + "\"")
        Local.run("setfacl -m \"g:" + admin_group + ":rwx\" \"" + project_root + "\"")
        Local.run("setfacl -dm \"g:" + admin_group + ":rwx\" \"" + project_root + "\"")
        Local.run("setfacl -m \"g:" + editor_group + ":rx\" \"" + project_root + "\"")
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

      def self.set_control(project, control)
        return unless @@enabled

        email = control.email.to_s
        user = User.get_user_by_email(email)
        return if user.nil?
        user = user.as(User)
        username = user.username.to_s
        role = control.role.to_s
        if role == "Viewer"
          group = "dmac-" + project.key.to_s + "-viewer"
          Local.set_project_group(project, username, group)
        elsif role == "Editor"
          group = "dmac-" + project.key.to_s + "-editor"
          Local.set_project_group(project, username, group)
        else
          group = "dmac-" + project.key.to_s + "-admin"
          Local.set_project_group(project, username, group)
        end
      end

      def self.remove_control(project, control)
        return unless @@enabled

        email = control.email.to_s
        user = User.get_user_by_email(email)
        return if user.nil?
        user = user.as(User)
        username = user.username.to_s

        admin_group = "dmac-" + project.key.to_s + "-admin"
        editor_group = "dmac-" + project.key.to_s + "-editor"
        viewer_group = "dmac-" + project.key.to_s + "-viewer"
        Local.run("gpasswd -d " + username + " " + admin_group)
        Local.run("gpasswd -d " + username + " " + editor_group)
        Local.run("gpasswd -d " + username + " " + viewer_group)
      end

      def self.makeup_controls(email, username)
        controls = Control.get_controls_by_user(email)
        return if controls.empty?
        project_ids = controls.keys
        projects = Project.get_projects_by_ids(project_ids)
        controls.each do |k, c|
          project = projects[k]
          role = c.role.to_s
          if role == "Viewer"
            group = "dmac-" + project.key.to_s + "-viewer"
            Local.run("usermod -a -G " + group + " " + username)
          elsif role == "Editor"
            group = "dmac-" + project.key.to_s + "-editor"
            Local.run("usermod -a -G " + group + " " + username)
          else
            group = "dmac-" + project.key.to_s + "-admin"
            Local.run("usermod -a -G " + group + " " + username)
          end
        end
      end

      def self.get_group_acl(group, full_path)
        return "rwx" unless @@enabled

        io = Local.run("getfacl -acE \"" + full_path + "\"")
        prefix = "group:" + group + ":"
        io.each_line do |l|
          if l.starts_with?(prefix)
            return l.lchop(prefix)
          end
        end
        return "---"
      end

      def self.reown_project_files(project)
        return unless @@enabled

        project_root = @@dmac_root + "/" + project.path.to_s
        Local.run("chown -R root:root \"" + project_root + "\"")
      end

      def self.set_file_permission(project, full_path, permission)
        return unless @@enabled

        Local.run("chown root:root \"" + full_path + "\"")

        editor_group = "dmac-" + project.key.to_s + "-editor"
        viewer_group = "dmac-" + project.key.to_s + "-viewer"

        if permission == "Normal"
          Local.run("setfacl -R -m \"g:" + editor_group + ":rwx\" \"" + full_path + "\"")
          Local.run("setfacl -R -m \"g:" + viewer_group + ":rx\" \"" + full_path + "\"")
        elsif permission == "Readonly"
          Local.run("setfacl -R -m \"g:" + editor_group + ":rx\" \"" + full_path + "\"")
          Local.run("setfacl -R -m \"g:" + viewer_group + ":rx\" \"" + full_path + "\"")
        elsif permission == "Hidden"
          Local.run("setfacl -R -m \"g:" + editor_group + ":-\" \"" + full_path + "\"")
          Local.run("setfacl -R -m \"g:" + viewer_group + ":-\" \"" + full_path + "\"")
        end
      end
    end
  end
end
