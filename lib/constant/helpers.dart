import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

bool isDesktop(BuildContext context) =>
    MediaQuery.of(context).size.width >= 900;

String iceUserName = dotenv.env['ICE_USERNAME']!;
String iceCredential = dotenv.env['ICE_CRED']!;
