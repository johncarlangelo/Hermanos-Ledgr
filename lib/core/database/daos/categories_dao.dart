import 'package:drift/drift.dart';
import 'package:hermanos_ledgr/core/database/app_database.dart';
import 'package:hermanos_ledgr/core/database/tables/categories_table.dart';

part 'categories_dao.g.dart';

@DriftAccessor(tables: [CategoriesTable])
class CategoriesDao extends DatabaseAccessor<AppDatabase> with _$CategoriesDaoMixin {
  CategoriesDao(super.db);

  Stream<List<CategoriesTableData>> watchAllCategories() => select(categoriesTable).watch();

  Future<List<CategoriesTableData>> getAllCategories() => select(categoriesTable).get();

  Future<CategoriesTableData?> getCategoryById(String id) =>
      (select(categoriesTable)..where((t) => t.id.equals(id))).getSingleOrNull();

  Future<int> insertCategory(CategoriesTableCompanion cat) =>
      into(categoriesTable).insert(cat, mode: InsertMode.insertOrIgnore);

  Future<int> deleteCustomCategory(String id) =>
      (delete(categoriesTable)..where((t) => t.id.equals(id) & t.isCustom.equals(true))).go();
}
