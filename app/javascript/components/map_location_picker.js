import * as $ from "jquery";
import L from 'leaflet';
import 'leaflet-defaulticon-compatibility';

const DEFAULT_LATITUDE = 41.396767038690285;
const DEFAULT_LONGITUDE = 2.1943382543588137;

class MapLocationPicker {
  constructor(element) {
    this.element = element
    this.latitudeInput = $("#" + element.dataset["latitudeInputId"]);
    this.longitudeInput = $("#" + element.dataset["longitudeInputId"]);
    const markerUrl = element.dataset["markerUrl"];
    const markerShadowUrl = element.dataset["markerShadowUrl"];
    this.icon = L.icon({
      iconUrl: markerUrl,
      shadowUrl: markerShadowUrl,
      iconSize: [32, 40],
      shadowSize: [51, 59],
      iconAnchor: [16, 40],
      shadowAnchor: [10, 59]
    });
    this.map = L.map(this.element, {
      center: this.defaultCenterLatLng(),
      zoom: this.defaultZoom(),
      attributionControl: false,
    });
    L.tileLayer('https://tiles.stadiamaps.com/tiles/stamen_toner/{z}/{x}/{y}{r}.{ext}', {
      minZoom: 0,
      maxZoom: 20,
      attribution: '&copy; <a href="https://www.stadiamaps.com/" target="_blank">Stadia Maps</a> &copy; <a href="https://www.stamen.com/" target="_blank">Stamen Design</a> &copy; <a href="https://openmaptiles.org/" target="_blank">OpenMapTiles</a> &copy; <a href="https://www.openstreetmap.org/copyright">OpenStreetMap</a> contributors',
      ext: 'png'
    }).addTo(this.map);

    if(this.getLatLng()) {
      this.createMarker();
    }

    this.map.on('click', function(e) {
        const latLng= e.latlng;
        this.setLatLng(latLng.lat, latLng.lng);
        if(this.marker) {
          this.updateMarkerPosition();
        } else {
          this.createMarker();
        }
    }.bind(this));
  }

  defaultZoom() {
    return this.getLatLng()  ? 15 : 3;
  }

  defaultCenterLatLng() {
    return this.getLatLng() || [DEFAULT_LATITUDE, DEFAULT_LONGITUDE]
  }

  getLatLng() {
    const lat = this.latitudeInput.val();
    const lng = this.longitudeInput.val();
    if(lat && lng) {
      return { "lat": lat, "lng": lng }
    }
  }

  setLatLng(lat, lng) {
    this.latitudeInput.val(lat);
    this.longitudeInput.val(lng);
  }

  createMarker() {
    const position = this.getLatLng();
    this.marker = L.marker([position.lat, position.lng], { icon: this.icon, draggable: true }).addTo(this.map);
    this.marker.on('dragend', function(event) {
      var position = event.target.getLatLng();
      this.setLatLng(position.lat, position.lng);
      this.updateMarkerPosition();
    }.bind(this));
    this.map.panTo(new L.LatLng(position.lat, position.lng));
  }

  updateMarkerPosition() {
    const position = this.getLatLng();
    this.marker.setLatLng(new L.LatLng(position.lat, position.lng),{draggable:'true'});
    this.map.panTo(new L.LatLng(position.lat, position.lng))
  }
}



export function setupMapLocationPickers() {
  $(".map-location-picker").each(function(ix, element) {
    new MapLocationPicker(element);
  });
}
