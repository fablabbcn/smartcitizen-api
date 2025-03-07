import * as $ from "jquery";

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
    this.searchInput.on("input", (event) => {
      const value = this.searchInput.val();
      if(value) {
        const option = $(this.dataList).find(`option[value="${value}"]`)
        if(option.length > 0) {
          this.searchInput.val(null);
          if(this.devicesList.find(`input[value="${value}"]`).length == 0) {
            const clone = $(this.deviceTemplate[0].content.cloneNode(true));
            clone.find(".template-input").val(option.val());
            clone.find(".template-title").text(option.text());
            clone.find(".template-owner").text(option.data("owner"));
            clone.find(".template-location").text(option.data("location"));
            clone.find(".template-description").text(option.data("description"));
            this.devicesList[0].appendChild(clone[0]);
            this.showOrHideDevicesList();
            this.initRemove(clone[0]);
            return false;
          }
        }
      }
    });
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
      $(item).find(".remove-link").click((event) => {
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
