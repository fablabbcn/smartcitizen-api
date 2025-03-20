import * as $ from "jquery";
import autocomplete from "autocompleter"

class DevicesTypeahead {
  constructor(container) {
    this.searchInput = $(container).find(".device-search");
    this.devicesList = $(container).find(".devices-list");
    this.dataList = $(container).find(".all-devices-list")
    this.deviceTemplate = $(container).find("#device-template");
  }

  init() {
    this.initSearch();
    this.initRemove();
  }

  initSearch() {
    autocomplete({
      input: this.searchInput[0],
      emptyMsg: this.searchInput.data("emptyMsg"),
      minLength: 3,
      debounceWaitMs: 200,
      className: "shadow-lg",
      fetch: (search, update) => {
        $.ajax({
          url: `/v1/devices/?q[name_or_description_or_owner_username_i_cont]=${search}&per_page=7`,
          cache: false,
          success: (devices) => {
            update(devices);
          }
        });
      },
      onSelect: (device) => {
        const rendered = this.renderDevice(device)
        this.devicesList[0].appendChild(rendered);
        this.showOrHideDevicesList();
        this.initRemove(rendered);
      },
      render: this.renderDevice.bind(this),
      customize: function(input, inputRect, container, maxHeight) {
          /* We want to offset slightly so the autocomplete displays below the rounded
           * corner of the search box, but also to add some lateral offset distance
           * wrt the device list below to make it less easy to confuse them. */
          const oneRem = parseFloat(getComputedStyle(document.documentElement).fontSize);
          container.style.left = parseFloat(container.style.left) + oneRem + "px";
          container.style.width = parseFloat(container.style.width) - 2 * oneRem + "px";
      }
    });
  }

  renderDevice(device) {
    const clone = $(this.deviceTemplate[0].content.cloneNode(true));
    clone.find(".template-input").val(device.id);
    clone.find(".template-title").text(device.name);
    clone.find(".template-owner").text(device.owner?.username);
    const location_string = [device.location.city, device.location.country_name].filter(Boolean).join(", ");
    clone.find(".template-location").text(location_string);
    clone.find(".template-description").text(device.description);
    return clone[0].querySelector("div");
  }

  showOrHideDevicesList() {
    if(this.devicesList.find(".device-select-list-item").length == 0) {
      this.devicesList.addClass("d-none");
    } else {
      this.devicesList.removeClass("d-none");
    }
  }

  initRemove() {
    this.devicesList.find(".device-select-list-item").each((ix, item) =>  {
      const link = $(item).find(".remove-link")
      link.show();
      link.click((event) => {
        event.preventDefault();
        item.remove();
        this.showOrHideDevicesList();
      });
    });
  }

}

export function setupDevicesTypeahead() {
  $(".devices-typeahead").each((ix, container) => {
    (new DevicesTypeahead(container)).init();
  });
}
