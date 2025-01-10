import * as $ from "jquery";
import Tags from "bootstrap5-tags";
import {setupCopyableInputs} from "components/copyable_input";
import {setupDeviceMaps} from "components/device_map";
import {setupMapLocationPickers} from "components/map_location_picker";
import {setupReadings} from "components/reading";

export default function setupApplication() {
  $(function() {
    setupCopyableInputs();
    setupDeviceMaps();
    setupMapLocationPickers();
    setupReadings();
    Tags.init(".tag-select", {
      baseClass: "tags-badge badge bg-light border text-dark text-truncate p-2 rounded-4"
    });
  });
}
