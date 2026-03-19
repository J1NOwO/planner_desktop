class ChecklistItem {
  final String id;
  final String text;
  final bool done;
  final bool isGlobal;

  const ChecklistItem({
    required this.id,
    required this.text,
    this.done = false,
    this.isGlobal = false,
  });

  ChecklistItem copyWith({bool? done}) {
    return ChecklistItem(
      id: id,
      text: text,
      done: done ?? this.done,
      isGlobal: isGlobal,
    );
  }
}
