require 'oauth'

class Service::Smarterbase < Service
  default_events :commit_comment, :issues, :issue_comment
  string   :subdomain, :consumer_key, :consumer_secret
  white_list :subdomain, :consumer_key, :consumer_secret
 
  def invalid_request?
    puts data
    data['subdomain'].to_s.empty? or
        data['consumer_key'].to_s.empty? or
        data['consumer_secret'].to_s.empty?
  end

  def full_url(subdomain, path='')
    if subdomain =~ /\./
      url = "http://#{subdomain}/#{path}"
    else
      url = "http://#{subdomain}.smarterbase.com/#{path}"
    end

    begin
      Addressable::URI.parse(url)
    rescue Addressable::URI::InvalidURIError
      raise_config_error("Invalid subdomain #{subdomain}")
    end

    url

  end

  def service_url(subdomain)
    full_url(subdomain, 'external/github')
  end

  def receive_event
    
    consumer = OAuth::Consumer.new(data['consumer_key'], data['consumer_secret'],
     :site => full_url(data['subdomain']), :http_method => :get, :scheme => :query_string)

    access_token = OAuth::AccessToken.new(consumer)
 
    raise_config_error "Bad configuration" if invalid_request?
    
    url = service_url(data['subdomain'])
    res = access_token.post(url, { :payload => payload.to_json,
                           :subdomain => data['subdomain'],
                           :event => event.to_s })
    
    unless res.code.to_s[/2\d+/]
      raise_config_error("Unexpected response code:#{res.code}")
    end
  end
end
