class HomeController < ApplicationController
  def index
    kanye_response = HTTParty.get('https://api.kanye.rest')
    taylor_response = HTTParty.get('https://api.taylor.rest')
    @kanye_quote = kanye_response['quote']
    @taylor_quote = taylor_response['quote']
  end
end