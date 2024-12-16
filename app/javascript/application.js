import * as $ from "jquery";
import {setupCopyableInputs} from "components/copyable_input";

export default function setupApplication() {
  $(function() {
    setupCopyableInputs();
  });
}
