class Shift < ActiveRecord::Base
  belongs_to :manager, class_name: 'User'
  belongs_to :employee, class_name: 'User'

  validates :manager, presence: true
  validates :start_time, presence: true
  validates :end_time, presence: true
  validate :start_time_less_than_end_time

  # Compute weekly total hours beginning at midnight on Monday in Time.zone for the specified shifts
  def self.total_weekly_hours(shifts)
    weekly_start_time = Time.zone.now.beginning_of_week
    return [{'week': weekly_start_time.to_date, 'hours': '0'}] if shifts.nil?

    # shifts must be sorted by start time and end time
    shifts = shifts.order(:start_time).order(:end_time)
    weekly_total = []
    weekly_hours = 0.0
    hours_next_week = 0.0

    shifts.each do |s|
      if s.start_time >= weekly_start_time + 7.days
        weekly_total << {'week': weekly_start_time.to_date, 'hours': weekly_hours}
        weekly_start_time += 7.days
        weekly_hours = hours_next_week
        hours_next_week = 0.0
      end
      if s.end_time >= weekly_start_time + 7.days  # special case: shift starts on Sunday, ends on Monday 
        weekly_hours += ((weekly_start_time + 7.days) - s.start_time) / 3600.0
        hours_next_week += (s.end_time - (weekly_start_time + 7.days)) / 3600.0
      else
        weekly_hours += (s.end_time - s.start_time) / 3600.0
      end
    end

    weekly_total << {'week': weekly_start_time.to_date, 'hours': weekly_hours}
    weekly_total << {'week': (weekly_start_time + 7.days).to_date, 'hours': hours_next_week} if hours_next_week > 0.0  # special case: last shift starts on Sunday, ends on Monday
    return weekly_total
  end


  private

  def start_time_less_than_end_time
    if start_time.present? && end_time.present?
      errors.add(:end_time, "cannot be before start time") if start_time > end_time
      errors.add(:end_time, "shift length cannot be zero") if start_time == end_time
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
