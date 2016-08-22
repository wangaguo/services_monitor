%w"date uri cgi net/http".each{|r| require r}

$:.unshift(File.join(File.dirname(__FILE__)))
require 'lib/twsmsr'
