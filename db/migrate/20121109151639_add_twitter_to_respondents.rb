class AddTwitterToRespondents < ActiveRecord::Migration
  def change
    add_column :respondents, :twitter, :string
  end
end
