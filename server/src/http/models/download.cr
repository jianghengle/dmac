module DMACServer
  module HttpAPI
    class Download < Crecto::Model
      schema "downloads" do
        field :key, String
        field :project_key, String
        field :data_path, String
      end

      def to_url()
        result = String.build do |str|
          str << "/download_file/"
          str << @key
        end
        result
      end

      def self.create_download(project_key, data_path)
        download = Download.new
        download.key = SecureRandom.hex(32).to_s
        download.project_key = project_key
        download.data_path = data_path
        changeset = Repo.insert(download)
        raise changeset.errors.to_s unless changeset.valid?
        return download
      end

      def self.get_download(key)
        download = Repo.get_by(Download, key: key)
        raise "cannot find download" if download.nil?
        download = download.as(Download)
        now = Time.now
        span = now - download.created_at.as(Time)
        return download if span.total_minutes < 60
        Repo.delete(download)
        raise "download expired"
      end



    end
  end
end
