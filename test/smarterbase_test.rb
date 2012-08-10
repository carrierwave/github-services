require File.expand_path("../helper", __FILE__)

class SmarterbaseTest < Service::TestCase
  def setup
    @stubs   = Faraday::Adapter::Test::Stubs.new
    @data    = { "subdomain" => "test",
                 "consumer_key" =>  "1d5ff56af429bcd3da32cc23f4982c3ccde7cf9ae3a8a68f0da507ecc8d47f7",
                 "consumer_secret" => "dc9ad345843e6c7f2d116f1cad8531382be386b6f6d389ba3e6f7bd1521be02"}
    @payload = { :message => "Some message" }
  end

  def test_subdomain
    post(@data)
    svc = service :event, @data, @payload
    svc.receive_event
  end

  def test_domain
    @data.merge("subdomain" => "test.smarterbase.com")

    post(@data)
    
    svc = service :event, @data, @payload
    svc.receive_event
  end


  def post(data)
    @stubs.post "/external/github" do |env|
      assert_equal "test.smarterbase.com", env[:url].host
      assert_equal ({ :payload => @payload }.merge(@data).to_json), env[:body]
      [ 201, {}, "" ]
    end
  end

  def service(*args)
    super Service::Smarterbase, *args
  end
end
