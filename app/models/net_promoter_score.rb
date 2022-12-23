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
  def self.calc_nps(touchpoint, responder_class, rated_object_class)
    cache_key = "nps_score/#{touchpoint}-#{responder_class}-#{rated_object_class}"

    Rails.cache.fetch(cache_key, expires_in: 5.minutes) do
      scores = where({ touchpoint: touchpoint,
                       respondent_class: responder_class,
                       rated_object_class: rated_object_class }.compact)

      nps = (promotors_average(scores) - detractors_average(scores)) * 100
      nps.round(2)
    end
  end

  def self.promotors_average(scores)
    scores.promotors.size.to_f / scores.size
  end

  def self.detractors_average(scores)
    scores.detractors.size.to_f / scores.size
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
    JWT.encode payload, ENV['SECRET_KEY'], 'HS512'
  end

  def self.parse_token(token)
    decoded_token = JWT.decode token, ENV['SECRET_KEY'], true, { algorithm: 'HS512' }
    # .first as the decoded_token is an array having the payload as the first element
    decoded_token&.first
  end
end
