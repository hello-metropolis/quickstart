class Api::HealthChecksController < ApplicationController
    def index
        resp = {
          time: Time.now.to_s(:db),
          env: Rails.env.to_s,
          message: "Metropolis Demo Change x2"
        }
        render json: resp
      end
end
