class ChangeConfirmationWordToWordsInPoll < ActiveRecord::Migration

  class MigrationPoll < ActiveRecord::Base
    self.table_name = "polls"
    serialize :confirmation_words, Array
  end

  def up
    add_column :polls, :confirmation_words, :text

    MigrationPoll.find_each do |poll|
      poll.confirmation_words = [poll.confirmation_word]
      poll.save!
    end

    remove_column :polls, :confirmation_word
  end

  def down
    add_column :polls, :confirmation_word, :string

    MigrationPoll.find_each do |poll|
      poll.confirmation_word = poll.confirmation_words.first
      poll.save!
    end

    remove_column :polls, :confirmation_words
  end
end
