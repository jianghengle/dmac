require "pg"
require "crecto"
require "kemal"
require "json"
require "crypto/bcrypt/password"
require "oauth2"
require "uuid"

require "./http/models/*"
require "./http/errors/*"
require "./http/controllers/*"
require "./http/middleware/*"
require "./http/templates/*"

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

      get "/globus_authcallback" do |env|
        HttpAPI::GlobusController.authcallback(env)
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

      post "/create_user" do |env|
        HttpAPI::UserController.create_user(env)
      end

      get "/get_projects" do |env|
        HttpAPI::ProjectController.get_projects(env)
      end

      get "/get_public_templates" do |env|
        HttpAPI::ProjectController.get_public_templates(env)
      end

      get "/get_project_controls/:project_id" do |env|
        HttpAPI::ControlController.get_project_controls(env)
      end

      get "/get_project/:project_id" do |env|
        HttpAPI::ProjectController.get_project(env)
      end

      get "/get_meta_by_data_path/:project_id/:data_path" do |env|
        HttpAPI::ProjectController.get_meta_by_data_path(env)
      end

      get "/get_meta_by_template/:project_id" do |env|
        HttpAPI::ProjectController.get_meta_by_template(env)
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

      post "/create_file" do |env|
        HttpAPI::ProjectController.create_file(env)
      end

      post "/update_folder" do |env|
        HttpAPI::ProjectController.update_folder(env)
      end

      post "/update_file" do |env|
        HttpAPI::ProjectController.update_file(env)
      end

      post "/delete_folder_file" do |env|
        HttpAPI::ProjectController.delete_folder_file(env)
      end

      post "/delete_multiple" do |env|
        HttpAPI::ProjectController.delete_multiple(env)
      end

      post "/upload_file/:project_id/:data_path" do |env|
        HttpAPI::ProjectController.upload_file(env)
      end

      get "/get_download_url/:project_id/:data_path" do |env|
        HttpAPI::DownloadController.get_download_url(env)
      end

      get "/get_public_download_url/:public_key/:project_id/:data_path" do |env|
        HttpAPI::DownloadController.get_public_download_url(env)
      end

      get "/download_file/:key" do |env|
        HttpAPI::DownloadController.download_file(env)
      end

      post "/save_text_file" do |env|
        HttpAPI::ProjectController.save_text_file(env)
      end
      post "/copy_folder_file" do |env|
        HttpAPI::ProjectController.copy_folder_file(env)
      end

      post "/unzip_file" do |env|
        HttpAPI::ProjectController.unzip_file(env)
      end

      post "/make_folder_public" do |env|
        HttpAPI::PublicController.make_folder_public(env)
      end

      get "/get_publics/:project_id" do |env|
        HttpAPI::PublicController.get_publics(env)
      end

      post "/remove_folder_public" do |env|
        HttpAPI::PublicController.remove_folder_public(env)
      end

      get "/get_public_file/:public_key/:data_path" do |env|
        HttpAPI::PublicController.get_public_file(env)
      end

      get "/get_logs/:project_id" do |env|
        HttpAPI::GitController.get_logs(env)
      end

      get "/get_commit/:project_id/:hash" do |env|
        HttpAPI::GitController.get_commit(env)
      end

      post "/revert_commits" do |env|
        HttpAPI::GitController.revert_commits(env)
      end

      post "/delete_history" do |env|
        HttpAPI::GitController.delete_history(env)
      end

      post "/commit_history" do |env|
        HttpAPI::GitController.commit_history(env)
      end

      get "/get_channels/:project_id" do |env|
        HttpAPI::ChannelController.get_channels(env)
      end

      get "/get_directories/:project_id" do |env|
        HttpAPI::ChannelController.get_directories(env)
      end

      get "/get_files/:project_id/:path" do |env|
        HttpAPI::ChannelController.get_files(env)
      end

      post "/create_channel" do |env|
        HttpAPI::ChannelController.create_channel(env)
      end

      post "/update_channel" do |env|
        HttpAPI::ChannelController.update_channel(env)
      end

      post "/delete_channel" do |env|
        HttpAPI::ChannelController.delete_channel(env)
      end

      get "/get_meta_by_channel/:project_id/:id" do |env|
        HttpAPI::ChannelController.get_meta_by_channel(env)
      end

      post "/upload_file_by_channel/:project_id/:id" do |env|
        HttpAPI::ChannelController.upload_file_by_channel(env)
      end

      post "/upload_meta_by_channel/:project_id/:id" do |env|
        HttpAPI::ChannelController.upload_meta_by_channel(env)
      end

      post "/search_project_files" do |env|
        HttpAPI::ProjectController.search_files(env)
      end

      post "/search_in_project_file" do |env|
        HttpAPI::ProjectController.search_in_file(env)
      end

      post "/search_public_files" do |env|
        HttpAPI::PublicController.search_files(env)
      end

      post "/search_in_public_file" do |env|
        HttpAPI::PublicController.search_in_file(env)
      end

      post "/list_irods_path" do |env|
        HttpAPI::IrodsController.list_irods_path(env)
      end

      post "/transfer_to_irods" do |env|
        HttpAPI::IrodsController.transfer_to_irods(env)
      end

      post "/transfer_from_irods" do |env|
        HttpAPI::IrodsController.transfer_from_irods(env)
      end

      port = 3000
      port = ENV["DMAC_PORT"].to_i if ENV.has_key?("DMAC_PORT")
      Kemal.run port
    end
  end
end

DMACServer::Server.new
