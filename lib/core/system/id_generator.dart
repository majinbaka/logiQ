abstract class IdGenerator {
  String nextId();
}

class TimestampIdGenerator implements IdGenerator {
  const TimestampIdGenerator();

  @override
  String nextId() => DateTime.now().microsecondsSinceEpoch.toString();
}
