class CreateTableUsers < ActiveRecord::Migration[5.1]
  def change
    create_table :users do |t|
    	t.string :mobile_number, null: false, unique: true
    	t.string :otp
    	t.datetime :otp_expires_at

    	t.timestamps null: false
    end
  end
end
