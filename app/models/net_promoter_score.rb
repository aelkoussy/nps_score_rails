# frozen_string_literal: true

class NetPromoterScore < ApplicationRecord
  validates_presence_of :score, :touchpoint, :respondent_class, :respondent_id, :rated_object_class, :rated_object_id

  validates_inclusion_of :score, in: 0..10
end
