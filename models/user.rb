class User < ActiveRecord::Base
  has_many :managers, class_name: "Shift", foreign_key: "manager_id", through: :shifts
  has_many :employees, class_name: "Shift", foreign_key: "employee_id", through: :shifts

  validates :name, presence: true
  validates :role, inclusion: { in: %w(employee manager)}
  # At least one of email or phone must be present
  validates :email, presence: true, unless: ->(user){user.phone.present?}
  validates :phone, presence: true, unless: ->(user){user.email.present?}
end

# == Schema Information
#
# Table name: users
#
#  id               :integer(4)      not null, primary key
#  name             :string(255)
#  role             :string(255)     either "manager" or "employee"
#  email            :string(255)
#  phone            :string(255)
#  created_at       :datetime
#  updated_at       :datetime
