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
  level = params['postrank'].nil? ? 'all' : params['postrank']

  url  = "http://api.postrank.com/v2/feed/info?id=#{params['feed']}&appkey=rssreplay&format=json"
  c = Curl::Easy.new(url)
  c.perform

  feed = JSON.parse(c.body_str)

  if feed['error']
    redirect "/?error=nofeed"
  else
    redirect "/#{feed['id']}/#{Time.now.utc.to_i}/#{interval}/#{level}"
  end
end

get "/:feed/:interval/:postrank" do
  redirect "/#{params['feed']}/#{Time.now.utc.to_i}/#{params['interval']}/#{params['postrank']}"
end

get "/:feed/:start/:interval/:postrank?" do
  seen  = (Time.now.utc.to_i - params['start'].to_i) / params['interval'].to_i
  postrank = params['postrank'].empty? ? 'all' : params['postrank']

  url  = "http://api.postrank.com/v2/feed/#{params[:feed]}?format=rss&appkey=rssreplay&"
  url += "start=#{seen-1}&num=1&"
  url += "level=#{postrank}"

  c = Curl::Easy.new(url)
  c.perform

  c.body_str
end
