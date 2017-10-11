class Project < ApplicationRecord
  after_create :set_key

  def set_key
    self[:key] = self.id.to_s
    self.save!
  end

  rails_admin do
    edit do
      field :name
      field :description
      field :status, :enum do
        enum do
          ['Active', 'Archived', 'Template', 'Public Template']
        end
      end
      field :key
      field :path
      field :meta_data
    end
  end
end
