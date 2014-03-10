require 'sinatra'
require 'sinatra/static_assets'

class AcroApp < Sinatra::Base
  register Sinatra::StaticAssets

  set :public_folder, File.expand_path('../public', __FILE__)

  get '/' do
    erb :index
  end

end
