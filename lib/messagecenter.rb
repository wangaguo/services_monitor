$:.unshift(File.join(File.dirname(__FILE__)))
# require 'msn/msn'
require 'net/smtp'
# require 'plurk/plurk'
# require 'twsmsr4/twsmsr4'

def send_email(from, to, subject, message)
  msg = <<END_OF_MESSAGE
From: #{from}
To: #{to.join(",")}
Subject: #{subject}

#{message}
END_OF_MESSAGE

  Net::SMTP.start('localhost') do |smtp|
    smtp.send_message msg, from, to
  end
end

def send_plurk(id, password, users_id, message)
  begin
    a = Plurk::Base.new(id, password)
    if(!a.login) then return "Login failed." end
    a.add_plurk("#{message} - #{Time.now}" , "says", users_id)
    return true
  rescue
    return $!
  end
end

def send_msn(id, password, users_email, message)
  conn = MSNConnection.new(id, password)

  conn.signed_in = lambda { puts "Signed in" }
  conn.debuglog = nil

  conn.new_chat_session = lambda do |tag, session|
    puts "*** new chat session created with tag '#{tag}'!"
    session.debuglog = nil

    session.session_started = lambda {
      puts "Session with tag '" + tag + "' started!"
      session.say(message)
    }

    session.start
  end

  conn.start
  wait_count = 0
  while true
    sleep 1
    wait_count += 1
    if wait_count == 20 then return("Login failed.") end
    if conn.status.name != "Offline"
      users_email.each do |email|
        m =email.match(/(^.*)@/)
        if !m.nil?
           conn.start_chat(m[1]+"1", email)
           10.times do
             sleep 1
           end
        end
      end
      conn.close
      return("")
    end
  end
end

def send_sms(id, password, sms_users, message)
  hra = ""
  sms = TWSMSR4.new(id, password)
  sms_users.each do |m|
    sms.sendSMS(m, message)
    hra += "#{m}=>#{sms.response.inspect}; "
  end
  return hra
end
