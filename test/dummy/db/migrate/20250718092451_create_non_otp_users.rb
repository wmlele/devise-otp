class CreateNonOtpUsers < ActiveRecord::Migration[8.0]
  def change
    create_table :non_otp_users do |t|
      t.string :name

      t.timestamps
    end
  end
end
