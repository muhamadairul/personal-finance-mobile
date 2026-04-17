import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:pencatat_keuangan/app.dart';
import 'package:pencatat_keuangan/services/notification_service.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  await NotificationService().initialize();
  await initializeDateFormatting('id_ID', null);
  runApp(const ProviderScope(child: PencatatKeuanganApp()));
}
