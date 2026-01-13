class RegionModel {
  final String name;

  RegionModel({required this.name});

  factory RegionModel.fromApi(Map<String, dynamic> data) {
    return RegionModel(
      name: data['name'],
    );
  }
}
