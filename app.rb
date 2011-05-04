require 'sinatra/base'

class App < Sinatra::Base
  get '/' do
    "hi!"
  end
end
