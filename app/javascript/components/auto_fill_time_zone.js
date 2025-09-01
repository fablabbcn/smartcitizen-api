import * as $ from "jquery";

export function setupAutoFillTimeZone() {
  const tz = Intl.DateTimeFormat().resolvedOptions().timeZone;
  $(".auto_fill_time_zone").val(tz);
}
