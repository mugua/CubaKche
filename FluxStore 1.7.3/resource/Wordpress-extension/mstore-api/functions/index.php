<?php
define("ACTIVE_API", "https://inspireui-license.now.sh/api/v1");
define("ACTIVE_TOKEN", "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJmb28iOiJiYXIiLCJpYXQiOjE1ODY5NDQ3Mjd9.-umQIC6DuTS_0J0Jj8lcUuUYGjq9OXp3cIM-KquTWX0");

function verifyPurchaseCode ($code) {
    $website = get_home_url();
    $response = wp_remote_get( ACTIVE_API."/active?code=".$code."&website=".$website."&token=".ACTIVE_TOKEN);
    $statusCode = wp_remote_retrieve_response_code($response);
    $success = $statusCode == 200;
    if($success){
        update_option("mstore_purchase_code", true);
    }else{
     $body = wp_remote_retrieve_body($response);
     var_dump($body);
    }
    return $success;
}
?>