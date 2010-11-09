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

migration "create the log file table" do
  database.create_table :logs do
    primary_key :id
    text        :entry
    timestamp   :timestamp, :null => false
    foreign_key :project_id
  end
end
  

class Project < Sequel::Model
  one_to_many :logs
end

class Log < Sequel::Model
  many_to_one :project
end

# before filter to populate project list
before do
    @projects = Project.all if request.get?
end

# routes

get '/' do
  @logs = Log.limit(5)
  
  haml :index
end

get '/projects/:id/?' do
  @proj = Project[params[:id]]
  halt [404, "No such project"] if @proj.nil?
  
  @logs = @proj.logs
  
  haml :project
end

# {name: 'my project'}
post '/projects/?' do
  request.body.rewind  # in case someone already read it
  data = JSON.parse request.body.read
  halt [400, "No or empty name field"] if data['name'].nil? || data['name'].empty?

  Project.create(:name => data['name'])
  [201, data['name']]
end

# {message: 'my log message'}
post '/projects/:id/logs/?' do
  request.body.rewind  # in case someone already read it
  data = JSON.parse request.body.read
  halt [400, "No or empty message field"] if data['message'].nil? || data['message'].empty?

  # find the project
  @proj = Project[params[:id]]
  halt [404, "No such project"] if @proj.nil?
  
  log = Log.create(:entry => data['message'], :timestamp => Time.now)
  @proj.add_log(log)

  [201, data['message']]
end

# stylesheets via sass
get '/css/style.css' do
  response['Content-Type'] = 'text/css; charset=utf-8'
  scss :style
end
