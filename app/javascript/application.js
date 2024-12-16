import * as $ from "jquery";
import {setupCopyableInputs} from "components/copyable_input";
import {setupDeviceMaps} from "components/device_map";

export default function setupApplication() {
  $(function() {
    setupCopyableInputs();
    setupDeviceMaps();
  });
}
