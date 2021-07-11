class User < ApplicationRecord
    has_many :photos, :dependent => :destroy
    validates :uuid, uniqueness: true
    validates :token, uniqueness: true
end
