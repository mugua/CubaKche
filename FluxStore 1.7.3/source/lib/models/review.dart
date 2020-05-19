class Review {
  int id;
  int productId;
  String name;
  String email;
  String review;
  double rating;
  DateTime createdAt;

  Review.fromJson(Map<String, dynamic> parsedJson) {
    id = parsedJson["id"];
    name = parsedJson["name"];
    email = parsedJson["email"];
    review = parsedJson["review"];
    rating = double.parse(parsedJson["rating"].toString());
    createdAt = parsedJson["date_created"] != null ? DateTime.parse(parsedJson["date_created"]) : DateTime.now();
  }

  Review.fromOpencartJson(Map<String, dynamic> parsedJson) {
    id = parsedJson["review_id"] != null ? int.parse(parsedJson["review_id"]) : 0;
    name = parsedJson["author"];
    email = parsedJson["author"];
    review = parsedJson["text"];
    rating = parsedJson["rating"] != null ? double.parse(parsedJson["rating"]) : 0.0;
    createdAt = parsedJson["date_added"] != null ? DateTime.parse(parsedJson["date_added"]) : DateTime.now();
  }

  Review.fromMagentoJson(Map<String, dynamic> parsedJson) {
    id = parsedJson["id"];
    name = parsedJson["name"];
    email = parsedJson["email"];
    review = parsedJson["review"];
    rating = parsedJson["rating"];
    createdAt = parsedJson["date_created"] != null ? DateTime.parse(parsedJson["date_created"]) : DateTime.now();
  }

  @override
  String toString() => 'Category { id: $id  name: $name}';
}
