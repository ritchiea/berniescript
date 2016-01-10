require "/home/ar/projects/berniescript/twitter_client.rb"

begin
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
  puts "connecting to client"
  tc = TwitterClient.new
  puts "getting latest"
  latest = tc.client.user_timeline('berniebot_').first
  tweets = []
  if latest
    puts "getting tweets"
    tc.client.search('"feel the bern" -rt', since_id: latest.id).each do |tweet|
      tweets << tweet
    end
  else
    tc.client.search('"feel the bern" -rt', result_type: "recent").each do |tweet|
      puts tweet.inspect
      tweets << tweet
    end
  end
  tweets.reverse.each_with_index do |tweet, i|
    puts "retweeting..."
    puts tweet.inspect
    tc.client.retweet(tweet)
    sleep 10 if i < tweets.length - 1
  end
  f = File.new("status", "w+")
  f.close
rescue => e
  puts "failed"
  puts e.message
  puts e.backtrace
  puts e.inspect
end
