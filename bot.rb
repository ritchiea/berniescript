require "/home/ar/projects/berniescript/twitter_client.rb"

def overwrite_status
  f = File.new("status", "w+")
  f.close
end

File.open("status", "r") do |f|
  if f.read.match("progress")
    puts "another script in process"
    abort
  end
end
f = File.new("status", "w+")
f.write "in progress\n"
f.close
f = File.new("last_run", "w+")
f.write "#{Time.now.to_s}\n"
f.close
begin
  puts "connecting to client"
  tc = TwitterClient.new
  puts "getting latest"
  #latest = tc.client.user_timeline('the_fire_berns').first
  latest_file = File.open("last_tweet", "r")
  latest = latest_file.read.gsub("\n",'')
  latest_file.close
  tweets = []
  if latest
    puts "getting tweets"
    berns = tc.client.search('"feel the bern" -rt', since_id: latest)
    puts berns.inspect
    berns.each do |tweet|
      tweets << tweet
    end
  else
    puts "no last tweet"
    overwrite_status
    abort
    #tc.client.search('"feel the bern" -rt', result_type: "recent").each do |tweet|
    #  puts tweet.inspect
    #  tweets << tweet
    #end
  end
  if tweets.empty?
    puts "no tweets"
  end
  tweets.reverse.each_with_index do |tweet, i|
    puts "retweeting..."
    puts tweet.inspect
    begin
      tc.client.retweet(tweet)
    rescue Twitter::Error::Unauthorized
      puts "can't retweet"
      next
    rescue Twitter::Error::Forbidden
      puts "can't retweet"
      next
    rescue Twitter::Error::AlreadyRetweeted
      puts "already retweeted"
      next
    end
    if i < tweets.length - 1
      sleep 5
    end
    if i == tweets.length - 1
      #last tweet
      puts "writing last tweet #{tweet.id}"
      last_tweet = File.new("last_tweet", "w+")
      last_tweet.write tweet.id
      last_tweet.close
    end
  end
  overwrite_status
rescue StandardError => e
  puts "failed"
  puts e.message
  puts e.backtrace
  puts e.inspect
ensure
  overwrite_status
end
