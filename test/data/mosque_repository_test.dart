import 'package:flutter_test/flutter_test.dart';
import 'package:Tebyan/core/cache/json_cache.dart';
import 'package:Tebyan/data/models/mosque/mosque_model.dart';
import 'package:Tebyan/data/repositories/mosque_repository.dart';
import '../core/cache/json_cache_test.dart' show FakeCacheStore;

void main() {
  test('streamActiveMosque emits cached mosque before remote', () async {
    final store = FakeCacheStore();
    final cache = JsonCache<MosqueModel>(
      store: store,
      cacheKey: 'mosque',
      toJson: (m) => {'id': m.id, ...m.toMap()},
      fromJson: (m) => MosqueModel.fromMap(m, m['id']?.toString() ?? ''),
    );
    await cache.save(MosqueModel.fromMap(const {'name': 'Al-Noor'}, 'mid1'));

    final repo = MosqueRepository.forTest(
      cache: cache,
      remoteStream: () => const Stream<MosqueModel?>.empty(),
    );

    final first = await repo.streamActiveMosque.first;
    expect(first!.id, 'mid1');
    expect(first.name, 'Al-Noor');
  });
}
