require 'sinatra'
require 'dropbox_sdk'

TOKEN_PATH = "/tmp/oauth2_token"
TOKEN_SECRET_PATH = "/tmp/oauth2_secret"

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

  if File.exists?(TOKEN_PATH) && File.exists?(TOKEN_SECRET_PATH)
    @session.set_access_token(open(TOKEN_PATH).read.chomp, open(TOKEN_SECRET_PATH).read.chomp)
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
    raise token.inspect
    open(TOKEN_PATH, 'w') {|f| f.puts token.key}
    open(TOKEN_SECRET_PATH, 'w') {|f| f.puts token.secret}

    redirect '/'
  else
    erb "Sorry, must have expired"
  end
end