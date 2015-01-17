module Sinatra
  module Assets
    def self.registered(app)
      app.assets do
        serve '/js', :from => 'js'
        serve '/assets/', :from => 'assets'

        js :modernizr, [
          '/assets/modernizr/modernizr.js',
        ]

        js :libs, [
          '/assets/jquery/dist/jquery.js',
          '/assets/foundation/js/foundation.js',
          '/assets/kbpgp/kbpgp.js',
        ]

        js :application, [
          '/js/*.js',
        ]
        js :gpg_mail_form, [
          '/js/*.coffee',
        ]
        serve '/css', :from => 'public/stylesheets'

        css :application, [
          '/css/*.css'
        ]

        js_compression :jsmin
      end
    end
  end
end
