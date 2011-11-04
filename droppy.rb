require 'sinatra'
require './droppy_box'

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
end

before do
  @nav = {
    '/'       => 'Files',
    '/about'  => 'About'
  }

  @droppy_box = DroppyBox.new

  start_auth_flow unless @droppy_box.client? or request.path.match(%r{/auth})
end

def start_auth_flow
  @droppy_box.session.clear_access_token
  request_token = @droppy_box.session.get_request_token
  session[:request_token] = request_token
  redirect @droppy_box.session.get_authorize_url(url('/auth'))
end

get '/' do
  begin
    @files = @droppy_box.client.metadata("/" + @droppy_box.path)
    erb :files
  rescue DropboxAuthError
    start_auth_flow
  end
end

get '/about' do
  erb :about
end

get '/get/:file' do
  path = File.join(@droppy_box.path, params[:file])
  redirect @droppy_box.client.media(File.join(@droppy_box.path, params[:file]))["url"]
end

get '/auth' do
  if request_token = session[:request_token]
    @droppy_box.session.set_request_token(request_token.key, request_token.secret)
    token = @droppy_box.session.get_access_token
    erb "Here is your DROPBOX_TOKEN=#{token.key}:#{token.secret}"
  else
    erb "Sorry, must have expired"
  end
end
