module DMACServer
  module HttpAPI
    class User < Crecto::Model
      schema "users" do
        field :email, String
        field :encrypted_password, String
        field :first_name, String
        field :last_name, String
        field :auth_token, String
        
        validate_required [:email]
      end

      def self.get_token(email : String, password : String)
        user = Repo.get_by(User, email: email)
        raise "Cannot find user" if user.nil?
        raise "Cannot verify password" unless Crypto::Bcrypt::Password.new(user.encrypted_password.not_nil!) == password
        return user.auth_token
      end

      def self.get_user(token : String)
        user = Repo.get_by(User, auth_token: token)
        raise "Cannot find user" if user.nil?
        return user
      end

    end
  end
end
