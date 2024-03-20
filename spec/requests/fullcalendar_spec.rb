require 'rails_helper'

RSpec.describe "Fullcalendars", type: :request do
  describe "GET /index" do
    it "returns http success" do
      get "/fullcalendar/index"
      expect(response).to have_http_status(:success)
    end
  end

end
