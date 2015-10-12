require "rest_api_learning/version"
require 'sinatra/base'
require 'sinatra/json'
require 'haml'
require 'tilt/haml'
require 'rest_api_learning/routes'
require 'rest_api_learning/helpers'
require 'rest_api_learning/token'
require 'rest_api_learning/domain'
require 'warden'

class RestApi < Sinatra::Application
  
  not_found do
    halt 404, 'page not found'
  end
  
  get '/protected' do
      env['warden'].authenticate!(:access_token)
      content_type :json
      json({ :message  => "This is an authenticated request!" })
  end

  # This is the route that unauthorized requests gets redirected to.
  post '/unauthenticated' do
      content_type :json
      json({ :message  => 'Sorry, this request can not be authenticated. Try again.' })
  end
  
  get '/' do
    @notes = RestApiLearning::Note.all :order => :id.desc
    @title = 'All Notes'
    haml :home
  end
  
  post '/' do
    n = RestApiLearning::Note.new
    n.content = params[:content]
    n.created_at = Time.now
    n.updated_at = Time.now
    n.save
    redirect '/'
  end
  
  get '/:id' do
    @note = RestApiLearning::Note.get params[:id]
    @title = "Edit note ##{params[:id]}"
    haml :edit
  end
  
  get '/:id/delete' do
    @note = RestApiLearning::Note.get params[:id]
    @title = "Confirm deletion of note ##{params[:id]}"
    haml :delete
  end
  
  delete '/:id' do 
    n = RestApiLearning::Note.get params[:id]
    n.destroy
    redirect '/'
  end
  
  put '/:id' do
    n = RestApiLearning::Note.get params[:id]
    n.content = params[:content]
    n.complete = params[:complete] ? 1 : 0
    n.updated_at = Time.now
    n.save
    redirect '/'
  end
  
  get '/:id/complete' do
    n = RestApiLearning::Note.get params[:id]
    n.complete = n.complete ? 0 : 1 # flip it
    n.updated_at = Time.now
    n.save
    redirect '/'
  end

=begin  
  get '/:name' do
    bar(params['name'])
  end
=end  
  
  get '/form' do
    haml :form
  end
  
  post '/form' do
    "your message was: #{params[:message]}"
  end
    
  # Configure Warden
  use Warden::Manager do |config|
      config.scope_defaults :default,
      # Set your authorization strategy
      :strategies => [:access_token],
      # Route to redirect to when warden.authenticate! returns a false answer.
      :action => '/unauthenticated'
      config.failure_app = self
  end
  
  Warden::Manager.before_failure do |env,opts|
      env['REQUEST_METHOD'] = 'POST'
  end
  
  Warden::Strategies.add(:access_token) do
      def valid?
          # Validate that the access token is properly formatted.
          # Currently only checks that it's actually a string.
          request.env["HTTP_ACCESS_TOKEN"].is_a?(String)
      end
  
      def authenticate!
          # Authorize request if HTTP_ACCESS_TOKEN matches 'youhavenoprivacyandnosecrets'
          # Your actual access token should be generated using one of the several great libraries
          # for this purpose and stored in a database, this is just to show how Warden should be
          # set up.
          access_granted = (request.env["HTTP_ACCESS_TOKEN"] == 'youhavenoprivacyandnosecrets')
          !access_granted ? fail!("Could not log in") : success!(access_granted)
      end
  end
    
  helpers RestApiLearning::Helpers
  register RestApiLearning::Routes  
  
  run! if app_file == $0
 
end