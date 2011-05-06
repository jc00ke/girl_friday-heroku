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
    set :public, 'public'
    set :static, true
  end

  helpers do
    include Rack::Utils
  end

  REDIS = Redis.new store_config

  ADDQ = GirlFriday::WorkQueue.new('dat_q', :store => GirlFriday::Store::Redis, :store_config => [store_config]) do |msg|
    REDIS.lpush('messages', msg)
  end

  CLEARQ = GirlFriday::WorkQueue.new('dat_q', :store => GirlFriday::Store::Redis, :store_config => [store_config]) do |s|
    sleep s
    REDIS.del('messages')
  end

  get '/' do
    @messages = REDIS.lrange('messages', 0, -1)
    haml :index
  end

  post '/' do
    ADDQ << escape_html(params[:message])
    redirect to('/')
  end

  delete '/' do
    CLEARQ << 5
  end
end
