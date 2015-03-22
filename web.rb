require 'sinatra'
require 'json'
require 'httparty'
require 'logger'

set :bot_uri, 'https://api.groupme.com/v3/bots/post'
set :bot_id, ENV['GROUPMEBOTID']

enable :logging

helpers do
  def post(text)
    options = { :text => text, :bot_id => settings.bot_id }
    logger.debug "Posting #{options[:text]} to groupme: "
    gm_response = HTTParty.post(settings.bot_uri,
                                :query => { :text => text, :bot_id => settings.bot_id },
                                :debug_output => $stdout)

    if(gm_response.success?)
      logger.debug gm_response.response
    else
      logger.info "error posting to groupme bot: "
      logger.info gm_response.response
    end
  end
end

before do

  logger.level = Logger::DEBUG

  begin

    if request.request_method == "POST"
      puts "request: #{request.request_method}"
      request.body.rewind
      @request_payload = JSON.parse request.body.read
    end
  rescue
    message = ''
    if(env['sinatra.error'])
      message ||= env['sinatra.error'].message
    end
    logger.error("error: #{message}")
    halt 500

  end

end

get '/' do
  puts "Hello, world"
end

post '/' do

  logger.debug "Text from groupme: " + @request_payload['text']

  if(@request_payload['text'].start_with?('john gage', 'johngage'))
    logger.debug "Matched input"
    post('You said: ' + @request_payload['text'])
  else
    logger.debug "No match on input"
  end

end
