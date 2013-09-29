class Preference < ActiveRecord::Base
  belongs_to :sun_class
  belongs_to :student
end
