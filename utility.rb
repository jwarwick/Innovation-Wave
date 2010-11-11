require 'rest_client'
require 'json'


#@host = "http://innovationwave.heroku.com"
@host = "http://127.0.0.1:4567"

begin
    # response = RestClient.post "#{@host}/projects", { 'name' => 'Innovation Demo' }.to_json, :content_type => :json, :accept => :json
  #   response = RestClient.post "http://innovationwave.heroku.com/projects", { 'name' => 'Office' }.to_json, :content_type => :json, :accept => :json
  #   response = RestClient.post "http://innovationwave.heroku.com/projects", { 'name' => 'Showroom' }.to_json, :content_type => :json, :accept => :json
  #   response = RestClient.post "http://innovationwave.heroku.com/projects", { 'name' => 'Retail' }.to_json, :content_type => :json, :accept => :json
  #   response = RestClient.post "http://innovationwave.heroku.com/projects", { 'name' => 'Facade' }.to_json, :content_type => :json, :accept => :json

  response = RestClient.post "#{@host}/projects/1/logs", { 'message' => 'test log message' }.to_json, :content_type => :json, :accept => :json

  response = RestClient.post "#{@host}/projects/1/supplies", { 'sn' => '1234', 'name' => 'fake supply', 'ip' => '127.0.0.1' }.to_json, :content_type => :json, :accept => :json
  response = RestClient.post "#{@host}/projects/1/supplies", { 'sn' => '5678', 'name' => 'fake supply2', 'ip' => '127.0.0.2' }.to_json, :content_type => :json, :accept => :json


  puts "#{response.code}: #{response.to_str}"
rescue => e
  puts "Exception: #{e.http_code}: #{e.response}"
end