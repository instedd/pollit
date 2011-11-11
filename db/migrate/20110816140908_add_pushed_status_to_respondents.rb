class AddPushedStatusToRespondents < ActiveRecord::Migration
  def change
    add_column :respondents, :pushed_status, :string
  end
end
