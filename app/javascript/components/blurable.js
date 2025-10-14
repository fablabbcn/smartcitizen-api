import * as $ from "jquery";

export function setupBlurables() {
  $(".blurable").each(function(ix, element) {
    console.log(element);
    let cta = $(element).find(".blurable-cta");
    let ctaContainer = $(element).find(".blurable-cta-container");
    let inner = $(element).find(".blurable-inner");
    cta.click(function(event) {
      event.preventDefault();
      ctaContainer.remove();
      inner.css("filter", "none");
    });
  });
}
