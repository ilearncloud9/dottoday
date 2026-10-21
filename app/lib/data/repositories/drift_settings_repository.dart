import 'package:dottoday/data/daos/profiles_dao.dart';
import 'package:dottoday/data/db/app_database.dart';
import 'package:dottoday/data/mappers/row_codec.dart';
import 'package:dottoday/domain/entities/settings.dart';
import 'package:dottoday/domain/repositories/settings_repository.dart';

const _codec = RowCodec(jsonColumns: {'settings'});

Profile? _toEntity(ProfileRow? row) =>
    row == null ? null : Profile.fromJson(_codec.decode(row));

/// [SettingsRepository] over the local Drift database.
final class DriftSettingsRepository implements SettingsRepository {
  DriftSettingsRepository(AppDatabase db) : _dao = ProfilesDao(db);

  final ProfilesDao _dao;

  @override
  Stream<Profile?> watchProfile(String userId) =>
      _dao.watchById(userId).map(_toEntity);

  @override
  Future<Profile?> findLocalProfile() async =>
      _toEntity(await _dao.findFirst());

  @override
  Future<void> upsert(Profile profile) =>
      _dao.upsert(_codec.encode<ProfileRow>(profile.toJson()));
}
