enum DateTimeStyle { datetime, time, timestamp, none }

DateTimeStyle styleById(int id) {
  switch (id) {
    case 0:
      return DateTimeStyle.datetime;
    case 1:
      return DateTimeStyle.time;
    case 2:
      return DateTimeStyle.timestamp;
    case 3:
      return DateTimeStyle.none;
    default:
      return DateTimeStyle.datetime;
  }
}

int idByStyle(DateTimeStyle style) {
  switch (style) {
    case DateTimeStyle.datetime:
      return 0;
    case DateTimeStyle.time:
      return 1;
    case DateTimeStyle.timestamp:
      return 2;
    case DateTimeStyle.none:
      return 3;
  }
}
