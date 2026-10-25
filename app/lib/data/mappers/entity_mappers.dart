import 'package:dottoday/data/db/app_database.dart';
import 'package:dottoday/data/mappers/row_codec.dart';
import 'package:dottoday/domain/entities/occurrence.dart';
import 'package:dottoday/domain/entities/routine.dart';
import 'package:dottoday/domain/entities/series.dart';
import 'package:dottoday/domain/entities/settings.dart';
import 'package:dottoday/domain/entities/subtask.dart';

// Row <-> entity for each synced table; `jsonb` columns are JSON text.

const occurrenceCodec = RowCodec(jsonColumns: {'alerts'});
const seriesCodec = RowCodec(jsonColumns: {'alerts', 'subtask_template'});
const subtaskCodec = RowCodec();
const profileCodec = RowCodec(jsonColumns: {'settings'});
const routineCodec = RowCodec(jsonColumns: {'items'});

Occurrence occurrenceFromRow(OccurrenceRow row) =>
    Occurrence.fromJson(occurrenceCodec.decode(row));

Series seriesFromRow(SeriesRow row) => Series.fromJson(seriesCodec.decode(row));

Subtask subtaskFromRow(SubtaskRow row) =>
    Subtask.fromJson(subtaskCodec.decode(row));

Profile profileFromRow(ProfileRow row) =>
    Profile.fromJson(profileCodec.decode(row));

Routine routineFromRow(RoutineRow row) =>
    Routine.fromJson(routineCodec.decode(row));
