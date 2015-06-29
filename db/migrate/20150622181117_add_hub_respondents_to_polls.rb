class AddHubRespondentsToPolls < ActiveRecord::Migration
  def change
    add_column :polls, :hub_respondents_path, :string
    add_column :polls, :hub_respondents_phone_field, :string
  end
end
