class CreateReposTable < ActiveRecord::Migration
  def change
    create_table :repos do |t|
      t.string   :organization
      t.string   :name
    end
  end
end
