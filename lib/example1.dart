import 'dart:isolate';

void main() async {
  await for (final msg in getMessages().take(10)) {
    print(msg);
  }
}

Stream<String> getMessages() {
  final receivePort = ReceivePort();
  return Isolate.spawn(_getMessages, receivePort.sendPort)
      .asStream()
      .asyncExpand((_) {
        return receivePort;
      })
      .takeWhile((element) => element is String)
      .cast();
}

void _getMessages(SendPort sendPort) async {
  await for (final now in Stream.periodic(
    Duration(milliseconds: 300),
    (_) => DateTime.now().toIso8601String(),
  )) {
    sendPort.send(now);
  }
}
