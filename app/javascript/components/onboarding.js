import * as $ from "jquery";
import { MapLocationPicker } from "./map_location_picker";

const TOKEN_TIMEOUT = 15 * 60;

class OnboardingDevice {
  constructor(container) {
    this.container = container;
    this.getDeviceTokenButton = $(container).find(".get-device-token");
    this.deviceTokenTemplate = $(container).find(".device-token-template");
    this.deviceTokenField = $(container).find(".device-token-field");
  }

  init() {
    this.initGetDeviceTokenButton();
  }

  initGetDeviceTokenButton() {
    $(this.getDeviceTokenButton).on("click", ((event) => {
      event.preventDefault();
      this.getDeviceToken();
    }).bind(this));
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
    $(this.container).find(".device-token-section").removeClass("bg-primary").removeClass("bg-danger").addClass("bg-success")
    this.countdownElement.parent().text("✔️")
    this.countdownElement = undefined;
  }
}

class Onboarding {
  constructor(container) {
    this.devicesContainer = $(container).find(".devices");
    this.deviceTemplate = $(container).find(".device-template");
    this.addButton = $(container).find(".add-device-button")
  }

  init() {
    $(this.devicesContainer).find(".onboarding-device").each((ix, container) => {
      (new OnboardingDevice(container)).init();
    });
    $(this.addButton).on("click", ((event) => {
      event.preventDefault();
      this.addNewDevice();
    }).bind(this));
  }

  generateRandomId() {
    let size = 6;
    return [...Array(size)].map(() => Math.floor(Math.random() * 16).toString(16)).join('');
  }

  addNewDevice() {
    const clone = $(this.deviceTemplate[0].content.cloneNode(true).firstElementChild);
    let id = this.generateRandomId();
    clone.attr("id", `onboarding-device-${id}`);
    clone.find("#device_latitude").attr("id", `device_latitude_${id}`)
    clone.find("#device_longitude").attr("id", `device_longitude_${id}`)
    this.devicesContainer.append(clone);
    let elem = $(`#onboarding-device-${id}`);
    new OnboardingDevice(elem).init()
    let picker = elem.find(".map-location-picker")[0];
    picker.dataset["latitudeInputId"] = `device_latitude_${id}`;
    picker.dataset["longitudeInputId"] = `device_longitude_${id}`;
    new MapLocationPicker(picker);
  }
}

export function setupOnboarding() {
  $(".onboarding").each((ix, container) => {
    (new Onboarding(container)).init();
  });
}
