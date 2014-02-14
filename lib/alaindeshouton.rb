require 'twitter'
require 'pg'
require 'active_record'

def trim140(tweet)
  while tweet.length>137
    tweetwords=tweet.split(' ')
    if tweetwords.size > 1
      tweet=tweetwords[0..-2].join(' ')
    else
      tweet=tweet[0..136]
    end
  end
  tweet << "..."
end

#heroku config:add DB_ADDRESS= DB_USER= DB_PW= DB_NAME=


=begin
ActiveRecord::Base.establish_connection(
  :encoding => "utf8",
  :collation => "utf8mb4_general_ci",
  :adapter  => "postgresql",
  :host     => ENV['DB_ADDRESS'],
  :username => ENV['DB_USER'],
  :password => ENV['DB_PASSWORD'],
  :database => ENV['DB_NAME']
)
=end
ActiveRecord::Base.establish_connection(ENV["DATABASE_URL"])


#heroku config:add E_CONSUMER_KEY= R_CONSUMER_SECRET= R_OATH_TOKEN= R_OATH_TOKEN_SECRET=

AlainTweets = Twitter::REST::Client.new do |config|
  config.consumer_key = ENV['R_CONSUMER_KEY']
  config.consumer_secret = ENV['R_CONSUMER_SECRET']
  config.access_token = ENV['R_OATH_TOKEN']
  config.access_token_secret = ENV['R_OATH_TOKEN_SECRET']
end

#heroku config:add W_CONSUMER_KEY= W_CONSUMER_SECRET= W_OATH_TOKEN= W_OATH_TOKEN_SECRET=

AlainTwoots = Twitter::REST::Client.new do |config|
  config.consumer_key = ENV['W_CONSUMER_KEY']
  config.consumer_secret = ENV['W_CONSUMER_SECRET']
  config.access_token  = ENV['W_OATH_TOKEN']
  config.access_token_secret = ENV['W_OATH_TOKEN_SECRET']

end

result = con.query("select lasttweet from lasttweet where id=1")

x = result.fetch_row



LatestTweet = AlainTweets.search("from:alaindebotton", :result_type => "recent",  :since_id => x[0].to_i 
).results.reverse.each do |status|
  puts status.id
  tweettext = status.text.upcase
  puts tweettext
  tweetid=status.id
  AlainTwoots.update(tweettext.trim140)  
  con.query("update lasttweet set lasttweet=#{tweetid} where id=1")

end

  

