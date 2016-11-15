$:.unshift(File.join(File.dirname(__FILE__)))
# require 'msn/msn'
require 'net/smtp'
# require 'plurk/plurk'
# require 'twsmsr4/twsmsr4'
require 'slack-ruby-client'

def send_email(from, to, subject, message)
  logger("[send_email] #{to}")
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
  rescue => e
    return e
  end
end

def send_slack_bot(message)
  Slack.configure do |config|
    config.token = CONF['slack_bot']['token']
    raise "Missing CONF['slack_bot']['token']!" unless config.token
  end

  client = Slack::Web::Client.new
  CONF['slack_bot']['channels'].each do |channel|
    logger("[send_slack_bot] ##{channel}")
    begin
      client.chat_postMessage(channel: "##{channel}", text: message, as_user: true)
    rescue => e
      logmsg = "[send_slack_bot status] ##{channel}: #{e}"
      logger(logmsg, :error)
    end
  end
rescue => e
  logmsg = "[send_slack_bot status] #{e}"
  logger(logmsg, :error)
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

def send_message(message)
  if(message != "")
    logmsg = "[fail] #{message}"
    logger(logmsg)
    short_message = message.gsub(/{[^{]*}/, "")

    alarms = CONF["alarms"]
    subject = CONF["subject"]
    alarms.each do |alarm|
      case alarm
        when "email" then
          email_from = CONF["email_from"]
          email_to = CONF["email_to"]

          send_email(email_from, email_to, subject, message)
          logmsg = "[send_email] #{email_to.inspect.to_s}"
          logger(logmsg)
        when "slack_bot" then
          send_slack_bot(message)
        when "plurk" then
          plurk_account = CONF["plurk_account"]
          plurk_password = CONF["plurk_password"]
          plurk_users = CONF["plurk_users"]

          logmsg = "[send_plurk] #{plurk_users.inspect.to_s}"
          logger(logmsg)

          hr = send_plurk(plurk_account, plurk_password, plurk_users, subject + "\n" + message)
          if hr != true then
            logmsg = "[send_plurk status] #{hr}"
            logger(logmsg, :error)
          end
        when "msn" then
          msn_account = CONF["msn_account"]
          msn_password = CONF["msn_password"]
          msn_users = CONF["msn_users"]

          logmsg = "[send_msn] #{msn_users.inspect.to_s}"
          logger(logmsg)

          hr = send_msn(msn_account, msn_password, msn_users, subject + "\n" + message)
          if hr != ""
            logmsg = "[send_msn status] #{hr}"
            logger(logmsg, :error)
          end
        when "sms" then
          #before sms resend will check the sms_time_file.
          sms_time_file = "sms_send_time.txt"
          sms_last_time = 0
          if File::exists?(sms_time_file)
            f = File.open(sms_time_file)
            sms_last_time = f.read.to_i
          end

          if (Time.now.to_i - sms_last_time) > (60*CONF["sms_resend_min"].to_i)
            f = File.new(sms_time_file, "w")
            f.write(Time.now.to_i.to_s)
            f.close
            sms_account = CONF["sms_account"]
            sms_password = CONF["sms_password"]
            sms_users = CONF["sms_users"]

            logmsg = "[send_sms] #{sms_users.inspect.to_s}"
            logger(logmsg)

            hr = send_sms(sms_account, sms_password, sms_users, subject + "\n" + short_message)
            if hr != ""
              logmsg = "[send_sms status] #{hr}"
              logger(logmsg, :error)
            end
          end
        end
      end

    logmsg = "fail message is sent."
    logger(logmsg)
  else
    logmsg = "Check is done. No error."
    logger(logmsg)
  end
end
