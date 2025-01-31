import * as $ from "jquery";
import L from 'leaflet';
import 'leaflet-defaulticon-compatibility';


export function setupMaps() {
  $(".map").each(function(ix, element) {
    const points = JSON.parse(element.dataset["points"]);
    const markerUrl = element.dataset["markerUrl"];
    const markerShadowUrl = element.dataset["markerShadowUrl"];
    const icon = L.icon({
      iconUrl: markerUrl,
      shadowUrl: markerShadowUrl,
      iconSize: [32, 40],
      shadowSize: [51, 59],
      iconAnchor: [16, 40],
      shadowAnchor: [10, 59]
    });
    const featureGroup = L.featureGroup()
    const map = L.map(element, {
      attributionControl: false,
      zoomControl: false,
      scrollWheelZoom: false,
      dragging: false,
      touchZoom: false,
      doubleClickZoom: false,
      boxZoom: false,
      keyboard: false,
      tap: false,
    });
    L.tileLayer('https://tiles.stadiamaps.com/tiles/stamen_toner/{z}/{x}/{y}{r}.{ext}', {
      minZoom: 0,
      maxZoom: 20,
      attribution: '&copy; <a href="https://www.stadiamaps.com/" target="_blank">Stadia Maps</a> &copy; <a href="https://www.stamen.com/" target="_blank">Stamen Design</a> &copy; <a href="https://openmaptiles.org/" target="_blank">OpenMapTiles</a> &copy; <a href="https://www.openstreetmap.org/copyright">OpenStreetMap</a> contributors',
      ext: 'png'
    }).addTo(map);
    points.forEach((point) => {
      if (point.lat && point.lng) {
        const marker = L.marker([point.lat, point.lng], { icon: icon });
        marker.addTo(map);
        marker.addTo(featureGroup);
      }
    });
    map.fitBounds(featureGroup.getBounds(), { padding: L.point(32, 40), maxZoom: 16});
  });
}
