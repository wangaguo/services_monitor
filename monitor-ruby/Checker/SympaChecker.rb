class SympaChecker 
  def checker(conf, log)
    begin
      if Time.now.strftime("%H:%M") == conf["ok_mail_time"]
        send_email(conf["email_from"], conf["sympa_monitor_mail_to"], "Monitor Sympa - #{Time.now.strftime("%Y/%m/%d")}", "Sympa is ok.")
      end
      return "" 
    rescue
      puts "#{$!}"
      return "#{$!}"
    end
  end
end
