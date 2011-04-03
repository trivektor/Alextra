class CreateUsers < ActiveRecord::Migration
  def self.up
    create_table :users do |t|
      t.string :username
      t.string :email
      t.string :identifier
      t.string :photo_url
    end
  end

  def self.down
    drop_table :users
  end
end
