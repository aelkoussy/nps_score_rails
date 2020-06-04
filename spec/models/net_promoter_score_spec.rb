# frozen_string_literal: true

require 'rails_helper'

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
  end
end
