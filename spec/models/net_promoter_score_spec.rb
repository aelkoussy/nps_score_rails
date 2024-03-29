# frozen_string_literal: true

require 'rails_helper'
require 'jwt'

# based on the given example in the readme

# Assumptions:
# I assumed here the ids to be normal integers referring maybe to other tables
# To avoid using a ruby reserved words (object_class, object_id), we will use rated_object_class & rated_object_id

RSpec.describe NetPromoterScore, type: :model do
  subject do
    described_class.new(
      score: 9,
      touchpoint: 'realtor_feedback',
      respondent_class: 'seller',
      respondent_id: '4214',
      rated_object_class: 'realtor',
      rated_object_id: '123'
    )
  end

  array_of_nps = [{ score: 9, respondent_id: '1523', touchpoint: 'realtor_feedback', respondent_class: 'seller', rated_object_class: 'realtor', rated_object_id: '421' },
                  { score: 10, respondent_id: '2412', touchpoint: 'realtor_feedback', respondent_class: 'seller',
                    rated_object_class: 'realtor', rated_object_id: '421' },
                  { score: 3, respondent_id: '2415', touchpoint: 'realtor_feedback', respondent_class: 'seller',
                    rated_object_class: 'realtor', rated_object_id: '421' },
                  { score: 8, respondent_id: '2444', touchpoint: 'realtor_feedback', respondent_class: 'seller',
                    rated_object_class: 'realtor', rated_object_id: '421' },
                  { score: 9, respondent_id: '2745', touchpoint: 'realtor_feedback', respondent_class: 'seller',
                    rated_object_class: 'realtor', rated_object_id: '421' },
                  { score: 9, respondent_id: '6234', touchpoint: 'realtor_feedback', respondent_class: 'seller',
                    rated_object_class: 'realtor', rated_object_id: '421' },
                  { score: 9, respondent_id: '4213', touchpoint: 'realtor_feedback', respondent_class: 'seller',
                    rated_object_class: 'realtor', rated_object_id: '421' },
                  { score: 9, respondent_id: '15123', touchpoint: 'realtor_feedback', respondent_class: 'buyer',
                    rated_object_class: 'realtor', rated_object_id: '421' },
                  { score: 9, respondent_id: '12512', touchpoint: 'realtor_feedback', respondent_class: 'buyer',
                    rated_object_class: 'realtor', rated_object_id: '421' }]

  NetPromoterScore.create(array_of_nps)

  it 'is valid with valid attributes' do
    expect(subject).to be_valid
  end

  describe 'Validations' do
    it { should validate_presence_of(:score) }
    it { should validate_presence_of(:touchpoint) }
    it { should validate_presence_of(:respondent_class) }
    it { should validate_presence_of(:respondent_id) }
    it { should validate_presence_of(:rated_object_class) }
    it { should validate_presence_of(:rated_object_id) }

    it { should validate_inclusion_of(:score).in_range(0..10) }

    # validates uniqueness of all given params
    it { should validate_uniqueness_of(:respondent_id).scoped_to(:touchpoint, :rated_object_class, :rated_object_id) }
  end

  describe '.calc_nps' do
    it 'filters the scores based on given params and gets the calculated nps' do
      nps_score = described_class.calc_nps('realtor_feedback', 'seller', 'realtor')
      expect(nps_score).to eq(57.14)
    end
  end

  # Declaring variables for the jwt methods in the model
  model_payload = {
    touchpoint: 'realtor_feedback',
    respondent_class: 'seller',
    respondent_id: '1523',
    rated_object_class: 'realtor',
    rated_object_id: '421'
  }
  model_token = JWT.encode model_payload, ENV['SECRET_KEY'], 'HS512'

  # Testing the jwt methods for this class
  describe '.generate_token' do
    it 'generates a jwt based on given params' do
      token = described_class.generate_token(
        'realtor_feedback',
        'seller',
        '1523',
        'realtor',
        '421'
      )

      expect(token).to eq(model_token)
    end
  end
  describe '.parse_token' do
    it 'parse a given token and returns the payload' do
      payload = described_class.parse_token(model_token)

      expect(payload['touchpoint']).to eq('realtor_feedback')
      expect(payload['respondent_class']).to eq('seller')
      expect(payload['respondent_id']).to eq('1523')
      expect(payload['rated_object_class']).to eq('realtor')
      expect(payload['rated_object_id']).to eq('421')
    end
  end
end
