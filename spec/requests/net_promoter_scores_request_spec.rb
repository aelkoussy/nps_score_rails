# frozen_string_literal: true

require 'rails_helper'

# By passing the params in a JWT to the user, we guarantee that no one can modify the params, the only param that can be adjusted is the score

token = NetPromoterScore.generate_token(
  'realtor_feedback',
  'seller',
  '1523',
  'realtor',
  '421'
)

array_of_nps = [{ score: 9, respondent_id: '1523', touchpoint: 'realtor_feedback', respondent_class: 'seller', rated_object_class: 'realtor', rated_object_id: '421' },
                { score: 10, respondent_id: '2412', touchpoint: 'realtor_feedback', respondent_class: 'seller', rated_object_class: 'realtor', rated_object_id: '421' },
                { score: 3, respondent_id: '2415', touchpoint: 'realtor_feedback', respondent_class: 'seller', rated_object_class: 'realtor', rated_object_id: '421' },
                { score: 8, respondent_id: '2444', touchpoint: 'realtor_feedback', respondent_class: 'seller', rated_object_class: 'realtor', rated_object_id: '421' },
                { score: 9, respondent_id: '2745', touchpoint: 'realtor_feedback', respondent_class: 'seller', rated_object_class: 'realtor', rated_object_id: '421' },
                { score: 9, respondent_id: '6234', touchpoint: 'realtor_feedback', respondent_class: 'seller', rated_object_class: 'realtor', rated_object_id: '421' },
                { score: 9, respondent_id: '4213', touchpoint: 'realtor_feedback', respondent_class: 'seller', rated_object_class: 'realtor', rated_object_id: '421' },
                { score: 9, respondent_id: '15123', touchpoint: 'realtor_feedback', respondent_class: 'buyer', rated_object_class: 'realtor', rated_object_id: '421' },
                { score: 9, respondent_id: '12512', touchpoint: 'realtor_feedback', respondent_class: 'buyer', rated_object_class: 'realtor', rated_object_id: '421' }]

NetPromoterScore.create(array_of_nps)

RSpec.describe 'add a NPS:', type: :request do
  it 'throw exception if param is missing' do
    post '/api/v1/net_promoter_scores', params: {
      score: 9
    }
    expect(response).to have_http_status(:bad_request)
  end

  it 'returns an ok status if record is valid and added' do
    post '/api/v1/net_promoter_scores', params: {
      score: 9,
      token: token
    }
    expect(response).to have_http_status(:ok)
  end
end

RSpec.describe 'add a NPS that was created before (shall update the record not create)', type: :request do
  before do
    post '/api/v1/net_promoter_scores', params: {
      score: 5,
      token: token
    }
  end

  it 'returns an ok status if record is updated' do
    expect(response).to have_http_status(:ok)
  end
end

RSpec.describe 'Get NPS with given params: ', type: :request do
  it 'returns an ok status if touchpoint is given and returns a correct number' do
    get '/api/v1/net_promoter_scores/', params: {
      touchpoint: 'realtor_feedback'
    }
    expect(response).to have_http_status(:ok)
    expect(response.body).to eq('66.67')
  end

  it 'returns an ok status if touchpoint & respondent_class are given and returns a correct number' do
    get '/api/v1/net_promoter_scores/', params: {
      touchpoint: 'realtor_feedback',
      respondent_class: 'buyer'
    }
    expect(response).to have_http_status(:ok)
    expect(response.body).to eq('100.0')
  end
  it 'returns an ok status if all params are given and returns a correct number' do
    get '/api/v1/net_promoter_scores/', params: {
      touchpoint: 'realtor_feedback',
      respondent_class: 'seller',
      rated_object_class: 'realtor'
    }
    expect(response).to have_http_status(:ok)
    expect(response.body).to eq('57.14')
  end
  it 'returns bad_request status if touchpoint is missing' do
    get '/api/v1/net_promoter_scores/'
    expect(response).to have_http_status(:bad_request)
  end
end
