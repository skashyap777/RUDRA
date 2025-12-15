class GenerateOtpScreen {
  String? status;
  bool? alreadyRegistered;
  bool? otpAlreadySent;
  Data? data;

  GenerateOtpScreen({
    this.status,
    this.alreadyRegistered,
    this.otpAlreadySent,
    this.data,
  });

  GenerateOtpScreen.fromJson(Map<String, dynamic> json) {
    status = json['status'];
    alreadyRegistered = json['already_registered'];
    otpAlreadySent = json['otp_already_sent'];
    data = json['data'] != null ? Data.fromJson(json['data']) : null;
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['status'] = status;
    data['already_registered'] = alreadyRegistered;
    data['otp_already_sent'] = otpAlreadySent;
    if (this.data != null) {
      data['data'] = this.data!.toJson();
    }
    return data;
  }
}

class Data {
  User? user;
  String? message;

  Data({this.user, this.message});

  Data.fromJson(Map<String, dynamic> json) {
    user = json['user'] != null ? new User.fromJson(json['user']) : null;
    message = json['message'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    if (user != null) {
      data['user'] = user!.toJson();
    }
    data['message'] = message;
    return data;
  }
}

class User {
  int? id;
  String? mobile;

  User({this.id, this.mobile});

  User.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    mobile = json['mobile'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['id'] = id;
    data['mobile'] = mobile;
    return data;
  }
}
