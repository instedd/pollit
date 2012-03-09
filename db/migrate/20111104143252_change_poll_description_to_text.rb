class ChangePollDescriptionToText < ActiveRecord::Migration
  def up
    change_column "polls", "description", :text
  end

  def down
    change_column "polls", "description", :string
  end
end
