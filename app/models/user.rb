class User < ActiveRecord::Base
has_many :games
has_many :words, through: :games
end
