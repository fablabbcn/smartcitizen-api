import * as $ from "jquery";

export function setupExtraInfos() {
  $(".extra-info").each(function(ix, element) {
    $(element).find(".icon").on("mouseenter", function(event) {
      $(".extra-info .info").hide();
      $(element).find(".info").show();
    });
    $(element).find(".icon").on("mouseout", function(event) {
      $(element).find(".info").hide();
    });
    $(element).find(".icon").on("touchstart", function(event) {
      const infoElement = $(element).find(".info")
      const initiallyHidden = $(infoElement).is(":hidden")
      $(".extra-info .info").hide();
      if (initiallyHidden) {
        infoElement.show();
      }
    });
  });
}
