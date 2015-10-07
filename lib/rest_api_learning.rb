require "rest_api_learning/version"
require 'sinatra/base'
require 'rest_api_learning/routes'
require 'rest_api_learning/helpers'

class RestApi < Sinatra::Application
  
  get '/' do
    "hello"
  end
  
  get '/:name' do
    bar(params['name'])
  end
  
  helpers RestApiLearning::Helpers
  register RestApiLearning::Routes
  
  run! if app_file == $0
 
end



