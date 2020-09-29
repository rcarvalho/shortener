### Overview
I decided to use the Sinatra framework because it is lighter than Rails for the purpose of this simple application. Sinatra has built-in routing yet is lightweight. The list of assumptions are below:
* The user info and associations with the slugs will be stored by the calling application. 
* The slugs are unique system-wide. If a user tries to specify a custom slug that is already in use in the system they will receive an error.
* The same URL can be stored multiple times.

### Requirements and Setup
1. RVM or rbenv
2. Redis - You can install it with brew on OSX `brew install redis`
3. Make sure you have bundler installed and run `bundle install`

### Running the tests
Run `rspec`

### Running the Application
Run `ruby app.rb`

### Sample API requests

# CREATE a shortened url for google.com:
curl -d "url=http://google.com/" http://localhost:4567/url

# CREATE with a custom slug
curl -d "url=http://google.com/&slug=gggggg" http://localhost:4567/url

# GET full url using the shortened url - Either paste the shortened url in the browser or use this to see the redirect information
curl --head http://localhost:4567/XXXXXX

# DELETE - specify either the slug or the shortened_url
curl -X "DELETE" -d "slug=XXXXXX" http://localhost:4567/url
curl -X "DELETE" -d "shortened_url=http://localhost:4567/XXXXXX" http://localhost:4567/url