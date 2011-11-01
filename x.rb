require 'dropbox_sdk'

open('.env').read.each_line {|l| m=l.scan(/(.*)=(.*)/); ENV[m[0][0]]=m[0][1] }

@session = DropboxSession.new(ENV["DROPBOX_KEY"], ENV["DROPBOX_SECRET"])

@session.set_access_token("8pd39desskytxc3", "qim0w7w5htsqscy")

@client = DropboxClient.new(@session, :dropbox)

begin
  puts @client.account_info.inspect
rescue DropboxAuthError
  puts "Need to reauth!"
  @session.clear_access_token
  @session.get_request_token
  puts "vist: " + @session.get_authorize_url
  puts "Hit enter after hitting"
  gets
  at = @session.get_access_token
  puts at.inspect
end