class AddIndexRespondentsByAoMessageGuid < ActiveRecord::Migration
  def up
    add_index :respondents, :ao_message_guid, :unique => true
  end
end
