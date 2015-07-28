class Shift < ActiveRecord::Base
  belongs_to :manager, class_name: 'User'
  belongs_to :employee, class_name: 'User'

  validates :break , numericality: true
  validates :start_time, presence: true
  validates :end_time, presence: true
  validates :manager_id, presence: true
  validate :manager_id_exists
  validate :employee_id_exists
  validate :start_time_less_than_end_time
  validate :employee_id_scheduling_conflict

  # Compute weekly total hours beginning at midnight on Monday in Time.zone for the specified shifts
  def self.total_weekly_hours(shifts)
    return [{'week': Time.zone.now.beginning_of_week.to_date, 'hours': '0'}] if shifts.nil?

    # shifts must be sorted by start time and end time
    shifts = shifts.order(:start_time).order(:end_time)
    weekly_start_time = shifts.first.start_time.beginning_of_week
    weekly_total = []
    weekly_hours = 0.0
    hours_next_week = 0.0

    shifts.each do |s|
      if hours_next_week > 0.0 && s.start_time >= weekly_start_time + 14.days 
        # special case: shift starts on Sunday, ends on Monday and no shifts the following week 
        weekly_total << {'week': (weekly_start_time + 7.days).to_date, 'hours': hours_next_week}
        weekly_start_time = s.start_time.beginning_of_week 
        weekly_hours = 0.0
        hours_next_week = 0.0
      elsif s.start_time >= weekly_start_time + 7.days
        weekly_total << {'week': weekly_start_time.to_date, 'hours': weekly_hours}
        weekly_start_time = s.start_time.beginning_of_week 
        weekly_hours = hours_next_week
        hours_next_week = 0.0
      end

      if s.end_time >= weekly_start_time + 7.days
        # special case: shift starts on Sunday, ends on Monday
        weekly_hours += ((weekly_start_time + 7.days) - s.start_time) / 3600.0
        hours_next_week += (s.end_time - (weekly_start_time + 7.days)) / 3600.0
      else
        weekly_hours += (s.end_time - s.start_time) / 3600.0
      end
    end

    weekly_total << {'week': weekly_start_time.to_date, 'hours': weekly_hours}
    # special case: last shift starts on Sunday, ends on Monday
    weekly_total << {'week': (weekly_start_time + 7.days).to_date, 'hours': hours_next_week} if hours_next_week > 0.0
    return weekly_total
  end


  private

  def manager_id_exists
    return unless manager_id.present?   # manager_id is required but presence already been checked
    unless User.where(role: 'manager').find_by_id(manager_id)
      errors.add(:manager_id, "must be a valid manager")
    end
  end

  def employee_id_exists
    return unless employee_id.present?   # employee_id is not required
    unless User.where(role: 'employee').find_by_id(employee_id)
      errors.add(:employee_id, "must be a valid employee")
    end
  end

  def start_time_less_than_end_time
    if start_time.present? && end_time.present?
      errors.add(:end_time, "cannot be before start time") if start_time > end_time
      errors.add(:end_time, "shift length cannot be zero") if start_time == end_time
    end
  end

  def employee_id_scheduling_conflict
    return unless employee_id.present? && start_time.present? && end_time.present?
    id_update = id.present? ? id : -1   # id is not present when new record is being saved
    unless Shift.where('id != ? and employee_id = ? and (start_time >= ? and start_time < ? or end_time > ? and end_time <= ?)', id_update, employee_id, start_time, end_time, start_time, end_time).first.nil?
      errors.add(:employee_id, "user is already scheduled during this time period")
    end
  end

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
