#!/usr/local/bin/perl

# print $mech->content();
# $mech->forms()->[0]->dump();
# foreach $f ($mech->forms()) { $f->dump() }

#./PCHomeSMS/PCHomeSMS.sh ossf ossfdev ossfdev $nums "$msg" >> $logfile 2>&1


#use lib qw(/u/gcp/85/8517543/perl/lib/perl5/5.8.7
#	/u/gcp/85/8517543/perl/lib/perl5/site_perl/5.8.7/);

use WWW::Mechanize;
use Data::Dumper;
use URI::Escape;

$name = $ARGV[0]; 
$pass = $ARGV[1];
$code = $ARGV[2];
$nums = $ARGV[3]; # comma or space sperated
$message = $ARGV[4];


my $mech = WWW::Mechanize->new( autocheck => 1 );



# 
# Login
#
my $req = HTTP::Request->new(POST => 'https://login.pchome.com.tw/adm/person_sell.htm');
$req->content_type('application/x-www-form-urlencoded');
$req->content("mbrid=${name}%40pchome.com.tw&mbrpass=${pass}&chan=sms&record_ipw=false&ltype=checklogin&buyflag=");
my $res = $mech->request($req);

#
# Fill in the message and numbers
#
my $post_nums = "";
foreach (split /\s+|,/, $nums) {
  $post_nums .= "mobile_phone%5B%5D=$_&";
}
$message = uri_escape($message);
my $post = "${post_nums}encoding_type=ASCII&msg_body=${message}&send_type=1";

$req = HTTP::Request->new(POST => 'http://sms.pchome.com.tw/check_msg.htm');
$req->content_type('application/x-www-form-urlencoded');
$req->content($post);
$res = $mech->request($req);

#
# Auth for payment
#
$mech->forms()->[0]->{'action'}='https://ezpay.pchome.com.tw/auth_access.htm';
###modify @ 
#$mech->submit_form(
#        form_number => 0,  # auth_form
#        fields      => { 'auth_code' => $code }
#    );

print "done\n";
