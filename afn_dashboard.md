# AFN dashboard http://dashboard.austinfree.net

## 2017-6-20

Here's [production](http://dashboard.austinfree.net) and here's [the dev site](https://oliveratutexas.github.io/AustinFreeNet2017/).  I've uploaded my ssh public key so now I have shell access to the AFN inmotionhosting shared hosting account.

The busted production dashboard was caused by a mysql php library versioning issue.  The version used in development was the old [mysql lib](http://php.net/manual/en/function.mysql-fetch-array.php) while the version in production is the newer [mysqli lib](http://php.net/manual/en/mysqli-result.fetch-array.php).

Here's the diff:
    
    commit d43ab51a28f19a6d8c291ba7d6461491051c4bb6
    Author: Ryan Nowakowski <tubaman@fattuba.com>
    Date:   Tue Jun 20 11:30:18 2017 -0500
    
        Use the newer mysqli fetch_row syntax
        
        Our production host uses the newer mysqli php library.  Convert the
        older mysql fetch_row calls to the newer mysqli format so that
        fetch_data.php will run without error.
    
    diff --git a/fetch_data.php b/fetch_data.php
    index 6d479fd..63197ff 100755
    --- a/fetch_data.php
    +++ b/fetch_data.php
    @@ -7,7 +7,7 @@
     
         $myArray = array();
         $result = $con->query("select sum(field_209) from data_20 where active='1'and mod_time >= (date_sub(curdate(), interval 12 month))");
    -    while($row = $result->fetch_array(MYSQL_ASSOC)) {
    +    while($row = $result->fetch_array(MYSQLI_ASSOC)) {
                 $myArray[] = $row;
         }
         $totalStudents = $myArray[0]["sum(field_209)"];
    @@ -15,7 +15,7 @@
     
         $myArray = array();
         $result = $con->query("select sum(field_791) from data_20 where active='1'and mod_time >= (date_sub(curdate(), interval 12 month))");
    -    while($row = $result->fetch_array(MYSQL_ASSOC)) {
    +    while($row = $result->fetch_array(MYSQLI_ASSOC)) {
                 $myArray[] = $row;
         }
     
    @@ -24,7 +24,7 @@
     
         $myArray = array();
         $result = $con->query("select sum(field_475) from data_36 where active='1'and field_486<>'x' and field_1579 >= (date_sub(curdate(), interval 12 month))");
    -    while($row = $result->fetch_array(MYSQL_ASSOC)) {
    +    while($row = $result->fetch_array(MYSQLI_ASSOC)) {
                 $myArray[] = $row;
         }
     
    @@ -33,7 +33,7 @@
     
         $myArray = array();
         $result = $con->query("select sum(field_294) from data_25 where active='1'and mod_time >= (date_sub(curdate(), interval 12 month));");
    -    while($row = $result->fetch_array(MYSQL_ASSOC)) {
    +    while($row = $result->fetch_array(MYSQLI_ASSOC)) {
                 $myArray[] = $row;
         }
     
    @@ -42,7 +42,7 @@
     
         $myArray = array();
         $result = $con->query("select count(distinct document_id) from data_30 where active='1' and mod_time >= (date_sub(curdate(), interval 12 month));");
    -    while($row = $result->fetch_array(MYSQL_ASSOC)) {
    +    while($row = $result->fetch_array(MYSQLI_ASSOC)) {
                 $myArray[] = $row;
         }
     
    @@ -50,7 +50,7 @@
     
         $myArray = array();
         $result = $con->query("select count(distinct data_25.mod_user) from data_4 inner join data_25 on data_4.document_id=data_25.mod_user where data_4.active='1' and data_25.active='1' and data_25.field_292 >= (date_sub(curdate(), interval 3 month))");
    -    while($row = $result->fetch_array(MYSQL_ASSOC)) {
    +    while($row = $result->fetch_array(MYSQLI_ASSOC)) {
                 $myArray[] = $row;
         }
     
    @@ -58,7 +58,7 @@
     
         $myArray = array();
         $result = $con->query("select count(distinct data_14.document_id) from documents as doc_18 inner join data_18 as data_18 on data_18.document_id = doc_18.id and (data_18.active=1 or data_18.active is null) inner join documents as doc_14 on doc_18.parent_id = doc_14.id inner join data_14 as data_14 on data_14.document_id=doc_14.id and (data_14.active=1 or data_14.active is null);");
    -    while($row = $result->fetch_array(MYSQL_ASSOC)) {
    +    while($row = $result->fetch_array(MYSQLI_ASSOC)) {
                 $myArray[] = $row;
         }
     
    @@ -66,7 +66,7 @@
     
         $myArray = array();
         $result = $con->query("Select  data_18.field_233 from    documents as doc_14 inner join data_14 on  data_14.document_id = doc_14.id and (data_14.active = 1 or  data_14.active is null) inner join documents as doc_18 on  doc_14.id = doc_18.parent_id inner join data_18 on  data_18.document_id = doc_18.id and (data_18.active = 1 or  data_18.active is null) where   data_18.field_182 >= (date_sub(curdate(), interval 12 month));");
    -    while($row = $result->fetch_array(MYSQL_ASSOC)) {
    +    while($row = $result->fetch_array(MYSQLI_ASSOC)) {
                 $myArray[] = $row;
         }
     
    @@ -78,7 +78,7 @@
     
         $myArray = array();
         $result = $con->query("select distinct field_492_zip from data_30 where active=1 and field_492_zip <> 0;");
    -    while($row = $result->fetch_array(MYSQL_ASSOC)) {
    +    while($row = $result->fetch_array(MYSQLI_ASSOC)) {
                 $myArray[] = $row;
         }
