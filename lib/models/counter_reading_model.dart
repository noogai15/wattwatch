class CounterReading {
  int counterState;
  DateTime date;

  CounterReading(this.counterState, this.date);

  Map<String, dynamic> toJson() => {
        'counterState': counterState,
        'date': date.toIso8601String(),
      };

  static CounterReading fromJson(json) => CounterReading(
        json['counterState'] as int,
        DateTime.parse(json['date'] as String),
      );
}
