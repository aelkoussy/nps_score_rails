# frozen_string_literal: true

require 'rails_helper'
require 'jwt'

# By passing the params in a JWT to the user, we guarantee that no one can modify the params, the only param that can be adjusted is the score

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
    }
    expect(response).to have_http_status(:bad_request)
  end

  it 'returns an ok status if record is valid and added' do
    post '/net_promoter_scores', params: {
      score: 9,
      token: token
    }
    expect(response).to have_http_status(:ok)
  end
end

RSpec.describe 'add a NPS that was created before (shall update the record not create)', type: :request do
  before do
    post '/net_promoter_scores', params: {
      score: 5,
      token: token
    }
  end

  it 'returns an ok status if record is updated' do
    expect(response).to have_http_status(:ok)
  end
end

RSpec.describe 'update a NPS: ', type: :request do
  before do
    put '/net_promoter_scores/1', params: {
      score: 7,
      token: token
    }
  end

  it 'returns an ok status if the record is updated' do
    expect(response).to have_http_status(:ok)
  end
end
