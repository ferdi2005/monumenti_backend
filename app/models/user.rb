class User < ApplicationRecord
    has_many :photos, :dependent => :destroy

    encrypts :authinfo, type: :hash, migrating: true
end
