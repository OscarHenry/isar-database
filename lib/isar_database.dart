import 'dart:async';
import 'dart:developer';

import 'package:isar/isar.dart';
import 'package:isar_database/user.dart';

class IsarDataBase {
  static const String _dbName = 'local_db';

  static void ensureInitialized() {
    Isar.openSync([UserSchema],name: _dbName);
  }

   late final Isar db = Isar.getInstance(_dbName)!;

  IsarCollection<User> get userCollection => db.users;

  // CRUD
   int? create<T>(T object){
     try {
       if (db.isOpen) {
         return db.writeTxnSync(() {
           return db.collection<T>().putSync(object);
         });
       } else {
         throw Exception('Database is Closed');
       }
     } catch (e, s) {
       log('${runtimeType.toString()} $e\n$s', error: 'DB Error');
       return null;
     }
  }

  bool? delete<T>(int id) {
    try {
      if (db.isOpen) {
        return db.writeTxnSync(() {
          return db.collection<T>().deleteSync(id);
        });
      } else {
        throw Exception('Database is Closed');
      }
    } catch (e, s) {
      log('${runtimeType.toString()} $e\n$s', error: 'DB Error');
      return null;
    }
  }

  int? update<T>(T object){
    try {
      if (db.isOpen) {
        return db.writeTxnSync(() {
          return db.collection<T>().putSync(object);
        });
      } else {
        throw Exception('Database is Closed');
      }
    } catch (e, s) {
      log('${runtimeType.toString()} $e\n$s', error: 'DB Error');
      return null;
    }
  }

}