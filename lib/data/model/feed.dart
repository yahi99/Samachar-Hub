import 'package:json_annotation/json_annotation.dart';
import 'package:samachar_hub/data/model/sources.dart';

part 'feed.g.dart';

class Feed {
  final String id;
  final FeedSource source;
  final FeedCategory category;
  final String author;
  final String title;
  final String description;
  final String link;
  final String image;
  @JsonKey(name: "pub_date")
  final String publishedAt;
  final String content;
  final String uuid;
  @JsonKey(required: false)
  final List<Feed> related;

  Feed(
      this.id,
      this.source,
      this.category,
      this.author,
      this.title,
      this.description,
      this.link,
      this.image,
      this.publishedAt,
      this.content,
      this.related, 
      this.uuid);

  String getAuthor() {
    if (author == null || author.isEmpty) return source.name;
    return author;
  }

  factory Feed.fromJson(Map<String, dynamic> json, Sources sources) {
    return Feed(
        json['id'] as String,
        json['source'] == null
            ? null
            : FeedSource.fromJson(json['source'] as Map<String, dynamic>),
        json['category'] == null
            ? null
            : FeedCategory.fromJson(json['category'] as Map<String, dynamic>),
        json['author'] as String,
        json['title'] as String,
        json['description'] as String,
        json['link'] as String,
        json['image'] as String,
        json['pub_date'] as String,
        json['content'] as String,
        (json['related'] as List)?.map((e) {
          if (e == null) return null;
          var feed = e as Map<String, dynamic>;
          if (json.containsKey('source')) {
            try {
              var source = sources.sources
                  .where((source) =>
                      source.code != null &&
                      source.code == (feed['source'] as String))
                  .first;
              feed.update('source', (update) => source.toJson());
            } catch (e) {}
          }
          if (feed.containsKey('category')) {
            try {
              var category = sources.categories
                  .where((category) =>
                      category.code != null &&
                      category.code == feed['category'] as String)
                  .first;
              feed.update('category', (update) => category.toJson());
            } catch (e) {}
          }
          return Feed.fromJson(e as Map<String, dynamic>, sources);
        })?.toList(),
        json['uuid'] as String,);
  }
  Map<String, dynamic> toJson() => <String, dynamic>{
        'id': this.id,
        'source': this.source,
        'category': this.category,
        'author': this.author,
        'title': this.title,
        'description': this.description,
        'link': this.link,
        'image': this.image,
        'pub_date': this.publishedAt,
        'content': this.content,
        (this.related != null && this.related.isNotEmpty)
            ? 'related'
            : this.related: [],
      };
}

@JsonSerializable()
class FeedSource {
  final int id;
  final String name;
  final String code;
  final String icon;
  final int priority;
  final String favicon;

  FeedSource(
      this.id, this.name, this.code, this.icon, this.priority, this.favicon);

  factory FeedSource.fromJson(Map<String, dynamic> json) =>
      _$FeedSourceFromJson(json);
  Map<String, dynamic> toJson() => _$FeedSourceToJson(this);
}

@JsonSerializable()
class FeedCategory {
  final int id;
  final String name;
  @JsonKey(name: "name_np")
  final String nameNp;
  final String code;
  final String icon;
  final int priority;
  final String enable;

  FeedCategory(this.id, this.name, this.nameNp, this.code, this.icon,
      this.priority, this.enable);

  factory FeedCategory.fromJson(Map<String, dynamic> json) =>
      _$FeedCategoryFromJson(json);
  Map<String, dynamic> toJson() => _$FeedCategoryToJson(this);
}