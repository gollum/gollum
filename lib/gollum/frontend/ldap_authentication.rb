require 'net/ldap'
require 'yaml'
require 'digest/md5'

LDAP = YAML.load_file( File.expand_path('../../../../config/ldap.yml', __FILE__) )

module Precious
  module LdapAuthentication

    AUTH_TOKEN_SEED = 'super freaking awesome secret seed'

    def authenticate(login, password)
      authenticated_user = ldap_login(login, password)

      if authenticated_user
        {
          :email => authenticated_user['mail'].first,
          :name  => authenticated_user[LDAP[:displayname_attribute]].first,
          :token => Digest::MD5.hexdigest(AUTH_TOKEN_SEED + authenticated_user['mail'].first)
        }
      else
        false
      end
    end

    def token_ok?(email,token)
      token == Digest::MD5.hexdigest(AUTH_TOKEN_SEED+email)
    end

    private

    # Returns a single Net::LDAP::Entry or false
    def ldap_login(username, password)
      ldap_session       = new_ldap_session
      bind_args          = args_for(username, password)
      authenticated_user = ldap_session.bind_as(bind_args)

      authenticated_user ? authenticated_user.first : false
    end

    # This is where LDAP jumps up and punches you in the face, all the while
    # screaming "You never gunna get this, your wasting your time!".
    def args_for(username, password)
      user_filter = "#{ LDAP[:username_attribute] }=#{ username }"
      args        = { :base     => LDAP[:base],
                      :filter   => "(#{ user_filter })",
                      :password => password }

      unless LDAP[:can_search_anonymously]
        # If you can't search your LDAP directory anonymously we'll try and
        # authenticate you with your user dn before we try and search for your
        # account (dn example. `uid=clowder,ou=People,dc=mycompany,dc=com`).
        user_dn = [user_filter, LDAP[:base]].join(',')
        args.merge({ :auth => { :username => user_dn, :password => password, :method => :simple } })
      end

      args
    end

    def new_ldap_session
      Net::LDAP.new(:host       => LDAP[:host],
                    :port       => LDAP[:port],
                    :encryption => LDAP[:encryption],
                    :base       => LDAP[:base])
    end

  end
end
