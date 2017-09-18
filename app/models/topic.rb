class Topic < ActiveRecord::Base
  # validates_presence_of :image, :content

  belongs_to :user
  has_many :image_labels, dependent: :destroy

  mount_uploader :image, ImageUploader
end
