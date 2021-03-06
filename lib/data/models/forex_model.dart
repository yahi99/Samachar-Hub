import 'package:flutter/widgets.dart';

class ForexModel {
  final int id;
  final String date;
  final String type;
  final String code;
  final String currency;
  final int unit;
  final int buying;
  final double selling;
  final String source;
  final String sourceUrl;
  final String addedDate;

  ForexModel(
      {@required this.id,
      @required this.date,
      @required this.type,
      @required this.code,
      @required this.currency,
      @required this.unit,
      @required this.buying,
      @required this.selling,
      @required this.source,
      @required this.sourceUrl,
      @required this.addedDate});
}
