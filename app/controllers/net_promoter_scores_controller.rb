# frozen_string_literal: true

class NetPromoterScoresController < ApplicationController
  before_action :nps_params, only: %i[create update]

  def index; end

  def create
    render json: @nps, status: :created if @nps.save
  end

  def update
    render json: @nps, status: :ok if @nps.save
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
