<?php
#################################################################################
# Created by Roger Nem                                                          #
#                                                                               #
# Generates CSR for SSL certificates                                            #
#                                                                               #
# v0.001 - Roger Nem -  File created - Aug 2017                                 #
#################################################################################

$submitted = false;
$error = false;
$sans = '';

if ($_POST)
{
  $sans = $_POST['sans'];
  if (strlen(trim($sans)) > 0)
  {
    $submitted = true;
    $sansarr = explode("\n", $sans);
    $cn = trim($sansarr[0]);

    foreach ($sansarr as $key => $val)
    {
      $sansarr[$key] = trim($val);
    }
    #echo 'sh create_csr.sh ' . implode(' ', $sansarr);
    $cleanedsans = implode(' ', $sansarr);
    `sh create_csr.sh $cleanedsans`;
  }
}

?>

<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN"
       "http://www.w3.org/TR/html4/loose.dtd">
<html>
<head>
<title>CSR Generator</title>
</head>
<body>
<h2>CSR Generator</h2>
<?php
if ($submitted == true)
{
  echo 'Your certificate and key have been created:<br />';
  echo '<a href="repo/' . $cn . '.key" target="new">' . $cn . '.key</a><br />';
  echo '<a href="repo/' . $cn . '.csr" target="new">' . $cn . '.csr</a><br />';
  echo '<br />';
}
?>
Please enter Subject Alternative Names, one per line. The first entry in the list will also be used as the Common Name.<br />
<span style="color:red">Wildcards (e.g. *.domain.tld) are not to be used under any circumstances.</span><br />
<br />
<form action="index.php" method="post">
 <textarea name="sans" cols="70" rows="10"><?php echo $sans ?></textarea><br />
 <input type="submit" value="Generate CSR" />
</form>
</form>
</body>
</html>
