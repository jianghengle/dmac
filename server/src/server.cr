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

      get "/get_project_controls/:project_id" do |env|
        HttpAPI::ControlController.get_project_controls(env)
      end

      get "/get_project/:project_id" do |env|
        HttpAPI::ProjectController.get_project(env)
      end

      get "/get_file/:project_id/:data_path" do |env|
        HttpAPI::ProjectController.get_file(env)
      end

      post "/create_project" do |env|
        HttpAPI::ProjectController.create_project(env)
      end

      post "/update_project" do |env|
        HttpAPI::ProjectController.update_project(env)
      end

      post "/delete_project" do |env|
        HttpAPI::ProjectController.delete_project(env)
      end

      post "/add_project_control" do |env|
        HttpAPI::ControlController.add_project_control(env)
      end

      post "/update_project_control" do |env|
        HttpAPI::ControlController.update_project_control(env)
      end

      post "/delete_project_control" do |env|
        HttpAPI::ControlController.delete_project_control(env)
      end

      post "/create_folder" do |env|
        HttpAPI::ProjectController.create_folder(env)
      end

      post "/update_folder_file_name" do |env|
        HttpAPI::ProjectController.update_folder_file_name(env)
      end

      post "/delete_folder_file" do |env|
        HttpAPI::ProjectController.delete_folder_file(env)
      end

      post "/upload_file/:project_id/:data_path" do |env|
        HttpAPI::ProjectController.upload_file(env)
      end

      Kemal.run
      end
  end
end

DMACServer::Server.new
