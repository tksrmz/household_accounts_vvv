import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import '../../util/service_locator/main.dart';

class MainPageAppBar extends AppBar {
  MainPageAppBar({
    required String title,
    super.key,
  }) : super(
          title: Text(title),
          actions: [
            IconButton(
              icon: const Icon(Icons.logout),
              onPressed: () async {
                await sl.reset();
                FirebaseAuth.instance.signOut();
              },
            ),
          ],
        );
}
