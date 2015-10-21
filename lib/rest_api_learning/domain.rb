require 'data_mapper'
require 'bcrypt'
require 'dm-timestamps'

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
 
 class User
   include DataMapper::Resource
   include BCrypt
   
   attr_accessor :password, :password_confirmation
   
   timestamps :at
   
   property :id, Serial, :key => true
   property :encrypted_password, String, :length => 60..60, :required => true, :writer => :protected
   property :username, String, :length => 4..30, :unique => true, :required => true
                                     
   validates_presence_of :password, :password_confirmation, :if => :password_required?
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