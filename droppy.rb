require 'sinatra'
require 'dropbox_sdk'

if ENV["AUTH_USERNAME"] && ENV["AUTH_PASSWORD"]
  use Rack::Auth::Basic do |username, password|
    username == ENV["AUTH_USERNAME"] && password == ENV["AUTH_PASSWORD"]
  end
end

configure do
  enable :sessions
end

helpers do
  def base_url
    @base_url ||= "#{request.env['rack.url_scheme']}://#{request.env['HTTP_HOST']}"
  end

  def dropbox_path
    @dropbox_path ||= (ENV["DROPBOX_PATH"] || "droppy")
  end
end

# Get the dropbox auth token
before do
  @nav = {
    '/'       => 'Home',
    '/files'  => 'Files'
  }
  
  @client = nil
  @session = DropboxSession.new(ENV["DROPBOX_KEY"], ENV["DROPBOX_SECRET"])

  if ENV["DROPBOX_TOKEN"]
    (key, secret) = ENV["DROPBOX_TOKEN"].split(":")
    @session.set_access_token(key, secret)
    db_type = (ENV["DROPBOX_TYPE"]) ? ENV["DROPBOX_TYPE"].to_sym : :dropbox
    @client = DropboxClient.new(@session, db_type)
  end

  start_auth_flow unless @client or request.path.match(%r{/auth})
end

def start_auth_flow
  @session.clear_access_token
  request_token = @session.get_request_token
  session[:request_token] = request_token
  redirect @session.get_authorize_url(url('/auth'))
end

get '/' do
  erb :index
end

get '/files' do
  begin
    @files = @client.metadata("/" + dropbox_path)
    erb :files
  rescue DropboxAuthError
    start_auth_flow
  end
end

get '/get/:file' do
  path = File.join(dropbox_path, params[:file])
  redirect @client.media(File.join(dropbox_path, params[:file]))["url"]
end

get '/auth' do
  if request_token = session[:request_token]
    @session.set_request_token(request_token.key, request_token.secret)
    token = @session.get_access_token
    erb "Here is your DROPBOX_TOKEN=#{token.key}:#{token.secret}"
  else
    erb "Sorry, must have expired"
  end
end