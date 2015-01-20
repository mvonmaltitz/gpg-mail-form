module Sinatra
  module AppRoutes
    def self.registered(app)
      #app.set :authentication, true
      #app.set :signup_allowed, true
      app.set :app_name,  "GPG Form Mailer"
      app.get '/' do
        haml :index
      end
      app.get '/single' do
        haml :single
      end
      app.get '/group_with_hidden_target' do
        haml :group_with_hidden_target
      end
      app.get '/group_with_input_target' do
        haml :group_with_input_target
      end
      app.post '/post_form' do
        haml :post_form
      end
    end
  end
end
