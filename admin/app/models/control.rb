class Control < ApplicationRecord
  belongs_to :project

  rails_admin do
    edit do
      field :project
      field :email
      field :role, :enum do
        enum do
          ['Owner', 'Admin', 'Editor', 'Viewer']
        end
      end
    end
  end
end
