import 'package:flutter/material.dart';

import '../widgets/shared.dart';

class RequestsScreen extends StatelessWidget {
  const RequestsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Text('Today\'s agenda is empty', style: appTextStyle()),
    );
  }
}

