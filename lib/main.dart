import 'package:flutter/material.dart';

import 'app/carepals_app.dart';
import 'core/database/app_database.dart';

void main() {
  final appDatabase = AppDatabase();
  runApp(CarePalsApp(appDatabase: appDatabase));
}
