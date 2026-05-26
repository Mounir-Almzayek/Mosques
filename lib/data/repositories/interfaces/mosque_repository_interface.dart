import '../../models/mosque/mosque_model.dart';
import '../../../core/enums/app_language.dart';

abstract class IMosqueRepository {
  Future<MosqueModel?> getActiveMosque();
  Future<MosqueModel?> fetchActiveMosqueFromServer();
  Future<void> updateMosque(MosqueModel mosque);
  Future<void> updateDesignSettings(MosqueModel mosque);
  Future<void> updateLanguageCode(AppLanguage language);
  Future<void> updateIqamaSettings(MosqueModel mosque);
  Future<void> updateMosqueTextList(MosqueModel mosque, MosqueTextListKind kind);
  Future<void> updateAnnouncements(MosqueModel mosque);
  Future<void> updateActiveAlerts(MosqueModel mosque);
  Future<void> updateLastSeen();
  Stream<MosqueModel?> get streamActiveMosque;
}
