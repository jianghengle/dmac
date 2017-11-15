module DMACServer
  module HttpAPI
    class Git
      property project : Project
      property hash : String
      property date : String
      property message : String

      raise "No root setup" unless ENV.has_key?("DMAC_ROOT")
      @@root = ENV["DMAC_ROOT"]

      def initialize(@project, lines)
        @hash = ""
        @date = ""
        @message = ""
        lines.each_index do |i|
          line = lines[i]
          @hash = line[7..-1] if i == 0
          @date = line[5..-1].strip if i == 2
          @message = line.strip if i == 4
        end
      end

      def to_json(read_text = false, public_url = "")
        result = String.build do |str|
          str << "{"
          str << "\"projectId\":\"" << @project.id << "\","
          str << "\"hash\":\"" << @hash << "\","
          str << "\"date\":\"" << @date << "\","
          str << "\"message\":" << @message.to_json
          str << "}"
        end
        result
      end

      def self.init(project, email)
        project_root = @@root + "/" + project.path.to_s
        command = "cd \"" + project_root + "\" && git init && git add ."
        command = command + " && git commit -m\"" + email + " initialized project\""
        io = IO::Memory.new
        Process.run(command, shell: true, output: io)
        io.to_s
      end

      def self.commit(project, message)
        project_root = @@root + "/" + project.path.to_s
        command = "cd \"" + project_root + "\" && git add . && git commit -m\"" + message + "\""
        io = IO::Memory.new
        Process.run(command, shell: true, output: io)
        io.to_s
      end

      def self.get_logs(project)
        project_root = @@root + "/" + project.path.to_s
        command = "cd \"" + project_root + "\" && git log"
        io = IO::Memory.new
        Process.run(command, shell: true, output: io)

        commits = [] of Git
        lines = [] of String
        io.to_s.each_line do |l|
          if l.starts_with? "commit "
            commits << Git.new(project, lines) if lines.size >= 5
            lines.clear
          end
          lines << l
        end
        commits << Git.new(project, lines) if lines.size >= 5
        return commits
      end

      def self.get_commit(project, hash)
        project_root = @@root + "/" + project.path.to_s
        command = "cd \"" + project_root + "\" && git show " + hash
        io = IO::Memory.new
        Process.run(command, shell: true, output: io)
        date = ""
        overflow = false
        result = String.build do |str|
          count = 0
          io.to_s.each_line do |l|
            count = count + l.size
            if count > 1000000
              overflow = true
              break
            elsif l.starts_with? "commit "
              next
            elsif l.starts_with? "Author:"
              next
            elsif l.starts_with? "Date:"
              date = l[5..-1].strip
            elsif ((l.starts_with? " ") && (l.strip.size != 0))
              str << "<p class=\"commit-description\">" << l.strip << "</p>"
            elsif l.starts_with? "diff "
              str << "<p class=\"commit-diff\">" << l << "</p>"
            elsif l.starts_with? "@@"
              str << "<p class=\"commit-lines\">" << l << "</p>"
            elsif ((!l.starts_with? "+++") && (l.starts_with? "+"))
              str << "<p class=\"commit-plus\">" << l << "</p>"
            elsif ((!l.starts_with? "---") && (l.starts_with? "-"))
              str << "<p class=\"commit-minus\">" << l << "</p>"
            else
              str << "<p>" << l << "</p>"
            end
          end
        end

        if overflow
          command = "cd " + project_root + " && git show --name-only " + hash
          io = IO::Memory.new
          Process.run(command, shell: true, output: io)
          date = ""
          result = String.build do |str|
            io.to_s.each_line do |l|
              if l.starts_with? "commit "
                next
              elsif l.starts_with? "Author:"
                next
              elsif l.starts_with? "Date:"
                date = l[5..-1].strip
              elsif ((l.starts_with? " ") && (l.strip.size != 0))
                str << "<p class=\"commit-description\">" << l.strip << "</p>"
                str << "<p class=\"commit-description\">(Only showing the names of files that changed...)</p>"
              else
                str << "<p>" << l << "</p>"
              end
            end
          end
        end

        String.build do |str|
          str << "{"
          str << "\"date\":\"" << date << "\","
          str << "\"content\":" << result.to_json
          str << "}"
        end
      end

      def self.revert_commits(project, hash, email)
        project_root = @@root + "/" + project.path.to_s

        command = "cd \"" + project_root + "\" && git show " + hash
        io = IO::Memory.new
        Process.run(command, shell: true, output: io)
        date = ""
        io.to_s.each_line do |l|
          if l.starts_with? "Date:"
            date = l[5..-1].strip
            break
          end
        end

        command = "cd \"" + project_root + "\""
        command = command + " && git revert --no-commit " + hash + "..HEAD"
        command = command + " && git commit -m\"" + email + " rollbacked to " + date + "\""
        io = IO::Memory.new
        Process.run(command, shell: true, output: io)
      end

      def self.delete_history(project, hash, email)
        project_root = @@root + "/" + project.path.to_s

        command = "cd \"" + project_root + "\" && git show " + hash
        io = IO::Memory.new
        Process.run(command, shell: true, output: io)
        date = ""
        io.to_s.each_line do |l|
          if l.starts_with? "Date:"
            date = l[5..-1].strip
            break
          end
        end

        command = "cd \"" + project_root + "\""
        command = command + " && git checkout --orphan temp " + hash
        command = command + " && git commit -m\"" + email + " truncated history to " + date + "\""
        command = command + " && git rebase --onto temp " + hash + " master"
        command = command + " && git branch -D temp"
        command = command + " && git prune --progress"
        command = command + " && git gc --aggressive"
        puts command
        io = IO::Memory.new
        Process.run(command, shell: true, output: io)
        puts io.to_s
      end
    end
  end
end
