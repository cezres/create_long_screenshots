import 'package:create_long_screenshots/main.dart';
import 'package:hydrated_bloc/hydrated_bloc.dart';
import 'package:sembast/sembast.dart';

class WebHydratedStorage extends Storage {
  final store = StoreRef<String, dynamic>('hydrated_bloc_storage');

  @override
  Future<void> clear() {
    return kDatabase.transaction((transaction) async {
      await store.delete(transaction);
    });
  }

  @override
  Future<void> close() async {
    //
  }

  @override
  Future<void> delete(String key) {
    return kDatabase.transaction((transaction) async {
      final record = store.record(key);
      await record.delete(transaction);
    });
  }

  @override
  read(String key) {
    return kDatabase.transaction((transaction) async {
      final record = store.record(key);
      final result = await record.get(transaction);
      return result;
    });
  }

  @override
  Future<void> write(String key, value) {
    return kDatabase.transaction((transaction) async {
      final record = store.record(key);
      await record.put(transaction, value);
    });
  }
}
