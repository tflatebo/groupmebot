require 'sinatra'
require 'json'
require 'httmultiparty'
require 'logger'
require 'open-uri'
require 'base64'

set :bot_uri, 'https://api.groupme.com/v3/bots/post'
set :bot_id, ENV['GROUPMEBOTID']
set :image_uri, "https://image.groupme.com/pictures?access_token=#{ENV['GROUPMEACCESSTOKEN']}"

enable :logging

class ImgClient
  include HTTMultiParty
end

helpers do
  def post(options)
    options['bot_id'] = settings.bot_id
    logger.debug "Posting #{options[:text]} to groupme: "
    gm_response = HTTParty.post(settings.bot_uri,
                                :body => options.to_json,
                                :debug_output => $stdout
                                )

    if(gm_response.success?)
      logger.debug "Post to groupme: " + gm_response.response.to_s
    else
      logger.info "error posting to groupme bot: "
      logger.info gm_response.response.to_s
    end

    return gm_response
  end

  def create_meme(top_text, bottom_text)
    # These code snippets use an open-source library. http://unirest.io/ruby
    top_text = URI::encode(top_text)
    bottom_text = URI::encode(bottom_text)

    meme_response = HTTParty.get("https://ronreiter-meme-generator.p.mashape.com/meme?bottom=#{bottom_text}&font=Impact&font_size=50&meme=johngage&top=#{top_text}",
                                 :headers => {
                                   "X-Mashape-Key" => "6KqZOuOrNmmshw6gSg4NqJmX1umcp15VezsjsnOHZiGrozDSMZ"
                                 },
                                 #:debug_output => $stdout
                                 )

    if meme_response.success?
      puts "writing file to meme.jpg"
      File.open('meme.jpg', 'w') { |file|
        file.puts(meme_response.body)
        file.close
      }
      meme_response = "meme.jpg"
    else
      logger.info "error storing image at groupme: " + meme_response.response.to_s
    end

    return meme_response
  end

  def upload_image(image)

    #puts "Image to store: " + image

    puts "Posting to: " + settings.image_uri
    puts "posting image: " + image

    im_response = ImgClient.post(settings.image_uri,
                                 :query => {
                                   "file" => File.new(image)
                                 },
                                 :debug_output => $stdout
                                 )

    if im_response.success?
      puts "Store image at groupme: " + im_response.response.to_s
      puts "Store image at groupme: " + im_response.body
      logger.debug "Store image at groupme: " + im_response.response.to_s
    else
      puts "error storing image at groupme: " + im_response.response.to_s
      logger.info "error storing image at groupme: " + im_response.response.to_s
    end

    im_payload = JSON.parse im_response.body

    return im_payload['payload']['url']
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
    puts "error: #{message}"
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

    match = @request_payload['text']
    match.slice! "johngage"

    meme_file = create_meme(match, '')

    # meme_response is byte array
    image_url = upload_image(meme_file)

    puts "Image: " + image_url

    groupme_post = {
      #:text => 'You said: ' + @request_payload['text'],
      :text => 'Your meme sir',
      :attachments => [
                       {
                         :type => "image",
                         :url => image_url + ".large"
                       }
                      ]
    }

    gpresponse = post(groupme_post)
    if gpresponse.success?
      "Posted to groupme"
    else
      "Error: cannot port to groupme " + gpresponse.body
    end
  else
    "No match on input"
  end

end
