require "pg"
require "crecto"
require "json"

require "./http/models/*"


module Repo
  extend Crecto::Repo

  config do |conf|
    conf.adapter = Crecto::Adapters::Postgres
    conf.uri = ENV["PG_URL"]
  end
end
Query = Crecto::Repo::Query

module DMACServer
  class Cleaner
    def initialize
      DMACServer::HttpAPI::MyFile.clean_temp
      DMACServer::HttpAPI::Download.clean_downloads
    end
  end
end

DMACServer::Cleaner.new
