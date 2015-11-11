require 'data_mapper'
require 'bcrypt'
require 'dm-timestamps'
require 'securerandom'

DataMapper::setup(:default, "sqlite3://#{Dir.pwd}/rest_api_learning.db")

module RestApiLearning
 class Note
    include DataMapper::Resource
    property :id, Serial
    property :content, Text, :required => true
    property :complete, Boolean, :required => true, :default => false
    property :created_at, DateTime
    property :updated_at, DateTime
 end
 
 class Token
   include DataMapper::Resource
   
   timestamps :at
   
   property :id, Serial, :key => true
   property :name, String, :required => true 
   property :email_address, String, :length => 4..30, :unique => true, :required => true, :format => :email_address
   property :description, String, :required => true 
   property :token, String, :required => true
   property :host_groups, String
   property :revoked, Boolean, :default  => false
   
   before :save, :generate_token
   
   def generate_token
     self.token = SecureRandom.urlsafe_base64 50
   end 
   
   # token = SecureRandom.urlsafe_base64(50)
   
 end
 
 class User
   include DataMapper::Resource
   include BCrypt
   
   attr_accessor :password, :password_confirmation
   
   timestamps :at
   
   property :id, Serial, :key => true
   property :encrypted_password, String, :length => 60..60, :required => true, :writer => :protected
   property :username, String, :length => 4..30, :unique => true, :required => true
                                     
   validates_presence_of :password, :password_confirmation, :if => :password_required?
   # this compares password with password_confirmation
   validates_confirmation_of :password, :if => :password_required?
   
   before :valid?, :encrypt_password
   
   def encrypt_password
     self.encrypted_password = BCrypt::Password.create(password) if password  
   end

    # check validity of password if we have a new resource, or there is a plaintext password provided
    def password_required?
      new? or password
    end  
    
    def encrypted_password
      pass = super
      if pass 
        BCrypt::Password.new(pass)
      else
        :no_password
      end
    end
    
   def reset_password(password, confirmation)
     update(:password => password, :password_confirmation => confirmation)
   end 
   
   def authenticate(password)
     encrypted_password == password
   end  
   
   def self.authenticate(username, password)
     un = username.to_s.downcase
     u = first(:conditions => ['lower(username) = ?', un, un])
     if u && u.authenticate(password)
       u
     else
       nil
     end
   end                              
                                     
                                     
 end
  DataMapper.finalize.auto_upgrade!
end