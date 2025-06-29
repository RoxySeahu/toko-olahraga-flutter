import 'package:flutter/foundation.dart';

class Address with ChangeNotifier {
  String id;
  String receiverName;
  String phoneNumber;
  String fullAddress;
  String city;
  String postalCode;

  Address({
    required this.id,
    required this.receiverName,
    required this.phoneNumber,
    required this.fullAddress,
    required this.city,
    required this.postalCode,
  });

  String get displayAddress {
    return '$fullAddress, $city - $postalCode\nTelp: $phoneNumber';
  }

  // Metode copyWith untuk kemudahan update jika diperlukan di masa depan
  Address copyWith({
    String? id,
    String? receiverName,
    String? phoneNumber,
    String? fullAddress,
    String? city,
    String? postalCode,
  }) {
    return Address(
      id: id ?? this.id,
      receiverName: receiverName ?? this.receiverName,
      phoneNumber: phoneNumber ?? this.phoneNumber,
      fullAddress: fullAddress ?? this.fullAddress,
      city: city ?? this.city,
      postalCode: postalCode ?? this.postalCode,
    );
  }
}