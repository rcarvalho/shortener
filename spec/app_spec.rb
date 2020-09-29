require './spec_helper'
require '../app'
require '../shortener'

RSpec.describe 'App' do
  include Rack::Test::Methods

  def app
    Sinatra::Application
  end

  describe 'get to shortened url' do
    it "redirects to proper url" do
      Shortener.any_instance.stubs(:read).returns('http://google.com')
      get '/abcdef'
      expect(last_response.redirect?).to be_truthy
      expect(last_response.headers['Location']).to eq('http://google.com')
    end

    it "returns a 404 if there is no url found" do
      get '/abcdef'
      expect(last_response.status).to eq(404)
    end

    it "returns an error if redis fails" do
      Shortener.any_instance.stubs(:read).raises(Redis::CannotConnectError)
      get '/abcdef'
      expect(last_response.status).to eq(500)
    end
  end


  describe 'post to url' do
    it 'shortens url and returns shortened url' do
      post '/url', { url: 'http://google.com' }
      expect(JSON.parse(last_response.body)['shortened_url']).to match(/http:\/\/example.org\/\w{6}/)
    end

    it 'returns error when no url is specified' do
      post '/url'
      expect(JSON.parse(last_response.body)['error']).to eq("A parameter 'url' must be specified.")
    end

    it 'returns error when there is a redis failure' do
      Shortener.any_instance.stubs(:shorten).raises(Redis::CannotConnectError)
      post '/url', { url: 'http://google.com' }
      expect(JSON.parse(last_response.body)['error']).to eq('Redis::CannotConnectError')
    end
  end

  describe 'delete' do
    it 'deletes key and returns ok with a slug' do
      delete '/url', { slug: 'abcedf' }
      expect(JSON.parse(last_response.body)['result']).to eq('OK')
    end
    it 'deletes key and returns ok with a shortened_url' do
      delete '/url', { shortened_url: 'http://localhost:4567/abcedf' }
      expect(JSON.parse(last_response.body)['result']).to eq('OK')
    end
    it 'returns an error if no slug or shortened_url specified' do
      delete '/url'
      expect(JSON.parse(last_response.body)['error']).to eq("Must specify parameter 'slug' or 'shortened_url'")
    end
    it 'returns an error if there is a redis failure' do
      Shortener.any_instance.stubs(:delete).raises(Redis::CannotConnectError)
      delete '/url', { slug: 'abcedf' }
      expect(JSON.parse(last_response.body)['error']).to eq('Redis::CannotConnectError')
    end
  end
end