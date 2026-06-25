import * as $ from "jquery";
import * as bootstrap from "bootstrap";
import { MapLocationPicker } from "./map_location_picker";
import { setupTags } from "./tags.js";

const TOKEN_TIMEOUT = 15 * 60;

class OnboardingDevice {
  constructor(container, onboarding) {
    this.container = container;
    this.onboarding = onboarding;
    this.getDeviceTokenButton = $(container).find(".get-device-token");
    this.closeButton = $(container).find(".btn-close");
    this.deviceTokenTemplate = $(container).find(".device-token-template");
    this.deviceTokenField = $(container).find(".device-token-field");
  }

  init() {
    this.initGetDeviceTokenButton();
    this.initCloseButton();
  }

  initGetDeviceTokenButton() {
    $(this.getDeviceTokenButton).on("click", ((event) => {
      event.preventDefault();
      this.getDeviceToken();
    }).bind(this));
  }

  initCloseButton() {
    $(this.closeButton).on("click", ((event) => {
      event.preventDefault();
      this.remove();
    }).bind(this));
  }

  remove() {
    this.container.remove();
    this.onboarding.setSubmittable();
  }

  getDeviceToken() {
    $.ajax({
      url: "/v0/onboarding/device",
      method: "POST",
      cache: false,
      success: ((response) => {
        this.deviceTokenFetched(response);
      }).bind(this)
    })
  }

  deviceTokenFetched(response) {
    this.deviceToken = response.device_token;
    this.onboardingSession = response.onboarding_session;
    const clone = $(this.deviceTokenTemplate[0].content.cloneNode(true));
    clone.find(".token").text(this.deviceToken);
    this.countdownElement = clone.find(".countdown")
    this.setCountdownValue(TOKEN_TIMEOUT);
    this.deviceTokenField.val(this.deviceToken)
    $(this.getDeviceTokenButton).replaceWith(
      clone
    );
    var countdown = TOKEN_TIMEOUT;
    let timer = window.setInterval((() => {
        this.setCountdown(countdown, timer);
        countdown -= 1;
    }).bind(this), 1000);
  }

  setCountdown(countdown, timer) {
    if(this.countdownElement) {
        this.setCountdownValue(countdown);
        if(countdown % 10 == 0) {
          this.checkDeviceCompletion(((completed) => {
            if(completed) {
              window.clearInterval(timer);
              this.setDeviceRegistered()
            }
          }).bind(this));
        } else if (countdown <= 0) {
          $(this.container).find(".device-token-section").replaceWith(this.getDeviceTokenButton);
          this.initGetDeviceTokenButton();
          window.clearInterval(timer);
          this.setDeviceRegistered();
        } else if (countdown <= 30) {
          $(this.container).find(".device-token-section").removeClass("bg-primary").addClass("bg-danger")
        }
    }
  }

  setCountdownValue(countdown) {
    let mins = String(Math.floor(countdown / 60)).padStart(2, "0");
    let secs = String(countdown % 60).padStart(2, "0");
    this.countdownElement.text(`${mins}:${secs}`);
  }

  checkDeviceCompletion(callback) {
    $.ajax({
      url: "/v0/onboarding/device",
      method: "GET",
      cache: false,
      headers: {
        "OnboardingSession": this.onboardingSession
      },
      success: (response) => {
        callback(response.device_handshake);
      }
    })
  }

  setDeviceRegistered() {
    $(this.container).find(".device-token-section").removeClass("bg-primary").removeClass("bg-danger").addClass("bg-success").addClass("registered");
    $(this.container).find(".progress-dots").addClass("step-3")
    $(this.container).find(".countdown").remove()
    this.countdownElement = undefined;
    this.onboarding.setSubmittable();
    this.closeButton.addClass("d-none");
  }
}

class Onboarding {
  constructor(container) {
    this.devicesContainer = $(container).find(".devices");
    this.deviceTemplate = $(container).find(".device-template");
    this.addButton = $(container).find(".add-device-button")
    this.optionalFields = $(container).find(".optional");
  }

  initDevices() {
    $(this.devicesContainer).find(".onboarding-device").each((ix, container) => {
      (new OnboardingDevice(container, this)).init();
    });
    $(this.addButton).on("click", ((event) => {
      event.preventDefault();
      this.addNewDevice();
    }).bind(this));
  }

  initOptionalFields() {
    let toggle = this.optionalFields.find(".toggle");
    $(toggle).on("click", ((event) => {
      event.preventDefault();
      this.optionalFields.find(".optional-fields").toggleClass("d-none");
      this.optionalFields.toggleClass("mb-5");
      let image = toggle.find("img");
      let oldSrc = image.attr("src");
      image.attr("src", image.data("alternateSrc"));
      image.data("alternateSrc", oldSrc);
    }).bind(this));
  }

  init() {
    this.initDevices();
    this.initOptionalFields();
  }

  generateRandomId() {
    let size = 6;
    return [...Array(size)].map(() => Math.floor(Math.random() * 16).toString(16)).join('');
  }

  addNewDevice() {
    const templateContent = this.deviceTemplate[0].innerHTML;
    const index = Date.now()
    const clone = $(templateContent.replaceAll("NEW_RECORD", index));
    const lastDevice = $(".onboarding-device").last();
    let id = this.generateRandomId();
    clone.attr("id", `onboarding-device-${id}`);
    this.devicesContainer.append(clone);
    let elem = $(`#onboarding-device-${id}`);
    elem.find(".exposure_input").val(lastDevice.find(".exposure_input").val());
    elem.find(".geocoding_input").val(lastDevice.find(".geocoding_input").val());
    elem.find(".latitude_input").val(lastDevice.find(".latitude_input").val());
    elem.find(".longitude_input").val(lastDevice.find(".longitude_input").val());
    elem.find(".btn-close").removeClass("d-none");
    new OnboardingDevice(elem, this).init()
    let picker = elem.find(".map-location-picker")[0];
    picker.dataset["containerSelector"] = `#onboarding-device-${id}`;
    new MapLocationPicker(picker);
    setupTags(`#onboarding-device-${id} .tag-select`);
    elem.find(".name_input").trigger("focus");
    this.setSubmittable();
  }

  setSubmittable() {
    const devices = $(".device-token-section");
    const registeredDevices = $(".device-token-section.registered");
    const wrapper = document.getElementById("onboarding-submit-wrapper")
    const tooltip = bootstrap.Tooltip.getOrCreateInstance(wrapper);
    const submit = document.getElementById("onboarding-submit");
    if(registeredDevices.length >= devices.length) {
      tooltip.disable();
      submit.disabled = false;
    } else {
      tooltip.enable();
      submit.disabled = true;
    }

  }
}

export function setupOnboarding() {
  $(".onboarding").each((ix, container) => {
    (new Onboarding(container)).init();
  });
}

window.bootstrap = bootstrap
