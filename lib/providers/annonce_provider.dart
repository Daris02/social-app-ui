import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/annonce.dart';
import '../services/api_service.dart';

final annoncesProvider = FutureProvider<List<Annonce>>((ref) async {
  return await ApiService.getAnnonces();
});
