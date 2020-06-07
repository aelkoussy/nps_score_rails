# frozen_string_literal: true

class NetPromoterScore < ApplicationRecord
  validates_presence_of :score, :touchpoint, :respondent_class, :respondent_id, :rated_object_class, :rated_object_id
  validates_inclusion_of :score, in: 0..10

  validates_uniqueness_of :respondent_id, scope: %i[touchpoint rated_object_class rated_object_id]

  scope :promotors, -> { where('score > ?', 8) }
  scope :passives, -> { where('score > ? and score < ?', 6, 8) }
  scope :detractors, -> { where('score < ?', 6) }

  # given these inputs, it will calc and return the nps
  # touchpoint required, others are optional
  def self.calc_nps(touchpoint, responder_class = nil, rated_object_class = nil)
    scores = where(touchpoint: touchpoint)
    unless responder_class.blank?
      scores = scores.where(respondent_class: responder_class)
    end
    unless rated_object_class.blank?
      scores = scores.where(rated_object_class: rated_object_class)
    end

    nps = (scores.promotors.count.to_f / scores.count - scores.detractors.count.to_f / scores.count).round(2) * 100
  end
end
