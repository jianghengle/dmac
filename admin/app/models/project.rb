class Project < ApplicationRecord
  before_create :set_key

  def set_key
    self[:key] = SecureRandom.hex(16)
  end

  rails_admin do
    edit do
      field :name
      field :description
      field :status, :enum do
        enum do
          ['active', 'archived']
        end
      end
      field :key
    end
  end
end
