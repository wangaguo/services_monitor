class WebServicesChecker 
  require 'net/http'

  @now_service = ""

  def fetch(uri_str, limit = 10)
    puts "---> #{uri_str}"
    raise ArgumentError, 'HTTP redirect too deep' if limit == 0

    begin
      response = nil
      Timeout::timeout(20) do |length|
        response = Net::HTTP.get_response(URI.parse(uri_str))
      end
    rescue
      puts $!
      return "#{@now_service}(#{$!})" 
    end

    case response
    when Net::HTTPSuccess, Net::HTTPUnauthorized then
      puts "#{@now_service} ok!!"
      return true
    when Net::HTTPRedirection then
      puts "redir to: #{response['location']}"
      fetch(response['location'], limit - 1)
    else
      puts "#{@now_service} error!! (#{response})"
      return "#{@now_service}(#{response.code})"
    end
  end

  def checker(conf, log)
    begin
     retry_max = conf["retry_max"] || 1 
     wait_sec = conf["wait_sec"] || 1 
     retry_count = 0
     error_services = ""
     fetch_total = 0
     fetch_retry = 0

     services = conf["services"] || []
     services.each do |s, url|
       @now_service = s
       fetch_s = Time.now
       hr = fetch(url)
       fetch_e = Time.now 
       fetch_retry += fetch_e - fetch_s 
       puts "run time: #{fetch_retry}s"
       if hr != true then
         retry_count += 1
         if retry_count < retry_max then
           sleep wait_sec
           redo
         else
           error_services += " #{hr}"
         end
       end
       fetch_total += fetch_retry
       #log.info "#{s}, #{fetch_retry}s"
       fetch_retry = 0
       retry_count = 0
     end
 
     log.info "fetch total time: #{fetch_total}s"
     if error_services != "" then
       return "services failed: #{error_services}"
     else
       return ""
     end
    rescue
      return "#{$!}"
    end
  end
end
