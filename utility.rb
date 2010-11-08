require 'rest_client'
require 'json'

begin
  # response = RestClient.post "http://127.0.0.1:4567/projects", { 'name' => 'Proj 2' }.to_json, :content_type => :json, :accept => :json
  response = RestClient.post "http://127.0.0.1:4567/projects/2/logs", { 'message' => 'test log message 5' }.to_json, :content_type => :json, :accept => :json
  puts "#{response.code}: #{response.to_str}"
rescue => e
  puts "Exception: #{e.http_code}: #{e.response}"
end