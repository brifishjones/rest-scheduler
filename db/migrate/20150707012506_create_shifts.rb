class CreateShifts < ActiveRecord::Migration
  def change
    create_table :shifts do |t|
      t.references :manager
      t.references :employee
      t.float :break
      t.datetime :start_time
      t.datetime :end_time

      t.timestamps null: true
    end
  end
end
