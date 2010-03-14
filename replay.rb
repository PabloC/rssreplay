require "rubygems"
require "sinatra"
require "chronic"
require "curb"
require "json"

get "/" do
  erb :index
end

post "/create" do
  interval = (Chronic.parse("in #{params['interval']}").utc - Time.now.utc).to_i
  
  url  = "http://api.postrank.com/v2/feed/info?id=#{params['feed']}&appkey=rssreplay&format=json"  
  c = Curl::Easy.new(url)
  c.perform
  
  feed = JSON.parse(c.body_str)
  
  redirect "/#{feed['id']}/#{Time.now.utc.to_i}/#{interval}"
end

get "/:feed/:interval" do
  redirect "/#{params['feed']}/#{Time.now.utc.to_i}/#{params['interval']}"
end

get "/:feed/:start/:interval" do  
  seen  = (Time.now.utc.to_i - params['start'].to_i) / params['interval'].to_i
  
  url  = "http://api.postrank.com/v2/feed/#{params[:feed]}?format=rss&appkey=rssreplay&"
  url += "start=#{seen-1}&num=1" 
  
  c = Curl::Easy.new(url)
  c.perform
  
  c.body_str
end

