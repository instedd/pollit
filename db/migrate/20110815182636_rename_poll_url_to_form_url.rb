class RenamePollUrlToFormUrl < ActiveRecord::Migration
  def up
    rename_column :polls, :url, :form_url
  end

  def down
    rename_column :polls, :form_url, :url
  end
end
