class SetDefaultValueForRespondent < ActiveRecord::Migration
  def up
    change_table :respondents do |t|
      t.change :current_question_sent, :boolean, :default => false, :null => false
      t.change :confirmed, :boolean, :default => false, :null => false
      # t.change_default :current_question_sent, false
      # t.change :current_question_sent, :null => false
      # t.change_default :confirmed, false
      # t.change :confirmed, :null => false
    end
  end

  def down
    change_table :respondents do |t|
      t.change :current_question_sent, :boolean, :default => nil, :null => true
      t.change :confirmed, :boolean, :default => nil, :null => true
      # t.change_default :current_question_sent, nil
      # # t.change :current_question_sent, :null => true
      # t.change_default :confirmed, nil
      # # t.change :confirmed, :null => true
    end
  end
end
