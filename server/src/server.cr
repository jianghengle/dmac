require "pg"
require "crecto"
require "kemal"
require "json"
require "crypto/bcrypt/password"

require "./http/models/*"
require "./http/errors/*"
require "./http/controllers/*"
require "./http/middleware/*"


module Repo
  extend Crecto::Repo

  config do |conf|
    conf.adapter = Crecto::Adapters::Postgres
    conf.uri = ENV["PG_URL"]
  end
end
Query = Crecto::Repo::Query

module DMACServer
    class Server
        def initialize
            # Middlewares
            add_handler DMACServer::HttpAPI::ApiHandler.new
            
            get "/" do |env|
               env.redirect "/index.html"
            end

            post "/get_auth_token" do |env|
                HttpAPI::UserController.get_auth_token(env)
            end

            post "/get_token" do |env|
                HttpAPI::UserController.get_token(env)
            end

            post "/get_user" do |env|
                HttpAPI::UserController.get_user(env)
            end

            get "/get_projects" do |env|
                HttpAPI::ProjectController.get_projects(env)
            end

            get "/get_project/:project_id" do |env|
                HttpAPI::ProjectController.get_project(env)
            end

            get "/get_file/:project_id/:data_path" do |env|
                HttpAPI::ProjectController.get_file(env)
            end

            Kemal.run
        end
    end
end

DMACServer::Server.new