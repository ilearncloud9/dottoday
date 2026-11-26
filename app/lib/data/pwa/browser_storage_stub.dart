// Only the web keeps Dottoday's data in browser storage (ED-188).
Future<bool?> persisted() async => null;

Future<bool?> persist() async => null;

bool asked(String owner) => true;

void markAsked(String owner) {}
