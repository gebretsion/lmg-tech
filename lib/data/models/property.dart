class BookingInfo {
  final String startDate;
  final String endDate;
  final int numberOfProperty;
  final String status;

  BookingInfo({required this.startDate, required this.endDate, required this.numberOfProperty, required this.status});

  factory BookingInfo.fromJson(Map<String, dynamic> json) => BookingInfo(
        startDate: json['startDate'] ?? '',
        endDate: json['endDate'] ?? '',
        numberOfProperty: json['numberOfProperty'] ?? 0,
        status: json['status'] ?? 'N/A',
      );
}

class Property {
  final String id;
  final String name;
  final String description;
  final String category;
  final String priceUnit;
  final Map<String, dynamic> rentalPrice;
  final int numberOfProperty;
  final String status;
  final List<String> imageUrls;
  final Map<String, dynamic> merchant;
  final List<BookingInfo> bookings;

  Property({
    required this.id,
    required this.name,
    required this.description,
    required this.category,
    required this.priceUnit,
    required this.rentalPrice,
    required this.numberOfProperty,
    required this.status,
    required this.imageUrls,
    required this.merchant,
    required this.bookings,
  });

  factory Property.fromJson(Map<String, dynamic> json) => Property(
        id: json['_id'] ?? '',
        name: json['name'],
        description: json['description'],
        category: json['category'],
        priceUnit: json['priceUnit'] ?? 'N/A',
        rentalPrice: json['rentalPrice'],
        numberOfProperty: json['numberOfProperty'],
        status: json['status'],
        imageUrls: List<String>.from(json['imageUrls'] ?? []),
        merchant: json['merchant'] ?? {},
        bookings: (json['bookings'] as List? ?? [])
            .map((b) => BookingInfo.fromJson(b))
            .toList(),
      );
}
