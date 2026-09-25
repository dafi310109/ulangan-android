import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:coin_flip/main.dart';

void main() {
  testWidgets('CoinFlipApp loads successfully and displays all key elements', (WidgetTester tester) async {
    tester.view.physicalSize = const Size(600, 1600);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.resetPhysicalSize);

    await tester.pumpWidget(const CoinFlipApp());
    await tester.pumpAndSettle();

    // Verify Title & Author
    expect(find.text('Coin Flip'), findsOneWidget);
    expect(find.text('Speed Code Challenge'), findsOneWidget);
    expect(find.text('Dafi Al Fajar • Soft UI'), findsOneWidget);

    // Verify Mode selector options
    expect(find.text('Bebas'), findsOneWidget);
    expect(find.text('Tebak'), findsOneWidget);
    expect(find.text('2 Koin'), findsOneWidget);

    // Verify Trending Material options
    expect(find.text('Trending'), findsOneWidget);
    expect(find.text('Emas'), findsOneWidget);
    expect(find.text('Perak'), findsOneWidget);
    expect(find.text('Perunggu'), findsOneWidget);

    // Verify Action button
    expect(find.text('LEMPAR KOIN SEKARANG'), findsOneWidget);

    // Verify Stats
    expect(find.text('Statistik Lemparan'), findsOneWidget);
    expect(find.text('Total: 0'), findsOneWidget);
  });

  testWidgets('Coin flip action executes and updates statistics', (WidgetTester tester) async {
    tester.view.physicalSize = const Size(600, 1600);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.resetPhysicalSize);

    await tester.pumpWidget(const CoinFlipApp());
    await tester.pumpAndSettle();

    // Tap the flip button
    final flipButton = find.text('LEMPAR KOIN SEKARANG');
    expect(flipButton, findsOneWidget);
    await tester.tap(flipButton);
    await tester.pump(); // Start animation

    // Should indicate flipping in progress
    expect(find.text('SEDANG MELEMPAR...'), findsOneWidget);

    // Fast forward past animation duration (1600ms)
    await tester.pump(const Duration(milliseconds: 1700));
    await tester.pumpAndSettle();

    // Total flips should now be 1
    expect(find.text('Total: 1'), findsOneWidget);
    expect(find.textContaining('Lemparan #1'), findsOneWidget);
  });

  testWidgets('Mode selector switches to Tebak mode correctly', (WidgetTester tester) async {
    tester.view.physicalSize = const Size(600, 1600);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.resetPhysicalSize);

    await tester.pumpWidget(const CoinFlipApp());
    await tester.pumpAndSettle();

    // Tap on 'Tebak' mode tab
    await tester.tap(find.text('Tebak'));
    await tester.pumpAndSettle();

    // Verify Tebak controls appear
    expect(find.text('Pilih Tebakanmu:'), findsOneWidget);
    expect(find.text('KEPALA'), findsOneWidget);
    expect(find.text('EKOR'), findsOneWidget);
  });
}
