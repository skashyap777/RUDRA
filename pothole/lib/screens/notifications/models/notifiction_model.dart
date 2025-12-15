class NotificationModel {
  String? status;
  String? message;
  List<Data>? data;
  Pagination? pagination;

  NotificationModel({this.status, this.message, this.data, this.pagination});

  NotificationModel.fromJson(Map<String, dynamic> json) {
    status = json['status'];
    message = json['message'];
    if (json['data'] != null) {
      data = <Data>[];
      json['data'].forEach((v) {
        data!.add(Data.fromJson(v));
      });
    }
    pagination =
        json['pagination'] != null
            ? Pagination.fromJson(json['pagination'])
            : null;
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['status'] = status;
    data['message'] = message;
    if (this.data != null) {
      data['data'] = this.data!.map((v) => v.toJson()).toList();
    }
    if (pagination != null) {
      data['pagination'] = pagination!.toJson();
    }
    return data;
  }
}

class Data {
  int? id;
  int? userId;
  int? caseId;
  String? caseNo;
  String? type;
  String? title;
  String? message;
  bool? feedBackProvided;
  String? createdAt;
  String? updatedAt;
  String? caseStatus;
  String? casePendingAt;

  Data({
    this.id,
    this.userId,
    this.caseId,
    this.caseNo,
    this.type,
    this.title,
    this.message,
    this.feedBackProvided,
    this.createdAt,
    this.updatedAt,
    this.caseStatus,
    this.casePendingAt,
  });

  Data.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    userId = json['user_id'];
    caseId = json['case_id'];
    caseNo = json['case_no'];
    type = json['type'];
    title = json['title'];
    message = json['message'];
    feedBackProvided = json['feed_back_provided'];
    createdAt = json['created_at'];
    updatedAt = json['updated_at'];
    caseStatus = json['case_status'];
    casePendingAt = json['case_pending_at'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['id'] = id;
    data['user_id'] = userId;
    data['case_id'] = caseId;
    data['case_no'] = caseNo;
    data['type'] = type;
    data['title'] = title;
    data['message'] = message;
    data['feed_back_provided'] = feedBackProvided;
    data['created_at'] = createdAt;
    data['updated_at'] = updatedAt;
    data['case_status'] = caseStatus;
    data['case_pending_at'] = casePendingAt;
    return data;
  }
}

class Pagination {
  int? total;
  int? page;
  int? limit;
  int? totalPages;

  Pagination({this.total, this.page, this.limit, this.totalPages});

  Pagination.fromJson(Map<String, dynamic> json) {
    total = json['total'];
    page = json['page'];
    limit = json['limit'];
    totalPages = json['totalPages'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['total'] = total;
    data['page'] = page;
    data['limit'] = limit;
    data['totalPages'] = totalPages;
    return data;
  }
}
