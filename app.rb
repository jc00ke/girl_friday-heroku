require 'sinatra/base'

class App < Sinatra::Base

  configure :production do
    set :uri, URI.parse(ENV['REDISTOGO_URL'])
  end
  configure :development do
    RedisURI = Struct.new :host, :port, :password
    set :uri, RedisURI.new('localhost', 6379, nil)
  end
  configure do
    set :store_config, {
      :host       => uri.host,
      :port       => uri.port,
      :password   => uri.password
    }
  end
  helpers do
    include Rack::Utils
  end
  REDIS = Redis.new store_config

  QUEUE = GirlFriday::WorkQueue.new('dat_q', :store => GirlFriday::Store::Redis, :store_config => [store_config]) do |msg|
    REDIS.rpush('messages', msg)
  end

  get '/' do
    @messages = REDIS.lrange('messages', 0, -1)
    haml :index
  end

  post '/' do
    QUEUE << escape_html(params[:message])
    redirect to('/')
  end
end
