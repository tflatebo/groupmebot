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

  def test_post_groupme_no_match
    post("/", {
           text: "bob"
         }.to_json)
    puts "response: " + last_response.status.to_s
    puts "response body: " + last_response.body.to_s
    assert last_response.ok?
    assert_equal 'No match on input', last_response.body
  end

  def test_post_groupme_match
    post("/", {
           text: "johngage foo"
         }.to_json)
    puts "response: " + last_response.status.to_s
    puts "response body: " + last_response.body.to_s
    assert last_response.ok?
    assert_equal 'Posted to groupme', last_response.body
  end

end
