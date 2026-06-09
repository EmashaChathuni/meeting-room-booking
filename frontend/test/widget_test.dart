import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:meeting_room_booking/main.dart';

void main() {
  testWidgets('shows the splash screen on launch', (WidgetTester tester) async {
    SharedPreferences.setMockInitialValues({});

    await tester.pumpWidget(const MeetingRoomBookingApp());

    expect(find.text('Meeting Room Booking'), findsOneWidget);
    expect(find.text('Book your workspace'), findsOneWidget);

    await tester.pump(const Duration(milliseconds: 2500));
    await tester.pumpAndSettle();
  });
}
