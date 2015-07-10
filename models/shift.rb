class Shift < ActiveRecord::Base
  belongs_to :manager, class_name: 'User'
  belongs_to :employee, class_name: 'User'

  validates :manager, presence: true
end


# == Schema Information
#
# Table name: shifts
#
#  id               :integer(4)      not null, primary key
#  manager_id       :integer(4)      foreign key
#  employee_id      :integer(4)      foreign key
#  break            :float
#  start_time       :datetime
#  end_time         :datetime
#  created_at       :datetime
#  updated_at       :datetime
