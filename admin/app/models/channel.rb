class Channel < ApplicationRecord
  belongs_to :project

  rails_admin do
    edit do
      field :project
      field :name
      field :path
      field :meta_data
      field :instruction
      field :files
      field :file_filter
      field :rename
      field :status, :enum do
        enum do
          ['Open', 'Closed']
        end
      end
    end
  end
end
