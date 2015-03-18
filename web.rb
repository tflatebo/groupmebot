require 'sinatra'

get '/' do
  "Hello, world"
end

post '/' do
  puts request.body
end
