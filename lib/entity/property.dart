class Property {
  final String name;
  int _amount;

  Property(this.name, this._amount);

  int get amount => _amount;

  set amount(int value) => amount = value;

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
