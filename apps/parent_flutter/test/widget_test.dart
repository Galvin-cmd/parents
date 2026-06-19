import 'package:flutter_test/flutter_test.dart';
import 'package:parent_flutter/main.dart';
import 'package:parent_flutter/src/mock_data.dart';

void main() {
  testWidgets('renders parent app shell', (tester) async {
    await tester.pumpWidget(ParentApp(initialData: mockBootstrapData));
    await tester.pump();

    expect(find.text('豆小宝'), findsOneWidget);
    expect(find.text('工作台'), findsOneWidget);
    expect(find.text('安全'), findsOneWidget);
    expect(find.text('成长'), findsOneWidget);
  });
}
