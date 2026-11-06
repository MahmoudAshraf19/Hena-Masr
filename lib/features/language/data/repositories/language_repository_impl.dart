import 'package:hena_masr/features/language/data/datasources/language_local_data_source.dart';
import 'package:hena_masr/features/language/domain/models/language_item.dart';
import 'package:hena_masr/features/language/domain/repositories/language_repository.dart';

class LanguageRepositoryImpl implements LanguageRepository {
  final LanguageLocalDataSource _dataSource;

  LanguageRepositoryImpl({LanguageLocalDataSource? dataSource})
      : _dataSource = dataSource ?? LanguageLocalDataSource();

  @override
  List<LanguageItem> getSupportedLanguages() => _dataSource.getSupportedLanguages();

  @override
  LanguageItem getLanguageByCode(String code) => _dataSource.getLanguageByCode(code);

  @override
  Future<void> saveLanguagePreference(String languageCode) =>
      _dataSource.persistLanguageCode(languageCode);

  @override
  Future<String> getLanguagePreference() => _dataSource.fetchSavedLanguageCode();
}

