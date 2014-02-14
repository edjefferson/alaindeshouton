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

def upcase_tweet(tweet)
  splittweet = tweet.split(' ')
  splittweet.map! do |word|
    if word[0,4]!="http"
      word.upcase!
    else
      word
    end
  end
  splittweet.join(" ")
end 


ActiveRecord::Base.establish_connection(ENV["DATABASE_URL"])

class Tweet < ActiveRecord::Base
end

#heroku config:add R_CONSUMER_KEY= R_CONSUMER_SECRET= R_OAUTH_TOKEN= R_OAUTH_TOKEN_SECRET=

AlainTweets = Twitter::REST::Client.new do |config|
  config.consumer_key = ENV['R_CONSUMER_KEY']
  config.consumer_secret = ENV['R_CONSUMER_SECRET']
  config.access_token = ENV['R_OAUTH_TOKEN']
  config.access_token_secret = ENV['R_OAUTH_TOKEN_SECRET']
end

#heroku config:add W_CONSUMER_KEY= W_CONSUMER_SECRET= W_OAUTH_TOKEN= W_OAUTH_TOKEN_SECRET=

AlainTwoots = Twitter::REST::Client.new do |config|
  config.consumer_key = ENV['W_CONSUMER_KEY']
  config.consumer_secret = ENV['W_CONSUMER_SECRET']
  config.access_token  = ENV['W_OAUTH_TOKEN']
  config.access_token_secret = ENV['W_OAUTH_TOKEN_SECRET']

end

result = Tweet.first_or_create(id: 1)

if ARGV[0]

  result_id = 1

else

  result_id = result.tweet_id

end

puts result_id


LatestTweet = AlainTweets.search("from:alaindebotton", :result_type => "recent", :since_id => result_id 
).take(20).to_a.reverse.each do |status|
  puts status.id
  tweettext = status.text
  puts upcase_tweet(tweettext)
  result.tweet_id = status.id
  result.save
  AlainTwoots.update(upcase_tweet(tweettext))

end

  

