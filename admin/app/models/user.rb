class User < ApplicationRecord
  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable, :omniauthable, :registerable
  devise :database_authenticatable, :recoverable, :rememberable, :trackable, :validatable, :lockable

  before_create :set_auth_token

  def set_auth_token
    self[:auth_token] = SecureRandom.hex(16)
  end

  rails_admin do
    edit do
      field :email
      field :password
      field :password_confirmation
      field :auth_token
      field :first_name
      field :last_name
      field :username
      field :role, :enum do
        enum do
          ['Admin', 'Manager', 'Subscriber']
        end
      end
      field :reset_password_token
    end
  end

  def reset_password(new_password, new_password_confirmation)
    super(new_password, new_password_confirmation)
    return unless new_password == new_password_confirmation
    return unless ENV.has_key? "DMAC_PERMISSION"
    perm = ENV["DMAC_PERMISSION"]
    return unless perm == "local"
    system("sudo usermod --password $(echo " + new_password + " | openssl passwd -1 -stdin) " + self[:username])
  end

end
