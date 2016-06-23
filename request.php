<?php 
    echo file_get_contents("http://localhost:8001/".$_SERVER['REQUEST_URI']."&ip=".$_SERVER['REMOTE_ADDR']);
?>




