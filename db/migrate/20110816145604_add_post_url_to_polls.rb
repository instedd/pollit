class AddPostUrlToPolls < ActiveRecord::Migration
  def change
    add_column :polls, :post_url, :string
  end
end
