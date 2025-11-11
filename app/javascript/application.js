import * as $ from "jquery";
import flatpickr from "flatpickr";
import Tags from "bootstrap5-tags";
import {setupCopyableInputs} from "components/copyable_input";
import {setupMaps} from "components/map";
import {setupMapLocationPickers} from "components/map_location_picker";
import {setupReadings} from "components/reading";
import {setupDevicesTypeahead} from "components/devices_typeahead";
import {setupExtraInfos} from "components/extra_info";
import {setupAutoFillTimeZone} from "components/auto_fill_time_zone";
import {setupBlurables} from "components/blurable";
import {setupOnboarding} from "components/onboarding";

export default function setupApplication() {
  $(function() {

    Tags.init(".tag-select", {
      baseClass: "tags-badge badge bg-light border text-dark text-truncate p-2 rounded-4"
    });
    flatpickr(".flatpickr", { enableTime: true, time_24hr: true, defaultHour: 0, dateFormat: "Z", altInput: true});
    setupCopyableInputs();
    setupMaps();
    setupMapLocationPickers();
    setupExtraInfos();
    setupDevicesTypeahead();
    setupReadings();
    setupAutoFillTimeZone();
    setupBlurables();
    setupOnboarding();
  });
}
