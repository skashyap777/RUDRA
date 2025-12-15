class CheckLocationModel {
  String? status;
  String? message;
  Data? data;

  CheckLocationModel({this.status, this.message, this.data});

  CheckLocationModel.fromJson(Map<String, dynamic> json) {
    status = json['status'];
    message = json['message'];
    data = json['data'] != null ? Data.fromJson(json['data']) : null;
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['status'] = status;
    data['message'] = message;
    if (this.data != null) {
      data['data'] = this.data!.toJson();
    }
    return data;
  }
}

class Data {
  bool? withinBoundary;
  Location? location;

  Data({this.withinBoundary, this.location});

  Data.fromJson(Map<String, dynamic> json) {
    withinBoundary = json['within_boundary'];
    location =
        json['location'] != null ? Location.fromJson(json['location']) : null;
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['within_boundary'] = withinBoundary;
    if (location != null) {
      data['location'] = location!.toJson();
    }
    return data;
  }
}

class Location {
  int? countryId;
  String? countryName;
  int? stateId;
  String? stateName;
  int? districtId;
  String? districtName;

  Location({
    this.countryId,
    this.countryName,
    this.stateId,
    this.stateName,
    this.districtId,
    this.districtName,
  });

  Location.fromJson(Map<String, dynamic> json) {
    countryId = json['country_id'];
    countryName = json['country_name'];
    stateId = json['state_id'];
    stateName = json['state_name'];
    districtId = json['district_id'];
    districtName = json['district_name'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['country_id'] = countryId;
    data['country_name'] = countryName;
    data['state_id'] = stateId;
    data['state_name'] = stateName;
    data['district_id'] = districtId;
    data['district_name'] = districtName;
    return data;
  }
}
