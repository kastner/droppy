require 'dropbox_sdk'

class DroppyBox
  def session
    @session ||= DropboxSession.new(ENV["DROPBOX_KEY"], ENV["DROPBOX_SECRET"])
  end

  def client?
    client
  end

  def client
    return nil unless ENV["DROPBOX_TOKEN"]

    @client ||= begin
      (key, secret) = ENV["DROPBOX_TOKEN"].split(":")
      session.set_access_token(key, secret)
      db_type = (ENV["DROPBOX_TYPE"]) ? ENV["DROPBOX_TYPE"].to_sym : :dropbox
      DropboxClient.new(session, db_type)
    end
  end

  def path
    @path ||= (ENV["DROPBOX_PATH"] || "droppy")
  end
end
