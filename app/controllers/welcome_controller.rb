class WelcomeController < ApplicationController

  # Initializing global hashmaps
  before_action :set_admin
  def set_admin
    @hashTagsArray=Hash.new
    @userMentionArray=Hash.new
  end

  # Implementing differnet checks on the search term
  # If the search term is nil, render index page
  # search term parameter length should be greater than zero and
  #shouldnot contain only space, to call trendAnalyser function
  def index
    if params[:term].nil?
      render "index"
    else
      mySearchTerm = params[:term]
      puts "#{mySearchTerm}"
      if mySearchTerm.length > 0 && ! mySearchTerm.squish.empty?
        trendAnalyser(mySearchTerm)
      else
        redirect_to action: :index
      end
    end
  end


  def trendAnalyser(mySearchTerm)
    puts "#{mySearchTerm}"

    # API keys we need to connect to the Twitter API, access to the whole Twitter API via the client object.
    require 'twitter'
      client = Twitter::REST::Client.new do |config|
        config.consumer_key        = "####"
        config.consumer_secret     = "####"
        config.access_token        = "####"
        config.access_token_secret = "####"
      end

      #####################################################
      ##### FINDING AND COUNTING USER MENTIONS ############
      ####################################################
      # This method will return an array of most recent 100 entities objects from tweets,
      # extract screen_name from user_mention attribute
      # screen_name should not be empty, it is neglected
      client.search(mySearchTerm, result_type: "recent").take(100).collect do |entities|
        entities.user_mentions.each do |userMention|
            if userMention.screen_name == ""
              puts "----------------- "
            else
              # if the hashmap which is userMentionArray already has key as current username,
              # the value corresponding to this key will be appended by 1, othewise value is set to be 1
              username=userMention.screen_name
              if @userMentionArray.has_key? (username)
                @userMentionArray[username]=@userMentionArray[username]+1
              else
                @userMentionArray[username]=1
              end
            end
        end
      end

      # sorting the userMentionArray according to the values
      # the sort returns the array in increasing order so, it is reversed
      @userMentionArray.each do|_key,value|
        @userMentionArray=@userMentionArray.sort_by {|_key, value| value}.reverse
      end

      #####################################################
      ##### FINDING AND COUNTING HASHTAGS  ###############
      ####################################################
      # This method will return an array of most recent 100 entities objects from tweets,
      # extract hashtag attribute from each entity
      # hashtag.text should not be empty, it is neglected
      client.search(mySearchTerm, result_type: "recent").take(100).collect do |entities|
        entities.hashtags.each do |val|
          if val.text == ""
            puts "----------------- "
          else
            # if the hashmap which is hashTagsArray already has key as current hashtagName,
            # the value corresponding to this key will be appended by 1, othewise value is set to be 1
            hashtagName=val.text
            if @hashTagsArray.has_key? (hashtagName)
              @hashTagsArray[hashtagName]=@hashTagsArray[hashtagName]+1
            else
              @hashTagsArray[hashtagName]=1
            end
          end
        end
      end
      # sorting the hashTagsArray according to the values
      @hashTagsArray.each do|_key,value|
        @hashTagsArray=@hashTagsArray.sort_by {|_key, value| value}.reverse
      end

  end

  #permiting the variable 'term' which is the imput taken from the user to be used in welcome controller
  def search_params
    params.require(:welcome).permit(:term)
  end
end
