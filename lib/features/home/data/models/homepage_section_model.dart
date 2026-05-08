/// Homepage section model
class HomepageSectionModel {
  final int id;
  final String? title;
  final String image;
  final String? link;
  final String? routeTo;
  final Map<String, dynamic>? filters;
  final int position;

  const HomepageSectionModel({
    required this.id,
    this.title,
    required this.image,
    this.link,
    this.routeTo,
    this.filters,
    required this.position,
  });

  factory HomepageSectionModel.fromJson(Map<String, dynamic> json) {
    return HomepageSectionModel(
      id: json['id'] as int? ?? 0,
      title: json['title'] as String?,
      image: json['image'] as String? ?? '',
      link: json['link'] as String?,
      routeTo: json['routeTo'] as String?,
      filters: json['filters'] as Map<String, dynamic>?,
      position: json['position'] as int? ?? 0,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      if (title != null) 'title': title,
      'image': image,
      if (link != null) 'link': link,
      if (routeTo != null) 'routeTo': routeTo,
      if (filters != null) 'filters': filters,
      'position': position,
    };
  }
}
