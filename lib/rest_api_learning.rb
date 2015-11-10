require "rest_api_learning/version"
require 'sinatra/base'
require 'sinatra/json'
require 'haml'
require 'tilt/haml'
require 'rack-flash'
require 'rest_api_learning/routes'
require 'rest_api_learning/helpers'
require 'rest_api_learning/token'
require 'rest_api_learning/domain'
require 'warden'

=begin
 https://github.com/charliepark/omniauth-for-sinatra
 https://github.com/maxjustus/sinatra-authentication
 http://ididitmyway.herokuapp.com/past/2011/2/22/really_simple_authentication_in_sinatra/
 http://ididitmyway.herokuapp.com/
 http://ididitmyway.herokuapp.com/past/2011/2/27/ajax_in_sinatra/
 http://stackoverflow.com/questions/549/the-definitive-guide-to-form-based-website-authentication
 http://recipes.sinatrarb.com/p/middleware/twitter_authentication_with_omniauth
=end

class RestApi < Sinatra::Application
   
  set :sessions, false

  use Rack::Session::Cookie, :secret  => '1DiAZhC=v&>@A%MC0qS87b?V=qC7m{'
  use Rack::Flash

  before do
    cache_control :private, :no_cache, :no_store, :must_revalidate
  end
  
  not_found do
    halt 404, 'page not found'
  end
  
  get '/user' do
    haml :user
  end
  
  post '/user' do  
    u = RestApiLearning::User.new
    puts params['user']
    u.username = params['user']['username']
    u.password = params['user']['password']
    u.password_confirmation = params['user']['password_confirmation']
    u.save
    
    if(u.saved?)
      redirect '/users'
    else
     u.errors.each do |e|
      puts e
     end
     "sorry, didnt save"
    end
    
  
  end
  
  get '/users' do
    @users = RestApiLearning::User.all :order => :id
    puts "users:"
    puts @users
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
    n.content = h params[:content]   
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
      config.default_strategies => [:access_token, :password],
      # Set your authorization strategy
      :strategies => [:access_token, :password],
      # Route to redirect to when warden.authenticate! returns a false answer.
      :action => '/unauthenticated'
      config.serialize_into_session {|user| user.id}
      config.serialize_from_session {|id| RestApiLearning::User.for(:user).find_by_id(id)}
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
  
  Warden::Strategies.add(:password) do
      def valid?
        params['user']['username'] && params['user']['password']
      end
  
      def authenticate!
        user = RestApiLearning::User.first(:username  => params['user']['username'])
        if user.nil?
          throw(:warden, :message => "The username you entered does not exist.")
        elsif user.authenticate(params['user']['password'])
          success!(user)
        else
          throw(:warden, :message => "The username and password combination ")
        end
      end
    end
  
  Warden::Manager.before_failure do |env,opts|
    env['REQUEST_METHOD'] = 'POST'
  end
    
  helpers RestApiLearning::Helpers
  register RestApiLearning::Routes  
  
  helpers do
      include Rack::Utils
      alias_method :h, :escape_html
  end
  
  run! if app_file == $0
 
end