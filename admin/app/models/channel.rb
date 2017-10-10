class Channel < ApplicationRecord
  belongs_to :project

  rails_admin do
    edit do
      field :project
      field :path
      field :meta_data
      field :instruction
      field :files
      field :rename
    end
  end
end
