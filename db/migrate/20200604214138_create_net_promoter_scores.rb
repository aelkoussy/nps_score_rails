class CreateNetPromoterScores < ActiveRecord::Migration[6.0]
  def change
    create_table :net_promoter_scores do |t|
      t.integer :score
      t.string :touchpoint
      t.string :respondent_class
      t.integer :respondent_id
      t.string :rated_object_class
      t.integer :rated_object_id

      t.timestamps
    end
  end
end
