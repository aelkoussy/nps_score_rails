# frozen_string_literal: true

class NetPromoterScore < ApplicationRecord
  require 'jwt'

  validates_presence_of :score, :touchpoint, :respondent_class, :respondent_id, :rated_object_class, :rated_object_id
  validates_inclusion_of :score, in: 0..10

  validates_uniqueness_of :respondent_id, scope: %i[touchpoint rated_object_class rated_object_id]

  scope :promotors, -> { where('score > ?', 8) }
  scope :passives, -> { where('score > ? and score < ?', 6, 8) }
  scope :detractors, -> { where('score < ?', 7) }

  # given these inputs, it will calc and return the nps
  # touchpoint required, others are optional

  # Suggested improvement: use a better search strategy here, maybe Elasticsearch or PostgreSQL FTS
  # or limit all the params to numbers instead of text

  # caching is used for 5 mins to speed up the results retrieval if it is queried heavily
  def self.calc_nps(touchpoint, responder_class = nil, rated_object_class = nil)
    cache_key = 'nps_score/' + touchpoint.to_s + responder_class.to_s + rated_object_class.to_s

    Rails.cache.fetch(cache_key, expires_in: 5.minutes) do
      scores = where(touchpoint: touchpoint)
      unless responder_class.blank?
        scores = scores.where(respondent_class: responder_class)
      end
      unless rated_object_class.blank?
        scores = scores.where(rated_object_class: rated_object_class)
      end

      nps = (scores.promotors.size.to_f / scores.size - scores.detractors.size.to_f / scores.size) * 100
      nps.round(2)
    end
  end

  # Generate a JWT with the claims given
  # TODO: add a sensible default expiry date for this to avoid it being valid forever
  def self.generate_token(touchpoint, respondent_class, respondent_id, rated_object_class, rated_object_id)
    payload = {
      touchpoint: touchpoint,
      respondent_class: respondent_class,
      respondent_id: respondent_id,
      rated_object_class: rated_object_class,
      rated_object_id: rated_object_id
    }
    token = JWT.encode payload, ENV['SECRET_KEY'], 'HS512'
  end

  def self.parse_token(token)
    decoded_token = JWT.decode token, ENV['SECRET_KEY'], true, { algorithm: 'HS512' }
    # .first as the decoded_token is an array having the payload as the first element
    payload = decoded_token&.first
  end
end
