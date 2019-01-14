module DMACServer
  module HttpAPI
    class Download < Crecto::Model
      schema "downloads" do
        field :key, String
        field :project_key, String
        field :data_path, String
      end

      def to_url
        result = String.build do |str|
          str << "/download_file/"
          str << @key
        end
        result
      end

      def self.create_download(project_key, data_path)
        download = Download.new
        download.key = Random::Secure.urlsafe_base64(32).to_s
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

      def self.clean_downloads
        query = Query.new
        downloads = Repo.all(Download, query)
        return if downloads.nil?
        downloads = downloads.as(Array)
        now = Time.now
        download_ids = [] of Int8 | Int16 | Int32 | Int64 | String | Nil
        downloads.each do |download|
          download = download.as(Download)
          span = now - download.created_at.as(Time)
          next if span.total_minutes < 60
          download_ids << download.id
        end
        return if download_ids.empty?
        query = Query.where(:id, download_ids)
        Repo.delete_all(Download, query)
      end
    end
  end
end
