require 'sinatra'
require 'sinatra/sequel'

set :database, ENV['DATABASE_URL'] || 'sqlite://my.db'

migration "create the projects table" do
  database.create_table :projects do
    primary_key :id
    text        :name, :unique => true
  end
end

class Projects < Sequel::Model
end

get '/' do
  # Projects.insert(:name => 'proj 2')
  # Projects[1].name
  projStr = "Project count: #{Projects.count}\n"
  Projects.each{ |p| projStr << "\t#{p.name}"}
  projStr
end

