require 'sinatra'
require 'redis'
require './shortener'

shortener = Shortener.new(Redis.new)

get '/:slug' do
  begin
    url = shortener.read(params['slug'])
    if url
      redirect url
    else
      status 404
    end
  rescue => e
    logger.error(e.message)
    status 500
  end
end

# Save the URL
post '/url' do
  begin
    slug = shortener.shorten(params['url'], params['slug'])
    host_name = request.env['SERVER_NAME']
    host_name += ":#{request.env['SERVER_PORT']}" if request.env['SERVER_PORT'] != '80'
    { shortened_url: "http://#{host_name}/#{slug}" }.to_json
  rescue => e
    logger.error(e.message)
    { error: e.message }.to_json
  end
end

# Delete the slug
delete '/url' do
  begin
    result = nil
    # Returning OK below whether or not the key actually exists because it should not matter whether it exists or not
    if params['slug']
      shortener.delete(params['slug'])
      return { result: 'OK'}.to_json
    elsif params['shortened_url']
      shortener.delete(params['shortened_url'].split('/').last)
      return { result: 'OK'}.to_json
    else
      return { error: "Must specify parameter 'slug' or 'shortened_url'"}.to_json
    end
  rescue => e
    logger.error(e.message)
    { error: e.message }.to_json
  end
end