class CheckPhotoStatusWorker
  include Sidekiq::Worker

  def perform(id)
    if (photo = Photo.find_by(id: id))
      if photo.uploaded == nil
        photo.uploaded = false
        photo.errorinfo = "Upload job timeout. Please, try again."
        photo.save
      end
    end
  end
end
