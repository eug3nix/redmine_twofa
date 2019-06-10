class AddTotpToUser < ActiveRecord::Migration
  def change
    add_column :users, :twofa_totp_key, :string
    add_column :users, :twofa_totp_last_used_at, :integer
  end
end
