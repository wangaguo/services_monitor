require 'rubygems'
require 'xmlsimple'
require 'uri'
require 'net/http'
class TWSMSR4
  attr_accessor :send_options
  attr_accessor :query_options
  attr_accessor :mo_query_options
  attr_reader :response
  def initialize(username, password)
    @@SEND_URL = "http://api.twsms.com/smsSend.php?"
    @@QUERY_URL = "http://api.twsms.com/smsQuery.php?"
    @@MO_QUERY_URL = "http://api.twsms.com/moQuery.php?"
    
    @uname, @upwd = username, password
    @send_options = {
      :sendtime => "",
      :expirytime => "86400",
      :popup => "",
      :mo => "Y",
      :longsms => "Y",
      :drurl => ""
    }
    
    @query_options = {
      :deltime => "N",
      :checkpoint => "N",
      :mobile => "", 
      :msgid => ""
    }

    @mo_query_options = {
      :snumber => "",
      :sdate => ""
    }
  end
  
  public
  
  def sendSMS(mobile, message, opt={})
    args = []
    @send_options[:mobile], @send_options[:message] = mobile.gsub(/-/, ""), message
    @send_options.merge!(opt).each{|k, v| args << k.to_s + "=" + URI::escape(v.to_s)}
    puts args.inspect
    url = @@SEND_URL + "username=" + @uname + "&password=" + @upwd + "&" + args.join("&")
    puts url
    return self.check_response(Net::HTTP.get(URI.parse(url)))
  end
  
  def querySMS
    args = []
    @query_options.each{|k, v| args << k.to_s + "=" + URI::escape(v.to_s)}
    url = @@QUERY_URL + "username=" + @uname + "&password=" + @upwd + "&" + args.join("&")
    puts url
    
    return self.check_response(Net::HTTP.get(URI.parse(url)), "query")
  end

  def moquerySMS
    args = []
    @mo_query_options.each{|k, v| args << k.to_s + "=" + URI::escape(v.to_s)}
    url = @@MO_QUERY_URL + "username=" + @uname + "&password=" + @upwd + "&" + args.join("&")
    puts url
    
    return self.check_response(Net::HTTP.get(URI.parse(url)), "query")
  end

  protected
  
  def check_response(resp, type="send")
    @response = XmlSimple.xml_in(resp, {'ForceArray' => false, 'AttrPrefix' => true}) 
    if type == "send" 
	@query_options[:msgid] = @response["msgid"]
	@query_options[:mobile] = @send_options[:mobile]
    end
    return @response["code"]
  end
end
