<?php
#################################################################################
# Created by Roger Nem                                                          #
#                                                                               #
# Alert if the limit of DB connections reaches a defined threshold              #
# It leverages MySQL connection                                                 #
#                                                                               #
# v0.001 - Roger Nem -  File created - 2017                                     #
#################################################################################

// 1. Connect to local DB server
$conn = mysql_connect('localhost','user','password') or die("Unable to Connect: ".mysql_error());
$db = mysql_select_db("db_stats",$conn);
$db_percentile = array();
$dbservers = array(
                "192.168.0.100",
                "192.168.0.101",
                "192.168.0.102",
                "192.168.0.103",
                "192.168.0.104",
                "192.168.0.105"
                );
echo date('D M j G:i:s T Y')."\n\n";

// 2. Loops throught DBs and query their information
for($db=0; $db<count($dbservers); $db++) {

	$dbserver =  $dbservers[$db];
	$connlimit = shell_exec('mysql -u user -h '.$dbserver.' -p***** -e "show variables like \'%max_connection%\';"');
	$conncurr = shell_exec('mysql -u user -h '.$dbserver.' -p***** -e "show status like \'%threads_connected\';"');
	$connlimit = (explode("\t",$connlimit));
	$conncurr = (explode("\t",$conncurr));
	$percenta = $conncurr['2']/$connlimit['2']*100;
	$db_percentile[] = number_format($percenta, 2, '.', '');
	echo "DB Server:\t".$dbserver."\n";
	echo "Connection Limit:\t".$connlimit['2'];
	echo "Current Connections:\t".$conncurr['2'];
	echo "Connection Percentage:\t".number_format($percenta, 2, '.', '')."%";
	echo "\n#############################################################\n";
	//$addtodb = mysql_query("INSERT INTO tbl_mxconnections VALUES ('', '.$dbserver.', '$connlimit[2]','$conncurr[2]', CURRENT_TIMESTAMP)") or die("Could not add records: ".mysql_error());

	#Send mail if threshold met, which is greater than 80%
	$message = "The database connections limit for the server $dbserver has reached above 80%\n For further information, please check pma server";
	if($percenta > 80) {
			mail("DL1@domain.com,DL2@domain.com","DB Connections Alert",$message);
	}
}

// 3. Record results to corresponding table in DB
$db_values = implode(", ", $db_percentile);
$addtodb = mysql_query("INSERT INTO tbl_mxconnections VALUES ('', '$db_values', CURRENT_TIMESTAMP)") or die("Could not add records: ".mysql_error());
?>
