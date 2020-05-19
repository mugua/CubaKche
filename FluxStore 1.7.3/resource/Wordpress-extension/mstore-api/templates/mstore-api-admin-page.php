<?php include(plugin_dir_path( dirname(__FILE__) ) . 'functions/index.php'); ?>

<!doctype html>
<html <?php language_attributes(); ?> >
    <head>
        <meta charset="<?php bloginfo('charset'); ?>">
        <meta name="viewport" content="width=device-width, initial-scale=1">
        <link rel="profile" href="http://gmpg.org/xfn/11">
        <?php wp_head(); ?>
        <style>
          .mstore_input {
            width:300px;padding: .857em 1.214em;
            background-color: transparent;
            color: #818181;
            line-height: 1.286em;
            outline: 0;
            border: 0;
            -webkit-appearance: none;
            border-radius: 1.571em;
            box-sizing: border-box;
            border-width: 1px;
            border-style: solid;
            border-color: #ddd;
          }
          .mstore_button {
            position: relative;
            border: 0 none;
            border-radius: 3px;
            color: #fff;
            display: inline-block;
            font-family: 'Poppins','Open Sans', Helvetica, Arial, sans-serif;
            font-size: 12px;
            letter-spacing: 1px;
            line-height: 1.5;
            text-transform: uppercase;
            font-weight: 600;
            text-decoration: none;
            cursor: pointer;
            margin-bottom: 21px;
            margin-right: 10px;
            line-height: 1;
            padding: 12px 30px;
            background: #39c36e;
            -webkit-transition: all 0.21s ease;
            -moz-transition: all 0.21s ease;
            -o-transition: all 0.21s ease;
            transition: all 0.21s ease;
          }
        </style>
    </head>
  <body>
<div class="wrap">
	<h1>MStore API Settings</h1>

  <br>

  <div class="thanks">
  <p style="font-size: 16px;">Thank you for installing Mstore API plugins.</p>
  <?php 
   $verified = get_option("mstore_purchase_code");
   if($verified){
     ?>
      <p style="font-size: 16px;color: green">The purchase code is verified.</p>
     <?php
   }else{
     ?>
     <p style="font-size: 16px;">Please verify purchase code to use Mstore API</p>
     <?php
   }
  ?>
	</div>
</div>
<?php
$verified = get_option("mstore_purchase_code");
if(!isset($verified) || $verified == false){
?>
  <form action="" enctype="multipart/form-data" method="post" style="margin-bottom:50px">
    <?php
    if (isset($_POST['but_verify'])) {     
      $verified = verifyPurchaseCode($_POST['code']);

      if (!$verified) {
        ?>
        <p style="font-size: 16px;color: red;">The purchase code is incorrect.</p>
        <?php
      }else{
        ?>
        <p style="font-size: 16px;color: green">The purchase code is verified.</p>
      <?php
      }
    }
    ?>
    <div class="form-group" style="margin-top:10px">
        <input name="code" placeholder="Purchase Code" type="text" class="mstore_input">
    </div>
    <button type="submit" class="mstore_button" name='but_verify'>Verify</button>
  </form>
<?php
}
?>
<div class="thanks">
  <p style="font-size: 16px;">This setting help to speed up the mobile app performance,  upload the config.json from the common folder:</p>
</div>
  <form action="" enctype="multipart/form-data" method="post">
  
    <div class="form-group" style="margin-top:30px">
        <input id="fileToUpload" accept=".json" name="fileToUpload" type="file" class="form-control-file">
    </div>
    
    <p style="font-size: 14px; color: #1B9D0D; margin-top:10px">
    <?php
    if (isset($_POST['but_submit'])) {     
      wp_upload_bits($_FILES['fileToUpload']['name'], null, file_get_contents($_FILES['fileToUpload']['tmp_name'])); 
      $uploads_dir = str_replace('plugins/mstore-api/templates','uploads',dirname( __FILE__ ));
      $source      = $_FILES['fileToUpload']['tmp_name'];
      $destination = trailingslashit( $uploads_dir ) . '2000/01/config.json';
      if (!file_exists($uploads_dir."/2000/01")) {
        mkdir($uploads_dir."/2000/01", 0777, true);
      }
      move_uploaded_file($source, $destination);
      echo "The caching is active.";
    }else{
      if (file_exists($uploads_dir = str_replace('plugins/mstore-api/templates','uploads',dirname( __FILE__ ))."/2000/01/config.json")) {
        echo "The caching is active.";
      }
    }
    ?>
    </p>

    <button type="submit" class="mstore_button" name='but_submit'>Save</button>
    </form>

  </body>
</html>