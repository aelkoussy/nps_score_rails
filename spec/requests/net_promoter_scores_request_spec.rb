# frozen_string_literal: true

require 'rails_helper'
require 'jwt'

payload = {
  touchpoint: 'realtor_feedback',
  respondent_class: 'seller',
  respondent_id: '1523',
  rated_object_class: 'realtor',
  rated_object_id: '421'
}

token = JWT.encode payload, ENV['SECRET_KEY'], 'HS512'

RSpec.describe 'add a NPS:', type: :request do
  it 'throw exception if param is missing' do
    post '/net_promoter_scores', params: {
      score: 9
      # token: token
    }
    expect(response).to have_http_status(:bad_request)
  end

  it 'returns a created status' do
    post '/net_promoter_scores', params: {
      score: 9,
      token: token
    }
    expect(response).to have_http_status(:created)
  end
end

RSpec.describe 'add a NPS that was created before (shall be update instead of create', type: :request do
  before do
    post '/net_promoter_scores', params: {
      score: 5,
      token: token
    }
  end

  it 'returns an ok status' do
    expect(response).to have_http_status(:created)
  end
end

RSpec.describe 'update a NPS: ', type: :request do
  before do
    put '/net_promoter_scores/1', params: {
      score: 7,
      token: token
    }
  end

  it 'returns an ok status' do
    expect(response).to have_http_status(:ok)
  end
end
