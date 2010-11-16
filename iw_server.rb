require 'sinatra'
require 'sinatra/sequel'
require 'json'
require 'haml'
require 'pusher'

set :database, ENV['DATABASE_URL'] || 'sqlite://my.db'
set :haml, :format => :html5

# required to keep RVM happy about where the haml views are located
set :views, File.dirname(__FILE__) + '/views'
set :public, File.dirname(__FILE__) + '/public'

# Pusher notifications
Pusher.app_id = '2773'
Pusher.key = '3fcce2741943f98bf5f6'
Pusher.secret = '5f5a1e9877c01dbe6df7'

# Sequel ORM
Sequel.extension(:pagination)
Sequel::Model.plugin :json_serializer

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
  
migration "create the power supply table" do
  database.create_table :supplies do
    primary_key :id
    text        :name
    text        :ip
    text        :sn
    timestamp   :timestamp, :null => false
    foreign_key :project_id
  end
end  

migration "add nodes column to supplies" do
    database.add_column :supplies, :nodes, Integer 
end

          

  
# Sequel models
class Project < Sequel::Model
  one_to_many :logs
  one_to_many :supplies
end

class Log < Sequel::Model
  # order :timestamp
  many_to_one :project
end

class Supply < Sequel::Model
  many_to_one :project
end

# before filter to populate project list
before do
    @projects = Project.all if request.get?
end

# routes

get '/' do
  @logs = Log.order(:timestamp.desc).limit(10)
  
  haml :index
end

get '/logs/?' do
  pass if params.key?('page')

  pages = Log.dataset.order(:timestamp.desc)
  responseHash = {'log' => pages }
  
  response['Content-Type'] = 'application/json'
  [200, responseHash.to_json]
end

get '/logs/?' do 
  pageNumber = params['page'].to_i || 1
  rows = params['rows'] || 10
  rows = rows.to_i
  
  pages = Log.dataset.order(:timestamp.desc).paginate(pageNumber,rows)
  
  logArray = Array.new
  pages.each do |p|
    logArray.insert(-1, {"entry" => p.entry, "timestamp" => p.timestamp.httpdate, 
      "project_name" => p.project.name, "project_id" => p.project.id})
  end
  
  responseHash = {'current_page' => pages.current_page,
    'prev_page' => pages.prev_page,
    'next_page' => pages.next_page,
    'page_count' => pages.page_count,
    'page_size' => pages.page_size,
    'logs' => logArray.to_json }
  
  response['Content-Type'] = 'application/json'
  [200, responseHash.to_json]
end



# {name: 'my project'}
post '/projects/?' do
  request.body.rewind  # in case someone already read it
  data = JSON.parse request.body.read
  halt [400, "No or empty name field"] if data['name'].nil? || data['name'].empty?

  Project.create(:name => data['name'])
  [201, data['name']]
end

get '/projects/:id/?' do
  @proj = Project[params[:id]]
  halt [404, "No such project"] if @proj.nil?
  
  # @logs = @proj.logs_dataset.order(:timestamp.desc).paginate(1, 4)
  # puts "page count: #{@logs.page_count}"
  
  @logs = @proj.logs_dataset.order(:timestamp.desc)
  @supplies = @proj.supplies_dataset.order(:sn)
  
  haml :project
end

# {'message':'my log message'}
post '/projects/:id/logs/?' do
  request.body.rewind  # in case someone already read it
  data = JSON.parse request.body.read
  halt [400, "No or empty message field"] if data['message'].nil? || data['message'].empty?

  # find the project
  @proj = Project[params[:id]]
  halt [404, "No such project"] if @proj.nil?
  
  log = Log.create(:entry => data['message'], :timestamp => Time.now)
  @proj.add_log(log)

  h = Hash["projName" => @proj.name, "projURL" => "/projects/#{@proj.id}",
    "message" => log.entry, "timestamp" => log.timestamp.httpdate]
  Pusher['log_channel'].trigger('new', h.to_json)  
  

  [201, data['message']]
end

# {'sn':'1234', 'name':'bob', 'ip':'127.0.0.1'}
post '/projects/:id/supplies/?' do
  request.body.rewind  # in case someone already read it
  data = JSON.parse request.body.read
  halt [400, "No or empty serial number field"] if data['sn'].nil? || data['sn'].empty?

  # find the project
  @proj = Project[params[:id]]
  halt [404, "No such project"] if @proj.nil?
  
  # find the supply
  response = 200
  supply = @proj.supplies_dataset.filter(:sn => data['sn']).first
  if supply.nil? then
    supply = Supply.create(:sn => data['sn'], :timestamp => Time.now, :nodes => 0) if @supply.nil?
    @proj.add_supply(supply)
    response = 201
  end
  
  # update the entry with the latest info
  supply.update(:timestamp => Time.now, :name => data['name'], :ip => data['ip'] )

  Pusher['update_channel'].trigger('update', {:some => 'data'})  

  [response, data['sn']]
end

# {'nodes':50}
put '/supplies/:sn/?' do
  request.body.rewind # in case someone already read it
  data = JSON.parse request.body.read
  halt [400, "No or empty nodes field"] if data['nodes'].nil? || data['nodes'].empty?

  # find the supply
  @supply = Supply[:sn => params[:sn]]
  halt [404, "No such supply"] if @supply.nil?
  
  @supply.nodes = data['nodes']
  
  [200, data['nodes']]
end

# stylesheets via sass
get '/css/style.css' do
  response['Content-Type'] = 'text/css; charset=utf-8'
  scss :style
end
