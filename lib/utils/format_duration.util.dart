String formatDuration(Duration duration, [bool padAll = false]) {
  int hours = (duration.inHours % 60);
  String minutes = (duration.inMinutes % 60).toString();
  String seconds = (duration.inSeconds % 60).toString().padLeft(2, '0');

  if (hours > 0) {
    minutes = minutes.toString().padLeft(2, '0');
    return '$hours:$minutes:$seconds';
  } else if (padAll) {
    minutes = minutes.toString().padLeft(2, '0');
    return '$minutes:$seconds';
  } else {
    return '$minutes:$seconds';
  }
}
