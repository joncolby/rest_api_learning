
require 'securerandom'

token = SecureRandom.urlsafe_base64(50)

puts token
