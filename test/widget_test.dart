import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:network_image_mock/network_image_mock.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:riverpod_ecommerce/src/app.dart';
import 'package:riverpod_ecommerce/src/providers/repository_providers.dart';

void main() {
  testWidgets(
    'catalog loads, navigation works, and adding a product updates the cart badge',
    (tester) async {
      // The default 800x600 test surface is too small to fit a two-column
      // product grid without scrolling; use a larger, phone-like surface so
      // the elements we interact with are actually on screen.
      tester.view.physicalSize = const Size(1080, 2400);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);

      await mockNetworkImagesFor(() async {
        SharedPreferences.setMockInitialValues({});
        final prefs = await SharedPreferences.getInstance();

        await tester.pumpWidget(
          ProviderScope(
            overrides: [sharedPreferencesProvider.overrideWithValue(prefs)],
            child: const RiverpodEcommerceApp(),
          ),
        );

        // Initial frame shows a loading state while products are fetched.
        expect(find.text('Catalogue'), findsWidgets);
        expect(find.byType(CircularProgressIndicator), findsWidgets);

        await tester.pump(const Duration(milliseconds: 800));

        // Catalog data has loaded and the four tabs are present.
        expect(find.text('Casque sans fil AuraSound'), findsOneWidget);
        expect(find.text('Favoris'), findsOneWidget);
        expect(find.text('Panier'), findsOneWidget);
        expect(find.text('Profil'), findsOneWidget);

        // Opening a product and adding it to the cart updates the badge.
        await tester.tap(find.text('Casque sans fil AuraSound'));
        await tester.pump();
        await tester.pump(const Duration(milliseconds: 400));

        await tester.tap(find.text('Ajouter au panier'));
        await tester.pump();
        await tester.pump(const Duration(milliseconds: 400));

        expect(find.text('1'), findsWidgets);

        // Let the button's revert timer finish so no timer is left pending.
        await tester.pump(const Duration(milliseconds: 800));
      });
    },
  );
}
