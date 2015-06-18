class AddKindToPolls < ActiveRecord::Migration
  def change
    add_column :polls, :kind, :string, default: 'gforms'
  end
end
