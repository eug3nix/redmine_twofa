class AddTwofaSchemeToUser < ActiveRecord::Migration
  def change
    add_column :users, :twofa_scheme, :string
  end
end
