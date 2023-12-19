<?php
#################################################################################
# Created by Roger Nem															#
#																				#
# Password Tracking process														#
#																				#
# v0.001 - Roger Nem -  File created - Apr 2017                                 #
#################################################################################

require_once '/etc/phpMyAdmin/pwtrack.inc.php';

print "\nStarting pwtrack process...\n\n";

foreach ($dbservs as $dbserv)
{
        print "Current DB: '$dbserv'\n";

  $conn = mysql_connect($dbserv, $pwtrackuser, $pwtrackpass) or die(mysql_error());

  // Find and update changed passwords
  $myq1 = mysql_query("SELECT pwtrack.user, pwtrack.host, user.password
    FROM pwtrack.pwtrack, mysql.user
    WHERE pwtrack.user=user.user AND pwtrack.host=user.host
    AND pwtrack.password!=user.password
    AND pwtrack.password LIKE '*%'", $conn);

  while ($res1 = mysql_fetch_array($myq1))
  {
    $pass = $res1['password'];
    $user = $res1['user'];
    $host = $res1['host'];
    mysql_query("UPDATE pwtrack.pwtrack
     SET password='$pass', lastchange=NOW()
     WHERE user='$user' AND host='$host'", $conn) or die($dbserv . ' 1 ' . mysql_error());
  }

  // Insert new users
  mysql_query("INSERT INTO pwtrack.pwtrack (host, user, password, lastchange)
    SELECT user.host, user.user, user.password, NOW()
    FROM mysql.user LEFT JOIN pwtrack.pwtrack
    ON user.host = pwtrack.host AND user.user = pwtrack.user
    WHERE pwtrack.user IS NULL", $conn) or die($dbserv . ' 2 ' . mysql_error());
}

print "\nFinishing pwtrack process...\n";
