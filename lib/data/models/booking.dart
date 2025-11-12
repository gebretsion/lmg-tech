class Booking {
  final String bookingId;
  final String assetName;
  final String category;
  final int numberOfProperty;
  final DateTime startDate;
  final DateTime endDate;
  final double totalPrice;
  final String status;
  final List<String> imageUrls;
  final String? paymentProofPath;
  final Map<String, dynamic> merchant;
  final Map<String, dynamic> bookedBy;

  Booking({
    required this.bookingId,
    required this.assetName,
    required this.category,
    required this.numberOfProperty,
    required this.startDate,
    required this.endDate,
    required this.totalPrice,
    required this.status,
    required this.imageUrls,
    this.paymentProofPath,
    required this.merchant,
    required this.bookedBy,
  });

  factory Booking.fromJson(Map<String, dynamic> json) => Booking(
        bookingId: json['bookingId'] ?? json['_id'],
        assetName: json['assetName'] ?? json['propertyName'] ?? '',
        category: json['category'] ?? 'N/A',
        numberOfProperty: json['numberOfProperty'] ?? 0,
        startDate: DateTime.parse(json['startDate']),
        endDate: DateTime.parse(json['endDate']),
        totalPrice: (json['totalPrice'] ?? 0).toDouble(),
        status: json['status'] ?? 'PENDING',
        imageUrls: List<String>.from(json['imageUrls'] ?? []),
        paymentProofPath: json['paymentProofPath'],
        merchant: json['merchant'] ?? {},
        bookedBy: json['bookedBy'] ?? {},
      );
}
