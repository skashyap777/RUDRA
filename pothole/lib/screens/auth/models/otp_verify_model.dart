class OTPVerifyModel {
  String? status;
  Data? data;

  OTPVerifyModel({this.status, this.data});

  OTPVerifyModel.fromJson(Map<String, dynamic> json) {
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
  String? token;
  String? refreshToken;
  String? message;

  Data({this.token, this.refreshToken, this.message});

  Data.fromJson(Map<String, dynamic> json) {
    token = json['token'];
    refreshToken = json['refreshToken'];
    message = json['message'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['token'] = token;
    data['refreshToken'] = refreshToken;
    data['message'] = message;
    return data;
  }
}
