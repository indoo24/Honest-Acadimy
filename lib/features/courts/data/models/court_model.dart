import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import 'package:honset_app/features/courts/domain/entities/court.dart';

class CourtModel extends Court {
  const CourtModel({
    required super.id,
    required super.name,
    required super.isActive,
    required super.pricePerHour,
    super.imageUrl,
    super.description,
  });

  factory CourtModel.fromFirestore(DocumentSnapshot<Map<String, dynamic>> doc) {
    final data = doc.data();
    final docId = doc.id;

    debugPrint('═══════════════════════════════════════════════');
    debugPrint('[📦 COURT PARSE] Document: "$docId"');
    debugPrint('═══════════════════════════════════════════════');

    if (data == null) {
      debugPrint('[📦 COURT PARSE] ❌ FATAL: Document "$docId" data is NULL!');
      debugPrint('[📦 COURT PARSE] ❌ This means the document reference exists');
      debugPrint('[📦 COURT PARSE] ❌ but has no stored fields (corrupted or deleted).');
      throw StateError('Court document "$docId" has no data');
    }

    debugPrint('[📦 COURT PARSE] Raw data map keys: ${data.keys.toList()}');
    debugPrint('[📦 COURT PARSE] Raw data entries:');
    for (final entry in data.entries) {
      debugPrint('[📦 COURT PARSE]   ${entry.key} => ${entry.value} (type: ${entry.value.runtimeType})');
    }

    // ── name ──
    final rawName = data['name'];
    String name;
    if (rawName == null) {
      debugPrint('[📦 COURT PARSE] ⚠️  "name" field is MISSING (null). Defaulting to "Squash Court".');
      name = 'Squash Court';
    } else if (rawName is! String) {
      debugPrint('[📦 COURT PARSE] ❌ "name" has WRONG TYPE: ${rawName.runtimeType} = $rawName (expected String). Defaulting.');
      name = rawName.toString();
    } else {
      name = rawName;
    }

    // ── isActive ──
    final rawIsActive = data['isActive'];
    bool isActive;
    if (rawIsActive == null) {
      debugPrint('[📦 COURT PARSE] ⚠️  "isActive" is MISSING. Defaulting to true.');
      isActive = true;
    } else if (rawIsActive is! bool) {
      debugPrint('[📦 COURT PARSE] ❌ "isActive" has WRONG TYPE: ${rawIsActive.runtimeType} = $rawIsActive (expected bool). Defaulting to true.');
      isActive = rawIsActive == true || rawIsActive == 1 || rawIsActive == 'true';
    } else {
      isActive = rawIsActive;
    }

    // ── pricePerHour / hourlyRate ──
    final rawPricePerHour = data['pricePerHour'];
    final rawHourlyRate = data['hourlyRate'];
    double pricePerHour;

    if (rawPricePerHour != null) {
      if (rawPricePerHour is num) {
        pricePerHour = rawPricePerHour.toDouble();
        debugPrint('[📦 COURT PARSE] ✅ "pricePerHour" = $pricePerHour (num → double)');
      } else {
        debugPrint('[📦 COURT PARSE] ❌ "pricePerHour" has WRONG TYPE: ${rawPricePerHour.runtimeType} = $rawPricePerHour (expected num).');
        pricePerHour = double.tryParse(rawPricePerHour.toString()) ?? 0;
      }
    } else if (rawHourlyRate != null) {
      if (rawHourlyRate is num) {
        pricePerHour = rawHourlyRate.toDouble();
        debugPrint('[📦 COURT PARSE] ✅ "pricePerHour" from legacy "hourlyRate" = $pricePerHour');
      } else {
        debugPrint('[📦 COURT PARSE] ❌ legacy "hourlyRate" has WRONG TYPE: ${rawHourlyRate.runtimeType} = $rawHourlyRate');
        pricePerHour = double.tryParse(rawHourlyRate.toString()) ?? 0;
      }
    } else {
      debugPrint('[📦 COURT PARSE] ❌ BOTH "pricePerHour" AND "hourlyRate" are MISSING. Defaulting to 0.');
      pricePerHour = 0;
    }

    // ── description (optional) ──
    final rawDescription = data['description'];
    String? description;
    if (rawDescription != null && rawDescription is! String) {
      debugPrint('[📦 COURT PARSE] ⚠️  "description" is not a String: ${rawDescription.runtimeType} = $rawDescription. Converting.');
      description = rawDescription.toString();
    } else {
      description = rawDescription as String?;
    }

    // ── imageUrl (optional) ──
    final rawImageUrl = data['imageUrl'];
    String? imageUrl;
    if (rawImageUrl != null && rawImageUrl is! String) {
      debugPrint('[📦 COURT PARSE] ⚠️  "imageUrl" is not a String: ${rawImageUrl.runtimeType} = $rawImageUrl. Converting.');
      imageUrl = rawImageUrl.toString();
    } else {
      imageUrl = rawImageUrl as String?;
    }

    final result = CourtModel(
      id: docId,
      name: name,
      isActive: isActive,
      pricePerHour: pricePerHour,
      description: description,
      imageUrl: imageUrl,
    );

    debugPrint('[📦 COURT PARSE] ✅ FINAL: id="$docId" name="$name" active=$isActive price=\$$pricePerHour');
    debugPrint('═══════════════════════════════════════════════');

    return result;
  }

  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'description': description,
      'imageUrl': imageUrl,
      'isActive': isActive,
      'pricePerHour': pricePerHour,
      'updatedAt': FieldValue.serverTimestamp(),
    };
  }
}