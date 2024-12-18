import * as $ from "jquery";
import {setupCopyableInputs} from "components/copyable_input";
import {setupDeviceMaps} from "components/device_map";
import {setupMapLocationPickers} from "components/map_location_picker";

export default function setupApplication() {
  $(function() {
    setupCopyableInputs();
    setupDeviceMaps();
    setupMapLocationPickers();
  });
}
