# frozen_string_literal: true

class NetPromoterScoresController < ApplicationController
  before_action :nps_params, only: %i[create update]

  def index; end

  def create
    # here we will use OK status for created and updated records for simplicity
    if @nps.save
      render json: @nps, status: :ok
    else
      render json: { error: 'something went wrong' }, status: :bad_request
    end
  end

  def update
    if @nps.save
      render json: @nps, status: :ok
    else
      render json: { error: 'something went wrong' }, status: :bad_request
    end
  end

  private

  def check_token
    @decoded_token = JWT.decode @token, ENV['SECRET_KEY'], true, { algorithm: 'HS512' }
    @payload = @decoded_token&.first

    @nps = NetPromoterScore.find_or_initialize_by(@payload)
    @nps.score = @score
  end

  def nps_params
    @score = params.require(:score)
    @token = params.require(:token)
    check_token
  end

  rescue_from ActionController::ParameterMissing do |e|
    render json: { error: e.message }, status: :bad_request
  end
end
