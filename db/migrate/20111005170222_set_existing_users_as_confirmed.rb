class SetExistingUsersAsConfirmed < ActiveRecord::Migration
  def up
    User.update_all ['confirmed_at = ?', 1.day.ago], 'confirmed_at IS NULL'
  end

  def down
  end
end
