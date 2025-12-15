class ProfileModel {
  String? status;
  Data? data;

  ProfileModel({this.status, this.data});

  ProfileModel.fromJson(Map<String, dynamic> json) {
    status = json['status'];
    data = json['data'] != null ? Data.fromJson(json['data']) : null;
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['status'] = status;
    if (this.data != null) {
      data['data'] = this.data!.toJson();
    }
    return data;
  }
}

class Data {
  Profile? profile;

  Data({this.profile});

  Data.fromJson(Map<String, dynamic> json) {
    profile =
        json['profile'] != null ? Profile.fromJson(json['profile']) : null;
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    if (profile != null) {
      data['profile'] = profile!.toJson();
    }
    return data;
  }
}

class Profile {
  int? id;
  Null? countryId;
  Null? stateId;
  Null? districtId;
  String? userType;
  String? mobile;
  String? name;
  String? profilePhotoLink;
  String? address;
  String? username;
  String? password;
  String? designation;
  bool? rememberMe;
  bool? mobileVerified;
  bool? firstTimeLogin;
  String? dateEntry;
  String? dateUpdate;
  bool? isActive;
  bool? isCentralAdmin;
  String? lastLogin;

  Profile({
    this.id,
    this.countryId,
    this.stateId,
    this.districtId,
    this.userType,
    this.mobile,
    this.name,
    this.profilePhotoLink,
    this.address,
    this.username,
    this.password,
    this.designation,
    this.rememberMe,
    this.mobileVerified,
    this.firstTimeLogin,
    this.dateEntry,
    this.dateUpdate,
    this.isActive,
    this.isCentralAdmin,
    this.lastLogin,
  });

  Profile.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    countryId = json['country_id'];
    stateId = json['state_id'];
    districtId = json['district_id'];
    userType = json['user_type'];
    mobile = json['mobile'];
    name = json['name'];
    profilePhotoLink = json['profile_photo_link'];
    address = json['address'];
    username = json['username'];
    password = json['password'];
    designation = json['designation'];
    rememberMe = json['remember_me'];
    mobileVerified = json['mobile_verified'];
    firstTimeLogin = json['first_time_login'];
    dateEntry = json['date_entry'];
    dateUpdate = json['date_update'];
    isActive = json['is_active'];
    isCentralAdmin = json['is_central_admin'];
    lastLogin = json['last_login'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['id'] = id;
    data['country_id'] = countryId;
    data['state_id'] = stateId;
    data['district_id'] = districtId;
    data['user_type'] = userType;
    data['mobile'] = mobile;
    data['name'] = name;
    data['profile_photo_link'] = profilePhotoLink;
    data['address'] = address;
    data['username'] = username;
    data['password'] = password;
    data['designation'] = designation;
    data['remember_me'] = rememberMe;
    data['mobile_verified'] = mobileVerified;
    data['first_time_login'] = firstTimeLogin;
    data['date_entry'] = dateEntry;
    data['date_update'] = dateUpdate;
    data['is_active'] = isActive;
    data['is_central_admin'] = isCentralAdmin;
    data['last_login'] = lastLogin;
    return data;
  }
}
