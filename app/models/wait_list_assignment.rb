class WaitListAssignment < ActiveRecord::Base
  belongs_to :sun_class, :counter_cache => true
  belongs_to :student

  REASONS = {
    full: 'Class is full.',
    invalid_hours: 'Was not able to place in both hours for this day.'
  }
end
