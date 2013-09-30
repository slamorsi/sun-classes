class Student < ActiveRecord::Base
  has_many :class_assignments, :dependent => :destroy
  has_many :classes, :through => :class_assignments

  has_many :wait_list_assignment, :dependent => :destroy
  has_many :wait_list_classes, :class_name => SunClass, :through => :wait_list_assignment

  has_many :preferences, :dependent => :destroy 
end
