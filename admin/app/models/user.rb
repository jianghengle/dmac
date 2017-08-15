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
      field :role, :enum do
        enum do
          ['Admin', 'Manager', 'Subscriber']
        end
      end
      field :reset_password_token
    end
  end
end
