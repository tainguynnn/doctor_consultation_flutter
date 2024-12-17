// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'transaction_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

TransactionModel _$TransactionModelFromJson(Map<String, dynamic> json) {
  return TransactionModel()
    ..docId = json['doc_id'] as String?
    ..doctorProfile = json['doctor_profile'] == null
        ? null
        : Doctor.fromJson(json['doctor_profile'] as Map<String, dynamic>)
    ..consultationSchedule = json['consultation_schedule'] == null
        ? null
        : ConsultationSchedule.fromJson(
            json['consultation_schedule'] as Map<String, dynamic>)
    ..status = json['status'] as String?
    ..paymentProof = json['payment_proof'] as String?
    ..createdAt = TransactionModel._fromJson(json['created_at'] as Timestamp)
    ..createdBy = json['created_by'] == null
        ? null
        : UserModel.fromJson(json['created_by'] as Map<String, dynamic>);
}

Map<String, dynamic> _$TransactionModelToJson(TransactionModel instance) =>
    <String, dynamic>{
      'doc_id': instance.docId,
      'doctor_profile': instance.doctorProfile,
      'consultation_schedule': instance.consultationSchedule,
      'status': instance.status,
      'payment_proof': instance.paymentProof,
      'created_at': TransactionModel._toJson(instance.createdAt),
      'created_by': instance.createdBy,
    };
