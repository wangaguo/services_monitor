class WebServicesChecker 
  require 'net/http'
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

  def checker(conf)
    retry_max = 5 
    retry_count = 0
    wait_sec = 5
    error_services = ""
    services = conf["services"]
    services.each do |s, url|
      @now_service = s
      if fetch(url) == false then
        retry_count += 1
        if retry_count < retry_max then
          sleep wait_sec
          redo
        else
          error_services += " #{@now_service}"
        end
      end
      retry_count = 0
    end

    if error_services != "" then
      return "services failed: #{error_services}"
    else
      return ""
    end
  end

end
