class SetDefaultValueForRespondent < ActiveRecord::Migration
  def up
    change_table :respondents do |t|
      t.change :current_question_sent, :boolean, :default => false, :null => false
      t.change :confirmed, :boolean, :default => false, :null => false
    end
  end

  def down
    change_table :respondents do |t|
      t.change :current_question_sent, :boolean, :default => nil, :null => true
      t.change :confirmed, :boolean, :default => nil, :null => true
    end
  end
end
