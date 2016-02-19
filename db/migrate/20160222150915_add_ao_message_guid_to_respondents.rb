class AddAoMessageGuidToRespondents < ActiveRecord::Migration
  def change
    add_column :respondents, :ao_message_guid, :string
  end
end
