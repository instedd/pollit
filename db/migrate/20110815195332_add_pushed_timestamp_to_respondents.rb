class AddPushedTimestampToRespondents < ActiveRecord::Migration
  def change
    add_column :respondents, :pushed_at, :datetime
  end
end
