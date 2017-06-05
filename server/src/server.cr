require "pg"
require "crecto"
require "kemal"
require "json"
require "crypto/bcrypt/password"

require "./http/models/*"
require "./http/errors/*"
require "./http/controllers/*"
require "./http/middleware/*"


# Shortcut variables
Repo  = Crecto::Repo
Query = Crecto::Repo::Query

module DMACServer
    class Server
        def initialize
            
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

            Kemal.run
        end
    end
end

DMACServer::Server.new