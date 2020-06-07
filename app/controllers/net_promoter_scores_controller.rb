# frozen_string_literal: true

class NetPromoterScoresController < ApplicationController
  before_action :nps_params, only: :create

  def index
    @nps_score = NetPromoterScore.calc_nps(nps_query_params[:touchpoint], nps_query_params[:respondent_class], nps_query_params[:rated_object_class])
    render json: @nps_score, status: :ok
  end

  def create
    # here we will use OK status for created and updated records for simplicity
    if @nps.save
      render json: @nps.id, status: :ok
    else
      render json: { error: 'something went wrong' }, status: :bad_request
    end
  end

  private

  def check_token_and_initialize_nps
    @payload = NetPromoterScore.parse_token(@token)

    @nps = NetPromoterScore.find_or_initialize_by(@payload)
    @nps.score = @score
  end

  def nps_params
    @score = params.require(:score)
    @token = params.require(:token)
    check_token_and_initialize_nps
  end

  def nps_query_params
    # for some weird reason, chaining the require and permit here does not work
    # this solves the issue anyways, making touchpoint mandotory, then permitting it with other params
    # the proper way would be this of course:
    # params.require(:touchpoint).permit(%i[respondent_class rated_object_class])
    params.require(:touchpoint)
    params.permit(:touchpoint, :respondent_class, :rated_object_class)
  end

  # To send a meaningful error if a param is missing
  rescue_from ActionController::ParameterMissing do |e|
    render json: { error: e.message }, status: :bad_request
  end
end
