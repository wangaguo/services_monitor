#!/usr/local/bin/perl

use HTTP::Request;
use LWP::UserAgent;
use HTTP::Status;
$url = $ARGV[0]; 

# 
# post 
# see http://kobesearch.cpan.org/htdocs/libwww-perl/HTTP/Status.html
#
$r = HTTP::Request->new(POST=>$url);
$ua = LWP::UserAgent->new;
$rc = $ua->request($r)->status_line;

if(is_success($rc)){print 1;}
elsif(is_redirect($rc)){print 1;}
#elsif(is_client_error($rc))
#elsif(is_server_error($rc)){print 0;}
elsif(is_error($rc))
{
  if($rc =~ m/^401/){print 1;}
  else{print 0;}
}
#else{print $rc;}

