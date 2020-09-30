require './spec_helper'
require '../shortener'

RSpec.describe 'shortener' do
  include Rack::Test::Methods

  describe 'shorten' do
    it 'generates a slug' do
      s = Shortener.new(nil)
      s.stubs(:read_slug).returns('http://test.com').then.returns(nil)
      s.stubs(:generate_random_characters).returns(['a', 'b', 'c', 'd', 'e', 'f']).then.returns(['g'])
      s.expects(:store_slug).with('bcdefg', 'http://hello.com')
      s.shorten('http://hello.com')
    end

    it 'takes a custom slug and stores the result' do
      s = Shortener.new(nil)
      s.expects(:store_slug).with('gggggg', 'http://google.com/')
      s.shorten('http://google.com/', 'gggggg')
    end

    it 'raises an error if custom slug is less than 6 characters' do
      s = Shortener.new(nil)
      expect { s.shorten('http://google.com/', 'abc') }.to raise_error('Invalid slug. Must be exactly 6 alpha numeric characters.')
    end

    it 'raises an error if custom slug is greater than 6 characters' do
      s = Shortener.new(nil)
      expect { s.shorten('http://google.com/', 'abcdefg') }.to raise_error('Invalid slug. Must be exactly 6 alpha numeric characters.')
    end

    it 'raises an error if the custom slug is in use' do
      s = Shortener.new(nil)
      s.stubs(:read_slug).returns('http://test.com')
      expect { s.shorten('http://google.com/', 'gggggg') }.to raise_error(RuntimeError, 'The specified slug is in use and must be unique. Please try another slug.')
    end

    it 'raises an error without a url' do
      s = Shortener.new(nil)
      expect { s.shorten(nil, nil) }.to raise_error("A parameter 'url' must be specified.")
    end

    it 'raises an error with an invalid url' do
      s = Shortener.new(nil)
      expect { s.shorten('invalid url string', nil) }.to raise_error('Not a valid URL. Must begin with http.')
    end
  end

  describe 'delete' do
    it 'calls delete_slug' do
      s = Shortener.new(nil)
      s.expects(:delete_slug)
      s.delete('abcdef')  
    end
  end

  describe 'read' do
    it 'calls read_slug' do
      s = Shortener.new(nil)
      s.expects(:read_slug)
      s.read('abcdef')  
    end
  end

  describe 'generate_random_characters' do
    it "generates number of characters properly" do
      s = Shortener.new(nil)
      chars = s.generate_random_characters(6)
      expect(chars.join('')).to match(/\w{6}/)
    end  
  end

  describe 'store_slug' do
    it 'calls set on Redis API' do
      st = stub()
      s = Shortener.new(st)
      st.expects(:set)
      s.store_slug('abcdef', 'http://google.com/')  
    end
  end

  describe 'read_slug' do
    it 'calls get on the Redis API' do
      st = stub()
      s = Shortener.new(st)
      st.expects(:get)
      s.read_slug('abcdef')
    end
  end

  describe 'delete_slug' do
    it 'calls del on the Redis API' do
      st = stub()
      s = Shortener.new(st)
      st.expects(:del)
      s.delete_slug('abcdef')
    end
  end
end