#!/usr/bin/ruby -

require 'net/http'
require 'json'

if ENV['CENTER_LAT'] and ENV['CENTER_LONG']
  CENTER = [ENV['CENTER_LAT'].to_f, ENV['CENTER_LONG'].to_f]
else
  CENTER = [-37.81361, 144.96306]
end

N_SPOTS = ENV['SPOTS'] || 100
VARIANCE = ENV['VARIANCE'] || 0.1

DATASET_URL = ENV['DATASET_URL'] || 'http://localhost:8001/api/v1/datasets/tom/bikespot'
API_URI = URI(DATASET_URL + '/places/')

SHAREABOUTS_KEY = ENV['SHAREABOUTS_KEY'] || 'YWY1YjMyNzU5YjRiZDljOTQwMGM0Nzhm'

# a sort-of random gaussian in 0,1
# according to wikipedia this works
def rand_gaussian
  n = 12
  (1..n).map { rand() }.reduce(0) { |x,y| x + y} - 6
end

def rand_point(center, variance)
  center.map {|coord| coord + rand_gaussian * variance}
end

N_SPOTS.times do 
  point = rand_point(CENTER, VARIANCE)
  
  data = {
    :visible => "on",
    :name => "Spot",
    :location_type => "Art",
    :address => "21 Something St",
    :submitter_name => "Tom Coleman",
    :link => "",
    :description => "",
    # 'location[lat]' => point[0], 
    # 'location[lng]' => point[1]
    :location => {:lat => point[0], :lng => point[1]}
  }
  
  req = Net::HTTP::Post.new(API_URI.path)
  req.body = JSON(data)
  req['X-Shareabouts-Key'] = SHAREABOUTS_KEY
  req['Content-type'] = 'application/json'
  
  res = Net::HTTP.start(API_URI.hostname, API_URI.port) do |http|
    p http.request(req)
  end
end