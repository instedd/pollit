class AddHubSourceToRespondents < ActiveRecord::Migration
  def change
    add_column :respondents, :hub_source, :string
  end
end
