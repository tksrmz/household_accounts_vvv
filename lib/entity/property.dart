class Property {
  final String name;
  int amount;

  Property(this.name, this.amount);

  Property.fromJson(Map<String, Object?> json)
      : this(
          json['name'] as String,
          json['amount'] as int,
        );

  Map<String, Object?> toJson() => {
        'name': name,
        'amount': amount,
      };

  @override
  String toString() => '''name...$name
amount...$amount''';
}
