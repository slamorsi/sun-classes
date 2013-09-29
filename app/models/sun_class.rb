class SunClass < ActiveRecord::Base
  has_many :class_alignments
  has_many :students, :through => :class_alignments

  has_many :wait_list_assignments
  has_many :wait_list_students, :class_name => Student, :through => :wait_list_assignments

  has_many :preferences
end
