module RestApiLearning
  module Routes
    
    def self.registered(app)
    
      app.get '/help' do
        "help me holy moly"
      end
    end
  end
end