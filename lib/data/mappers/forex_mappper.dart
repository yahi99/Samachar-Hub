import 'package:samachar_hub/data/api/response/forex_api_response.dart';
import 'package:samachar_hub/data/models/models.dart';

class ForexMapper {
  static ForexModel fromApi(ForexApiResponse response) {
    return ForexModel(
        id: response.id,
        date: response.date,
        type: response.type,
        code: response.code,
        currency: response.currency,
        unit: response.unit,
        buying: response.buying,
        selling: response.selling,
        source: response.source,
        sourceUrl: response.sourceUrl,
        addedDate: response.addedDate);
  }
}
