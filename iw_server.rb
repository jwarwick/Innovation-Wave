require 'sinatra'
require 'sinatra/sequel'
require 'json'

set :database, ENV['DATABASE_URL'] || 'sqlite://my.db'

migration "create the projects table" do
  database.create_table :projects do
    primary_key :id
    text        :name
  end
end

class Projects < Sequel::Model
end

get '/' do
  # Projects.insert(:name => 'proj 2')
  # Projects[1].name
  projStr = "Project count: #{Projects.count}\n"
  Projects.each{ |p| projStr << "\t#{p.id} #{p.name}"}
  projStr
end

get '/projects/:id/?' do
  @proj = Projects[params[:id]]
  halt [404, "No such project"] if @proj.nil?
  
  @proj.name
end

post '/projects/?' do
  request.body.rewind  # in case someone already read it
  data = JSON.parse request.body.read
  halt [400, "No or empty name field"] if data['name'].nil? || data['name'].empty?

  Projects.create(:name => data['name'])
  [201, data['name']]
end

