class AddConfirmedToRespondents < ActiveRecord::Migration
  def change
    add_column :respondents, :confirmed, :bool
  end
end
