class ReportModel {
  String? status;
  List<Data>? data;
  Counts? counts;
  Pagination? pagination;

  ReportModel({this.status, this.data, this.counts, this.pagination});

  ReportModel.fromJson(Map<String, dynamic> json) {
    status = json['status'];
    if (json['data'] != null) {
      data = <Data>[];
      json['data'].forEach((v) {
        data!.add(Data.fromJson(v));
      });
    }
    counts = json['counts'] != null ? Counts.fromJson(json['counts']) : null;
    pagination =
        json['pagination'] != null
            ? Pagination.fromJson(json['pagination'])
            : null;
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['status'] = status;
    if (this.data != null) {
      data['data'] = this.data!.map((v) => v.toJson()).toList();
    }
    if (counts != null) {
      data['counts'] = counts!.toJson();
    }
    if (pagination != null) {
      data['pagination'] = pagination!.toJson();
    }
    return data;
  }
}

class Data {
  int? id;
  int? caseMasterId;
  String? caseNo;
  int? userId;
  String? severity;
  String? areaDetails;
  String? landmark;
  String? remarks;
  String? status;
  String? createdAt;
  String? updatedAt;
  List<Images>? images;
  int? clientId;
  int? countryId;
  int? stateId;
  int? districtId;
  int? divisionId;
  int? subdivisionId;
  int? roadId;
  String? fromSource;
  String? pendingAt;
  String? caseCreatedAt;
  String? caseUpdatedAt;
  String? countryName;
  String? stateName;
  String? districtName;
  String? divisionName;
  String? subdivisionName;
  String? roadName;
  bool? feedBackProvided;
  List<OfficerReports>? officerReports;

  Data({
    this.id,
    this.caseMasterId,
    this.caseNo,
    this.userId,
    this.severity,
    this.areaDetails,
    this.landmark,
    this.remarks,
    this.status,
    this.createdAt,
    this.updatedAt,
    this.images,
    this.clientId,
    this.countryId,
    this.stateId,
    this.districtId,
    this.divisionId,
    this.subdivisionId,
    this.roadId,
    this.fromSource,
    this.pendingAt,
    this.caseCreatedAt,
    this.caseUpdatedAt,
    this.countryName,
    this.stateName,
    this.districtName,
    this.divisionName,
    this.subdivisionName,
    this.roadName,
    this.feedBackProvided,
    this.officerReports,
  });

  Data.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    caseMasterId = json['case_master_id'];
    caseNo = json['case_no'];
    userId = json['user_id'];
    severity = json['severity'];
    areaDetails = json['area_details'];
    landmark = json['landmark'];
    remarks = json['remarks'];
    status = json['status'];
    createdAt = json['created_at'];
    updatedAt = json['updated_at'];
    if (json['images'] != null) {
      images = <Images>[];
      json['images'].forEach((v) {
        images!.add(Images.fromJson(v));
      });
    }
    clientId = json['client_id'];
    countryId = json['country_id'];
    stateId = json['state_id'];
    districtId = json['district_id'];
    divisionId = json['division_id'];
    subdivisionId = json['subdivision_id'];
    roadId = json['road_id'];
    fromSource = json['from_source'];
    pendingAt = json['pending_at'];
    caseCreatedAt = json['case_created_at'];
    caseUpdatedAt = json['case_updated_at'];
    countryName = json['country_name'];
    stateName = json['state_name'];
    districtName = json['district_name'];
    divisionName = json['division_name'];
    subdivisionName = json['subdivision_name'];
    roadName = json['road_name'];
    feedBackProvided = json['feed_back_provided'];
    if (json['officer_reports'] != null) {
      officerReports = <OfficerReports>[];
      json['officer_reports'].forEach((v) {
        officerReports!.add(OfficerReports.fromJson(v));
      });
    }
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['id'] = id;
    data['case_master_id'] = caseMasterId;
    data['case_no'] = caseNo;
    data['user_id'] = userId;
    data['severity'] = severity;
    data['area_details'] = areaDetails;
    data['landmark'] = landmark;
    data['remarks'] = remarks;
    data['status'] = status;
    data['created_at'] = createdAt;
    data['updated_at'] = updatedAt;
    if (images != null) {
      data['images'] = images!.map((v) => v.toJson()).toList();
    }
    data['client_id'] = clientId;
    data['country_id'] = countryId;
    data['state_id'] = stateId;
    data['district_id'] = districtId;
    data['division_id'] = divisionId;
    data['subdivision_id'] = subdivisionId;
    data['road_id'] = roadId;
    data['from_source'] = fromSource;
    data['pending_at'] = pendingAt;
    data['case_created_at'] = caseCreatedAt;
    data['case_updated_at'] = caseUpdatedAt;
    data['country_name'] = countryName;
    data['state_name'] = stateName;
    data['district_name'] = districtName;
    data['division_name'] = divisionName;
    data['subdivision_name'] = subdivisionName;
    data['road_name'] = roadName;
    data['feed_back_provided'] = feedBackProvided;
    if (officerReports != null) {
      data['officer_reports'] = officerReports!.map((v) => v.toJson()).toList();
    }
    return data;
  }
}

class Images {
  String? imageUrl;
  double? latitude;
  double? longitude;

  Images({this.imageUrl, this.latitude, this.longitude});

  Images.fromJson(Map<String, dynamic> json) {
    imageUrl = json['image_url'];
    latitude = json['latitude'];
    longitude = json['longitude'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['image_url'] = imageUrl;
    data['latitude'] = latitude;
    data['longitude'] = longitude;
    return data;
  }
}

class OfficerReports {
  int? id;
  int? officerId;
  String? officerType;
  int? totalPotholes;
  String? inspectionDate;
  String? fieldNote;
  String? materialConsumptionKg;
  String? status;
  String? reportType;
  String? createdAt;
  String? updatedAt;
  List<PotholesData>? potholesData;
  List<AfterFixPhotos>? afterFixPhotos;

  OfficerReports({
    this.id,
    this.officerId,
    this.officerType,
    this.totalPotholes,
    this.inspectionDate,
    this.fieldNote,
    this.materialConsumptionKg,
    this.status,
    this.reportType,
    this.createdAt,
    this.updatedAt,
    this.potholesData,
    this.afterFixPhotos,
  });

  OfficerReports.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    officerId = json['officer_id'];
    officerType = json['officer_type'];
    totalPotholes = json['total_potholes'];
    inspectionDate = json['inspection_date'];
    fieldNote = json['field_note'];
    materialConsumptionKg = json['material_consumption_kg'].toString();
    status = json['status'];
    reportType = json['report_type'];
    createdAt = json['created_at'];
    updatedAt = json['updated_at'];
    if (json['potholes_data'] != null) {
      potholesData = <PotholesData>[];
      json['potholes_data'].forEach((v) {
        potholesData!.add(PotholesData.fromJson(v));
      });
    }
    if (json['after_fix_photos'] != null) {
      afterFixPhotos = <AfterFixPhotos>[];
      json['after_fix_photos'].forEach((v) {
        afterFixPhotos!.add(AfterFixPhotos.fromJson(v));
      });
    }
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['id'] = id;
    data['officer_id'] = officerId;
    data['officer_type'] = officerType;
    data['total_potholes'] = totalPotholes;
    data['inspection_date'] = inspectionDate;
    data['field_note'] = fieldNote;
    data['material_consumption_kg'] = materialConsumptionKg;
    data['status'] = status;
    data['report_type'] = reportType;
    data['created_at'] = createdAt;
    data['updated_at'] = updatedAt;
    if (potholesData != null) {
      data['potholes_data'] = potholesData!.map((v) => v.toJson()).toList();
    }
    if (afterFixPhotos != null) {
      data['after_fix_photos'] =
          afterFixPhotos!.map((v) => v.toJson()).toList();
    }
    return data;
  }
}

class PotholesData {
  int? id;
  int? beforeDiggingLength;
  int? beforeDiggingWidth;
  int? beforeDiggingDepth;
  int? afterDiggingLength;
  int? afterDiggingWidth;
  int? afterDiggingDepth;
  String? createdAt;
  String? updatedAt;
  List<Photos>? photos;

  PotholesData({
    this.id,
    this.beforeDiggingLength,
    this.beforeDiggingWidth,
    this.beforeDiggingDepth,
    this.afterDiggingLength,
    this.afterDiggingWidth,
    this.afterDiggingDepth,
    this.createdAt,
    this.updatedAt,
    this.photos,
  });

  PotholesData.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    beforeDiggingLength = json['before_digging_length'];
    beforeDiggingWidth = json['before_digging_width'];
    beforeDiggingDepth = json['before_digging_depth'];
    afterDiggingLength = json['after_digging_length'];
    afterDiggingWidth = json['after_digging_width'];
    afterDiggingDepth = json['after_digging_depth'];
    createdAt = json['created_at'];
    updatedAt = json['updated_at'];
    if (json['photos'] != null) {
      photos = <Photos>[];
      json['photos'].forEach((v) {
        photos!.add(Photos.fromJson(v));
      });
    }
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['id'] = id;
    data['before_digging_length'] = beforeDiggingLength;
    data['before_digging_width'] = beforeDiggingWidth;
    data['before_digging_depth'] = beforeDiggingDepth;
    data['after_digging_length'] = afterDiggingLength;
    data['after_digging_width'] = afterDiggingWidth;
    data['after_digging_depth'] = afterDiggingDepth;
    data['created_at'] = createdAt;
    data['updated_at'] = updatedAt;
    if (photos != null) {
      data['photos'] = photos!.map((v) => v.toJson()).toList();
    }
    return data;
  }
}

class Photos {
  int? id;
  String? photoUrl;
  String? photoType;
  double? latitude;
  double? longitude;
  String? createdAt;
  String? updatedAt;

  Photos({
    this.id,
    this.photoUrl,
    this.photoType,
    this.latitude,
    this.longitude,
    this.createdAt,
    this.updatedAt,
  });

  Photos.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    photoUrl = json['photo_url'];
    photoType = json['photo_type'];
    latitude = json['latitude'];
    longitude = json['longitude'];
    createdAt = json['created_at'];
    updatedAt = json['updated_at'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['id'] = id;
    data['photo_url'] = photoUrl;
    data['photo_type'] = photoType;
    data['latitude'] = latitude;
    data['longitude'] = longitude;
    data['created_at'] = createdAt;
    data['updated_at'] = updatedAt;
    return data;
  }
}

class AfterFixPhotos {
  int? id;
  int? officersReportId;
  String? photoUrl;
  double? latitude;
  double? longitude;
  String? createdAt;
  String? updatedAt;

  AfterFixPhotos({
    this.id,
    this.officersReportId,
    this.photoUrl,
    this.latitude,
    this.longitude,
    this.createdAt,
    this.updatedAt,
  });

  AfterFixPhotos.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    officersReportId = json['officers_report_id'];
    photoUrl = json['photo_url'];
    latitude = json['latitude'];
    longitude = json['longitude'];
    createdAt = json['created_at'];
    updatedAt = json['updated_at'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['id'] = id;
    data['officers_report_id'] = officersReportId;
    data['photo_url'] = photoUrl;
    data['latitude'] = latitude;
    data['longitude'] = longitude;
    data['created_at'] = createdAt;
    data['updated_at'] = updatedAt;
    return data;
  }
}

class Counts {
  int? all;
  int? submitted;
  int? inProgress;
  int? completed;
  int? rejected;

  Counts({
    this.all,
    this.submitted,
    this.inProgress,
    this.completed,
    this.rejected,
  });

  Counts.fromJson(Map<String, dynamic> json) {
    all = json['all'];
    submitted = json['submitted'];
    inProgress = json['in_progress'];
    completed = json['completed'];
    rejected = json['rejected'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['all'] = all;
    data['submitted'] = submitted;
    data['in_progress'] = inProgress;
    data['completed'] = completed;
    data['rejected'] = rejected;
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
