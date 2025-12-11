import 'package:flutter/material.dart';

import '../widgets/shared.dart';

class InboxScreen extends StatelessWidget {
  const InboxScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Text('Notifications will appear here', style: appTextStyle()),
    );
  }
}

