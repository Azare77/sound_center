// ignore_for_file:  constant_identifier_names, non_constant_identifier_names

import 'package:material_ui/material_ui.dart';
import 'package:sound_center/features/local_audio/domain/repositories/audio_repository.dart';

const AudioColumns QUERY_DEFAULT_COLUMN_ORDER = AudioColumns.id;

const bool QUERY_DEFAULT_DESC = true;

const String APP_DB_FOLDER_LINUX = ".local/share/app.sound_center.player/DB";

const double LIST_ITEM_HEIGHT = 70;

const double EXPANDED_HEIGHT = 300;

const int VERSION_NUMBER = 4;

const String VERSION_NAME = "v1.0.0";

final GlobalKey<NavigatorState> NAVIGATOR_KEY = GlobalKey<NavigatorState>();
