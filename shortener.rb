require 'digest'

class Shortener
  def initialize(redis)
    @redis = redis
  end

  def shorten(url, slug=nil)
    raise "A parameter 'url' must be specified." if url.nil? || url.empty?
    raise "Not a valid URL. Must begin with http." if url !~ /^http/

    if slug
      raise "Invalid slug. Must be exactly 6 alpha numeric characters." unless slug =~ /^\w{6}$/
      if read_slug(slug)
        raise "The specified slug is in use and must be unique. Please try another slug."
      else
        store_slug(slug, url)
        return slug
      end
    end

    slug_array = generate_random_characters(6)

    loop do
      slug_str = slug_array.join('')
      if read_slug(slug_str)
        slug_array.shift
        slug_array += generate_random_characters(1)
      else
        store_slug(slug_str, url)
        return slug_str
      end
    end 
  end

  def delete(slug)
    delete_slug(slug)
  end

  def read(slug)
    read_slug(slug)
  end

  # The following methods are not called directly via the web service. 
  # However, they are not specified as protected or private for ease of testing

  def generate_random_characters(num)
    valid_characters = ('a'..'z').to_a + ('A'..'Z').to_a + (0..9).to_a
    slug_array = []
    num.times do
      slug_array << valid_characters[rand(62)]
    end
    slug_array
  end

  def store_slug(slug, url)
    @redis.set(slug, url) if @redis
  end

  def read_slug(slug)
    @redis.get(slug) if @redis
  end

  def delete_slug(slug)
    @redis.del(slug) if @redis
  end
end