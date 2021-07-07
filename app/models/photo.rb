class Photo < ApplicationRecord
  belongs_to :user
  has_one_attached :file

  def serverurl
    if self.file.attached?
      Rails.application.routes.url_helpers.url_for(self.file)
    end
  end
end
