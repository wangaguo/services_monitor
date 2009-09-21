class TWSMSR
  def initialize(username, password)
    @@SEND_URL = "http://api.twsms.com/send_sms.php?"
    @@QUERY_URL = "http://api.twsms.com/query_sms.php?"
    
    @uname, @upwd = username, password
    @send_options = {
      :type => "now",
      :popup => "",
      :mo => "Y",
      :vldtime => "86400",
      :modate => "",
      :dlvtime => "",
      :wapurl => "",
      :encoding => "big5"
    }
    
    @query_options = {
      :type => "now",
      :msgid => "",
      :monumber => "",
      :sdate => "",
      :edate => ""
    }
    
    @@send_errors = {
      -1.to_s.to_sym => "Send failed",
      -2.to_s.to_sym => "Username or password is invalid",
      -3.to_s.to_sym => "Popup tag error",
      -4.to_s.to_sym => "Mo tag error",
      -5.to_s.to_sym => "Encoding tag error",
      -6.to_s.to_sym => "Mobile tag error",
      -7.to_s.to_sym => "Message tag error",
      -8.to_s.to_sym => "vldtime tag error",
      -9.to_s.to_sym => "dlvtime tag error",
      -10.to_s.to_sym => "You have no point",
      -11.to_s.to_sym => "Your account has been blocked",
      -12.to_s.to_sym => "Type tag error",
      -13.to_s.to_sym => "You can't send SMS message by dlvtime tag if you use wap push",
      -14.to_s.to_sym => "Source IP has no permission",
      -99.to_s.to_sym => "System error!! Please contact the administrator, thanks!!"
    }
    
    @@query_errors = {
      0.to_s.to_sym => "Message already been sent or reserving message has been deleted",
      -1.to_s.to_sym => "Could not find the message id or ",
      -2.to_s.to_sym => "Username or password is invalid",
      -3.to_s.to_sym => "The reserving message does send yet",
      -4.to_s.to_sym => "Type tag error",
      -5.to_s.to_sym => "The target mobile did not callback",
      -6.to_s.to_sym => "Failed on sent message to the operator",
      -7.to_s.to_sym => "No short code",
      -8.to_s.to_sym => "No return message",
      -9.to_s.to_sym => "sdate or edate setting error",
      -10.to_s.to_sym => "No record of ",
      -11.to_s.to_sym => "Your account has been blocked",
      -12.to_s.to_sym => "Your message maybe invalid",
    }
  end
  
  public
  
  def sendSMS(mobile, message, opt={})
    args = []
    @send_options[:mobile], @send_options[:message] = mobile.gsub(/-/, ""), message
    self.check_send_val
    (raise ArgumentError, "dlvtime is invalid";return false) unless self.check_date("dlvtime") if opt[:type] =~ /^dlv$/
    @send_options.merge!(opt).each{|k, v| args << k.to_s + "=" + CGI::escape(v.to_s)}
    url = @@SEND_URL + "username=" + @uname + "&password=" + @upwd + "&" + args.join("&")
    return self.check_response(Net::HTTP.get(URI.parse(url)))
  end
  
  def querySMS
    options = @query_options
    url = @@QUERY_URL + "username=" + @uname + "&password=" + @upwd
    url = url + "&type=" + options[:type].to_s
    url = url + "&msgid=" + options[:msgid].to_s if options[:type].to_s =~ /^(now|dlv(del)?)$/
    url = url + "&monumber=" + options[:monumber].to_s if options[:type].to_s =~ /^mo$/
    url = url + "&sdate=" + options[:sdate].to_s if options[:type].to_s =~ /^backpoint$/
    url = url + "&edate=" + options[:edate].to_s if options[:type].to_s =~ /^backpoint$/
    
    unless self.check_date("sdate") || self.check_date("edate")
      raise ArgumentError, "sdate or edate is invalid."
      return false
    end if @query_options[:type].to_s =~ /backpoint/
    
    return self.check_response(Net::HTTP.get(URI.parse(url)), "query")
  end
  
  def message_id
    return @query_options[:msgid].to_s
  end
  
  def message_id=(msgid)
    @query_options[:msgid] = msgid
    return true
  end
  
  protected
  
  def check_response(resp, type="send")
    resp =~ /^resp=(\d?),/
    return @@query_errors[$1.to_sym] if type =~ /^query$/
    return @@send_errors[$1.to_sym] if $1.to_i < 0
    @query_options[:msgid] = $1.to_s
    return $1.to_s
  end
  
  def check_send_val
    @send_options[:type] = "now" unless @send_options[:type].to_s =~ /^(now|dlv)$/i
    @send_options[:dlvtime] = "" unless @send_options[:type].to_s =~ /^(dlv)$/i
    @send_options[:wapurl] = "" unless @send_options[:type].to_s =~ /^((u)?push)$/i
    @send_options[:mo].upcase!
    return nil
  end
  
  def check_date(type="dlvtime")
    case type
      when /^dlvtime$/
        d = DateTime.parse(@send_options[:dlvtime])
        vc = Date.valid_civil?(d.year, d.month, d.day)
        vt = Date.valid_time?(d.hour, d.min, d.sec)
        return true if vc == vt
      when /^(s|e)date$/
        d = DateTime.parse(@query_options[:"#{type}"])
        return true if Date.valid_civil?(d.year, d.month, d.day)
    end
    return false
  end
end
