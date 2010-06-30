#!/usr/bin/env ruby

require 'rubygems'
require 'yaml'
require "logger"
$:.unshift(File.join(File.dirname(__FILE__)))
require 'lib/messagecenter'
Dir.chdir File.join(File.dirname(__FILE__))
require 'WebServicesChecker'

def send_message(message, conf, log)
  if(message != "")
    logmsg = "[fail] #{message}" 
    log.info logmsg 
    puts logmsg 

    alarms = conf["alarms"]
    subject = conf["subject"]
    alarms.each do |alarm|
      case alarm
        when "email" then
          email_from = conf["email_from"]
          email_to = conf["email_to"]
          
          send_email(email_from, email_to, subject, message)
          logmsg = "[send_email] #{email_to}"
          log.info logmsg 
          puts logmsg 
        when "plurk" then
          plurk_account = conf["plurk_account"]
          plurk_password = conf["plurk_password"]
          plurk_users = conf["plurk_users"]
    
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
          msn_account = conf["msn_account"]
          msn_password = conf["msn_password"]
          msn_users = conf["msn_users"] 
    
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
          sms_account = conf["sms_account"]
          sms_password = conf["sms_password"]
          sms_users = conf["sms_users"] 
    
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
end

conf = YAML.load_file('monitor.yaml')
log = Logger.new(conf["log_file"])
log.level = Logger::INFO
log.formatter = Logger::Formatter.new
begin
  log.info ">>> Begin the WebServicesChecker."
  message = WebServicesChecker.new.checker(conf)
  send_message(message, conf, log) 
rescue
  log.error $!
  puts "Some error occur."
end
