require "rubygems"
require "sinatra/base"
require "bundler"
require "sinatra/assetpack"

Bundler.require
require_relative "assets"
require_relative "app_routes"


class GPGFormMailerApp < Sinatra::Base
  set :environment, :development
  register Sinatra::Flash
  register Sinatra::AssetPack
  register Sinatra::Assets
  register Sinatra::AppRoutes
  run! if app_file == $0
end
