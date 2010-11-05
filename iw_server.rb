require 'sinatra'
require 'sinatra/sequel'
require 'json'
require 'haml'

set :database, ENV['DATABASE_URL'] || 'sqlite://my.db'
set :haml, :format => :html5

# required to keep RVM happy about where the haml views are located
set :views, File.dirname(__FILE__) + '/views'

migration "create the projects table" do
  database.create_table :projects do
    primary_key :id
    text        :name
  end
end

class Projects < Sequel::Model
end

# before filter to populate project list
before do
    @projects = Projects.all
end

# routes

get '/' do
  haml :index
end

get '/projects/:id/?' do
  @proj = Projects[params[:id]]
  halt [404, "No such project"] if @proj.nil?
  
  haml :project
end

post '/projects/?' do
  request.body.rewind  # in case someone already read it
  data = JSON.parse request.body.read
  halt [400, "No or empty name field"] if data['name'].nil? || data['name'].empty?

  Projects.create(:name => data['name'])
  [201, data['name']]
end

# stylesheets via sass
get '/css/style.css' do
  response['Content-Type'] = 'text/css; charset=utf-8'
  scss :style
end
