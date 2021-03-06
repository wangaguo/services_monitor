#!/usr/bin/env ruby

require 'rubygems'
require 'yaml'
require 'logger'
$:.unshift(File.join(File.dirname(__FILE__)))
require 'lib/messagecenter'
Dir.chdir File.join(File.dirname(__FILE__))

def logger(message, level = :info)
  puts "#{level.upcase}: #{message}"
  LOG.try(level, message)
end

begin
  #Init
  CONF = YAML.load_file('monitor.yml')
  LOG = Logger.new(CONF['log_file'])
  LOG.level = Logger::INFO
  LOG.formatter = Logger::Formatter.new

  # Send monitor ok every day.
  if CONF['ok_time'].include? Time.now.strftime('%H:%M')
    send_email(CONF['email_from'], CONF['ok_mail_to'], CONF['ok_mail_subject'], CONF['ok_message']) if CONF['ok_alarms'].include?('email')
    send_slack_bot(CONF['ok_message']) if CONF['ok_alarms'].include?('slack_bot')
  end

  # Start check.
  message = ''
  Dir['./Checker/*.rb'].each do |x| # Load each Checker
    require File.join(File.dirname(x), File.basename(x, '.rb'))

    logmsg = ">>> Run Checker -> #{File.basename(x, '.rb')}"
    logger(logmsg)

    # Run Checker
    message += "\n" if message != ''
    message += eval("#{File.basename(x, '.rb')}.new.checker(CONF, LOG)")

    logmsg = "<<< End Checker -> #{File.basename(x, '.rb')}"
    logger(logmsg)
  end
  send_message(message) if message != ''
rescue => e
  mail_msg = "#{e}\n\n#{e.backtrace}"
  logger(mail_msg, :error)
  send_email(CONF['email_from'], CONF['ok_mail_to'], 'Monitor debug @', mail_msg) if CONF['ok_alarms'].include?('email')
  send_slack_bot("Monitor debug log\n" + mail_msg) if CONF['ok_alarms'].include?('slack_bot')
end
