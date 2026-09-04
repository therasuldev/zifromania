class RemoteMessageData {
  final String? title;
  final String? body;
  final String? route;
  final String? value;

  RemoteMessageData({
    this.title,
    this.body,
    this.route,
    this.value,
  });

  factory RemoteMessageData.fromJson(Map<String, dynamic> json) => RemoteMessageData(
        title: json['title'] as String?,
        body: json['body'] as String?,
        route: json['route'] as String?,
        value: json['value'] as String?,
      );
}
