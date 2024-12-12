function setupCopyableInputs() {
  $(".copyable-input").each(function(ix, element) {
    let input = $(element).find("input");
    let button = $(element).find("button");
    input.focus(function(event) {
      input.select();
    });
    button.click(function(event) {
      input.select();
      navigator.clipboard.writeText(input.val());
    });
  });
}
