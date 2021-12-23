class Property {
  final String id;
  final String name;
  int amount;

  Property(this.id, this.name, this.amount);

  Property.fromIdAndJson(String id, Map<String, Object?> json)
      : this(
          id,
          json['name'] as String,
          json['amount'] as int,
        );

  Map<String, Object?> toJson() => {
    'name': name,
    'amount': amount,
  };

  @override
  String toString() => '''id...$id
name...$name
amount...$amount''';
}
