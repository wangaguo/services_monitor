#!/usr/bin/env ruby

require 'rubygems'
require 'net/http'
require 'yaml'
require "logger"
$:.unshift(File.join(File.dirname(__FILE__)))
require 'lib/messagecenter'
Dir.chdir File.join(File.dirname(__FILE__))

@error_services = ""
@now_service = ""

def fetch(uri_str, limit = 10)
  puts "---> #{uri_str}"
  raise ArgumentError, 'HTTP redirect too deep' if limit == 0
  
  begin 
    response = Net::HTTP.get_response(URI.parse(uri_str))
  rescue
    puts $!
    return false 
  end

  case response
  when Net::HTTPSuccess, Net::HTTPUnauthorized then
    puts "#{@now_service} ok!!"
    return true
  when Net::HTTPRedirection then 
    puts "redir to: #{response['location']}"
    fetch(response['location'], limit - 1)
  else
    puts "#{@now_service} error!!"
    return false
  end
end

def checker
  retry_max = 3
  retry_count = 0
  wait_sec = 5
  services = @conf["services"]
  services.each do |s, url| 
    @now_service = s
    if fetch(url) == false then 
      retry_count += 1
      if retry_count < retry_max then
        sleep wait_sec
        redo
      else
        @error_services += " #{@now_service}"
      end
    end
    retry_count = 0   
  end
end

@conf = YAML.load_file('monitor.yaml')
log = Logger.new(@conf["log_file"])
log.level = Logger::INFO
log.formatter = Logger::Formatter.new
begin
  checker
  
  if(@error_services != "")
    message = "services failed: #{@error_services}"
    logmsg = "[fail] #{message}" 
    log.info logmsg 
    puts logmsg 

    alarms = @conf["alarms"]
    subject = @conf["subject"]
    alarms.each do |alarm|
      case alarm
        when "email" then
          email_from = @conf["email_from"]
          email_to = @conf["email_to"]
          
          send_email(email_from, email_to, subject, message)
          logmsg = "[send_email] #{email_to}"
          log.info logmsg 
          puts logmsg 
        when "plurk" then
          plurk_account = @conf["plurk_account"]
          plurk_password = @conf["plurk_password"]
          plurk_users = @conf["plurk_users"]
    
          logmsg = "[send_plurk] #{plurk_users.inspect.to_s}"
          log.info logmsg 
          puts logmsg 

          hr = send_plurk(plurk_account, plurk_password, plurk_users, subject + "\n" + message)
          if hr != true then 
            logmsg = "[send_plurk status] #{hr}"
            log.error logmsg
            puts logmsg
          end
        when "msn" then
          msn_account = @conf["msn_account"]
          msn_password = @conf["msn_password"]
          msn_users = @conf["msn_users"] 
    
          logmsg = "[send_msn] #{msn_users.inspect.to_s}"
          log.info logmsg 
          puts logmsg 

          hr = send_msn(msn_account, msn_password, msn_users, subject + "\n" + message)
          if hr != ""
            logmsg = "[send_msn status] #{hr}"
            log.error logmsg 
            puts logmsg 
          end
        when "sms" then
          sms_account = @conf["sms_account"]
          sms_password = @conf["sms_password"]
          sms_users = @conf["sms_users"] 
    
          logmsg = "[send_sms] #{sms_users.inspect.to_s}"
          log.info logmsg 
          puts logmsg 

          hr = send_sms(sms_account, sms_password, sms_users, subject + "\n" + message)
          if hr != ""
            logmsg = "[send_sms status] #{hr}"
            log.error logmsg 
            puts logmsg 
          end
        end
      end

    logmsg = "fail message is sent."
    log.info logmsg 
    puts logmsg 
  else
    logmsg = "Check is done. No error."
    log.info logmsg
    puts logmsg
  end
rescue
  log.error $!
  puts "Some error occur."
end
