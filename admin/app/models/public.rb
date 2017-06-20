class Public < ApplicationRecord
  belongs_to :project

  rails_admin do
    edit do
      field :project
      field :key
      field :data_path
      field :path
    end
  end
end
