require 'sinatra'
require 'json'

get '/' do
  puts "Hello, world"
end

post '/' do
  request.body.rewind
  request_payload = JSON.parse request.body.read

  #do something with request_payload
  puts "Text from groupme: " + request_payload['text']

  "Text from groupme: " + request_payload['text']
end
