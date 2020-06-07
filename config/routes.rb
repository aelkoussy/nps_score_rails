# frozen_string_literal: true

Rails.application.routes.draw do
  # Delete won't be allowed as the resource shall not be deleted
  resources :net_promoter_scores, only: %i[index create]
end
