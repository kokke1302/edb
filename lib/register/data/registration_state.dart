import 'package:edb/db/app_database.dart';
import 'package:edb/share/data/vocab_entry.dart';

class RegistrationState {
  final int id;
  final VocabEntry vocab;

  const RegistrationState({required this.id, required this.vocab});

  // 状態を変更した新しいインスタンスを返すメソッド
  RegistrationState copyWith({VocabEntry? vocab, Based? based}) {
    return RegistrationState(id: id, vocab: vocab ?? this.vocab);
  }

  factory RegistrationState.fromVocabularies({required Vocabulary vocabulary}) {
    return RegistrationState(
      id: vocabulary.id,
      vocab: VocabEntry.fromVocabularies(vocabulary: vocabulary),
    );
  }
}
