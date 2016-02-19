class AddAoMessageStateToRespondents < ActiveRecord::Migration
  def change
    add_column :respondents, :ao_message_state, :string
  end
end
