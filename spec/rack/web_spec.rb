require File.join(File.dirname(__FILE__), *%w[.. spec_helper])

class HelloWorldTest < Test::Unit::TestCase
  include Rack::Test::Methods

  def app
    Sinatra::Application
  end

  def test_it_says_hello_world
    get '/'
    assert last_response.ok?
    #assert_equal 'Hello, World', last_response.body
  end

  def test_accepts_groupme_json
    post '/', :text => 'foo'
    assert last_response.ok?
    #assert last_response.body.include?('Simon')
  end
end
