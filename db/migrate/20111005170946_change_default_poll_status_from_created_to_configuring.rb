class ChangeDefaultPollStatusFromCreatedToConfiguring < ActiveRecord::Migration
  def up
    Poll.update_all ['status = ?', 'configuring'], "status IS NULL OR status='created'"
  end

  def down
    Poll.update_all ['status = ?', 'created'], "status='configuring'"
  end
end
