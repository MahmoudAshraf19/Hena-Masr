import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:hena_masr/core/localization/locale_controller.dart';
import 'package:hena_masr/features/language/data/repositories/language_repository_impl.dart';
import 'package:hena_masr/features/language/domain/models/language_item.dart';
import 'package:hena_masr/features/language/domain/repositories/language_repository.dart';

/// State representation for the Language Selection screen.
class LanguageSelectionState {
  final LanguageItem selectedLanguage;
  final List<LanguageItem> supportedLanguages;
  final bool isSubmitting;

  const LanguageSelectionState({
    required this.selectedLanguage,
    required this.supportedLanguages,
    this.isSubmitting = false,
  });

  LanguageSelectionState copyWith({
    LanguageItem? selectedLanguage,
    List<LanguageItem>? supportedLanguages,
    bool? isSubmitting,
  }) {
    return LanguageSelectionState(
      selectedLanguage: selectedLanguage ?? this.selectedLanguage,
      supportedLanguages: supportedLanguages ?? this.supportedLanguages,
      isSubmitting: isSubmitting ?? this.isSubmitting,
    );
  }
}

/// Repository DI provider.
final languageRepositoryProvider = Provider<LanguageRepository>((ref) {
  return LanguageRepositoryImpl();
});

/// Controller managing language selection and persistence.
class LanguageSelectionController extends Notifier<LanguageSelectionState> {
  @override
  LanguageSelectionState build() {
    final repo = ref.read(languageRepositoryProvider);
    final currentLocale = ref.read(localeProvider);
    final languages = repo.getSupportedLanguages();

    // Default to currently selected locale or English
    final initial = languages.firstWhere(
      (lang) => lang.code == currentLocale.languageCode,
      orElse: () => languages.firstWhere((lang) => lang.code == 'en'),
    );

    return LanguageSelectionState(
      selectedLanguage: initial,
      supportedLanguages: languages,
    );
  }

  void selectLanguage(LanguageItem item) {
    if (state.selectedLanguage.code == item.code) return;
    state = state.copyWith(selectedLanguage: item);
  }

  Future<void> confirmSelection({VoidCallback? onSuccess}) async {
    if (state.isSubmitting) return;
    state = state.copyWith(isSubmitting: true);
    try {
      final code = state.selectedLanguage.code;
      await ref.read(languageRepositoryProvider).saveLanguagePreference(code);
      await ref.read(localeProvider.notifier).setLocale(Locale(code));
      onSuccess?.call();
    } finally {
      state = state.copyWith(isSubmitting: false);
    }
  }
}

final languageSelectionControllerProvider =
    NotifierProvider<LanguageSelectionController, LanguageSelectionState>(
  LanguageSelectionController.new,
);

