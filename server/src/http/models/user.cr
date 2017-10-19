module DMACServer
  module HttpAPI
    class User < Crecto::Model
      schema "users" do
        field :email, String
        field :encrypted_password, String
        field :first_name, String
        field :last_name, String
        field :username, String
        field :auth_token, String
        field :role, String
        validate_required [:email]
      end

      def self.get_token(email : String, password : String)
        user = Repo.get_by(User, email: email)
        raise "Cannot find user" if user.nil?
        raise "Cannot verify password" unless Crypto::Bcrypt::Password.new(user.encrypted_password.not_nil!) == password
        return user.auth_token.to_s
      end

      def self.get_user(token : String)
        user = Repo.get_by(User, auth_token: token)
        raise "Cannot find user" if user.nil?
        return user
      end

      def self.create_user(email : String, password : String, first_name : String, last_name : String)
        old_user = Repo.get_by(User, email: email)
        raise "User existed" unless old_user.nil?

        encrypted_password = Crypto::Bcrypt::Password.create(password)
        raise "failed to encrypted password" if encrypted_password.nil?

        user = User.new
        user.email = email
        user.encrypted_password = encrypted_password.to_s
        user.auth_token = SecureRandom.hex(32).to_s
        user.role = "Subscriber"
        user.first_name = first_name
        user.last_name = last_name
        user.username = Local.create_user(email, password)
        changeset = Repo.insert(user)
        raise changeset.errors.to_s unless changeset.valid?
        return user
      end

      def self.get_user_by_email!(email : String)
        user = Repo.get_by(User, email: email)
        raise "Cannot find user" if user.nil?
        return user
      end

      def self.get_user_by_email(email : String)
        Repo.get_by(User, email: email)
      end

      def self.make_token(email : String)
        user = Repo.get_by(User, email: email)
        auth_token = ""
        if user.nil?
          password = SecureRandom.base64
          user = User.create_user(email, password, "", "")
          auth_token = user.auth_token.to_s
        else
          user = user.as(User)
          user.auth_token = SecureRandom.hex(32).to_s
          changeset = Repo.update(user)
          raise changeset.errors.to_s unless changeset.valid?
          auth_token = user.auth_token.to_s
        end
        return auth_token
      end
    end
  end
end
