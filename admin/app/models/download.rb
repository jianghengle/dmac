class Download < ApplicationRecord

  rails_admin do
    edit do
      field :key
      field :project_key
      field :data_path
    end
  end
end
