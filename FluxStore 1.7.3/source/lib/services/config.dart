class Config {
  String type;
  String url;
  String blog;
  String consumerKey;
  String consumerSecret;
  String forgetPassword;
  String accessToken;
  bool isCacheImage;

  static final Config _instance = Config._internal();
  
  factory Config() => _instance;

  Config._internal();

  void setConfig(config) {
    type = config['type'];
    url = config['url'];
    blog = config['blog'];
    consumerKey = config['consumerKey'];
    consumerSecret = config['consumerSecret'];
    forgetPassword = config['forgetPassword'];
    accessToken = config['accessToken'];
    isCacheImage = config['isCacheImage'];
  }
}