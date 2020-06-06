# frozen_string_literal: true

class AddIndexForNpsUniqueness < ActiveRecord::Migration[6.0]
  def change
    add_index :net_promoter_scores, %i[respondent_id touchpoint rated_object_class rated_object_id], unique: true, name: 'nps_index'
  end
end
