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
      app.get '/group' do
        haml :group
      end
      app.post '/post_form' do
        haml :post_form
      end
    end
  end
end
