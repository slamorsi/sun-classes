class ClassAssignment < ActiveRecord::Base
  belongs_to :sun_class, :counter_cache => true
  belongs_to :student
end
