require 'clockwork'
require 'pony'

require './droppy_box'

include Clockwork

@files = {}
@droppy_box = DroppyBox.new

Pony.options = { 
  :via => :smtp, 
  :from => ENV["GMAIL_USER"],
  :via_options => {
    :address              => 'smtp.gmail.com',
    :port                 => '587',
    :enable_starttls_auto => true,
    :user_name            => ENV["GMAIL_USER"],
    :password             => ENV["GMAIL_PASS"],
    :authentication       => :plain,
    :domain               => "localhost.localdomain"
  }
}

handler do |job|
  old_files = @files
  begin
    @files = @droppy_box.client.metadata("/" + @droppy_box.path)

    # don't email the first time you're populating
    next if @files.key?("hash") && old_files.empty?
  rescue DropboxAuthError
    next
  end

  if old_files["hash"] != @files["hash"]
    # something changed...
    # look for new files
    new_files = (@files["contents"] - old_files["contents"]).map do |f|
      f["path"].gsub(/^#{@files["path"]}\//, '')
    end
    
    if new_files && ! new_files.empty?
      subject = "New file#{"s" if new_files.count > 1} ready to download: #{new_files.join(", ")}"
      body = "Get them here:"
      new_files.each do |file|
        body += "\n\t#{ENV["DROPPY_URL"]}/get/#{file}"
      end
      
      puts %Q{Sending email with subject: "#{subject}" to #{ENV["EMAIL_NOTIFY_LIST"]}}

      puts Pony.mail(:to => ENV["EMAIL_NOTIFY_LIST"], :subject => subject, :body => body)
    end
  end
end

if ENV["EMAIL_NOTIFY_LIST"]
  every(10.seconds, 'check_for_new_files')
end
