import 'package:create_long_screenshots/main.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:sembast/sembast.dart';

final _store = StoreRef<String, dynamic>.main();

abstract class CachedCubit<State> extends Cubit<State> {
  CachedCubit(super.initialState);

  String get cacheKey => runtimeType.toString();

  Map<String, dynamic>? toJson(State state);

  State? fromJson(Map<String, dynamic> json);

  Future<void> load() async {
    await kDatabase
        .transaction((transaction) => loadInTransaction(transaction));
  }

  Future<void> loadInTransaction(Transaction transaction) async {
    final record = _store.record(cacheKey);
    final json = await record.get(transaction);
    if (json is Map<String, dynamic>) {
      final state = fromJson(json);
      if (state != null) {
        emit(state);
      }
    }
  }

  Future<void> save() async {
    await kDatabase.transaction((transaction) async {
      final record = _store.record(cacheKey);
      await record.put(transaction, toJson(state));
    });
  }

  Future<void> delete() async {
    await kDatabase
        .transaction((transaction) => deleteInTransaction(transaction));
  }

  Future<void> deleteInTransaction(Transaction transaction) async {
    final record = _store.record(cacheKey);
    await record.delete(transaction);
  }

  static Future<void> saveCubitList(List<CachedCubit> list) async {
    await kDatabase.transaction((transaction) async {
      for (var element in list) {
        final record = _store.record(element.cacheKey);
        await record.put(transaction, element.toJson(element.state));
      }
    });
  }
}
