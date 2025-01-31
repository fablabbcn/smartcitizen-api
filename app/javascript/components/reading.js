import * as $ from "jquery";
import * as d3 from "d3";
import * as strftime from "strftime";
import BTree from "sorted-btree";

class Reading {

  static instances = [];

  constructor(element) {
    this.element = element;
    this.valueElement = $(this.element).find(".big-number .value")[0];
    this.dateLabelElement = $(this.element).find(".date-line .label")[0];
    this.dateElement = $(this.element).find(".date-line .date")[0];
    this.trendElement = $(this.element).find(".trend")[0];
    this.deviceId = element.dataset["deviceId"];
    this.sensorId = element.dataset["sensorId"];
    this.fromDate = element.dataset["fromDate"] ?? this.getDateString(-24 * 60 * 60 * 1000);
    this.toDate = element.dataset["toDate"] ?? this.getDateString();
    this.syncAllOnPage = element.dataset["syncAllOnPage"] == "true";
    this.initialValue = this.valueElement.innerHTML;
    this.initialDateLabel = this.dateLabelElement.innerHTML;
    this.hoveredDateLabel = this.dateLabelElement.dataset["hoveredText"];
    this.noReadingLabel = this.dateLabelElement.dataset["noReadingText"];
    this.initialDate = this.dateElement.innerHTML;
    Reading.instances.push(this);
  }

  getDateString(offset = 0) {
    return new Date(new Date() - offset).toISOString()
  }

  async init() {
    await this.initData();
    this.initSparkline();
  }

  async initData() {
    const response = await $.ajax({
      url:`/devices/${this.deviceId}/readings?rollup=5m&sensor_id=${this.sensorId}&from=${this.fromDate}&to=${this.toDate}`,
      method: "GET",
    });
    const timestamps = response.readings.map(x => Date.parse(x[0]));
    const values = response.readings.map(x => x[1]);
    this.dataTree = new BTree();
    this.data = values.map((value, i) => {
      const timestamp = timestamps[i];
      this.dataTree.set(timestamp, value);
      return { value: value, time: timestamp };
    });
    this.minTimestamp = Math.min(...timestamps);
    this.maxTimestamp = Math.max(...timestamps);
    this.maxValue = Math.max(...values)
  }

  initSparkline() {
    const sparklineElement = $(this.element).find(".sparkline")[0];
    const STROKE_OFFSET = 2;
    const width = sparklineElement.offsetWidth;
    const height = sparklineElement.offsetHeight;
    const x = d3.scaleUtc()
      .domain([this.minTimestamp, this.maxTimestamp])
      .range([0, width]);
    const y = d3.scaleLinear()
      .domain([0, this.maxValue])
      .range([height - STROKE_OFFSET, 0]);
    const area = d3.area()
      .x(d => x(d.time))
      .y0(height)
      .y1(d => y(d.value));
    const line = d3.line()
      .x(d => x(d.time))
      .y(d => y(d.value));
    const svg = d3.create("svg")
      .attr("width", width)
      .attr("height", height);
    const g = svg.append("g")
      .attr("width", width)
      .attr("height", height - STROKE_OFFSET)
      .attr("transform", "translate(0, 2)");
    g.append("path")
      .attr("class", "fill")
      .attr("d", area(this.data))
    g.append("path")
      .attr("class", "stroke")
      .attr("d", line(this.data));

    this.cursor = svg.append("path")
      .attr("class", "cursor")
      .attr("visibility", "hidden")
      .attr("d", `M 0,0 L 0,${height} Z`)

    const moveHandler = (event) => {
        if (window.TouchEvent && event instanceof TouchEvent) event = event.touches[event.touches.length -1];
        const mouseX = d3.pointer(event)[0];
        const time = x.invert(mouseX).getTime();
        if(this.syncAllOnPage) {
          Reading.instances.forEach((instance) => { instance.showSpecificTime(time, mouseX) });
        } else {
          this.showSpecificTime(time, mouseX)
        }
    }

    const enterHandler = (event) => {
        this.cursor.attr("visibility", "visible");
        this.trendElement.style.visibility = "hidden";
        this.dateLabelElement.innerHTML = this.hoveredDateLabel;
    }

    const leaveHandler = (event) => {
        if(this.syncAllOnPage) {
          Reading.instances.forEach((instance) => { instance.showLatest() });
        } else {
          this.showLatest()
        }
    }

    $(sparklineElement).on("mouseenter", enterHandler);
    $(sparklineElement).on("mouseleave", leaveHandler)
    $(sparklineElement).on("touchstart", enterHandler);
    $(sparklineElement).on("touchend", leaveHandler)
    svg.on("mousemove", moveHandler);
    svg.on("touchmove", moveHandler);
    sparklineElement.appendChild(svg.node());
  }

  showSpecificTime(time, mouseX) {
    const timestamp = this.dataTree.nextLowerKey(time);
    const value = this.dataTree.get(timestamp);
    this.cursor.attr("visibility", "visible");
    this.cursor.attr("transform", `translate(${mouseX}, 0)`);
    this.trendElement.style.visibility = "hidden";
    this.dateLabelElement.innerHTML = this.hoveredDateLabel;
    if(value) {
      this.dateElement.innerHTML = strftime("%B %d, %Y %H:%M", new Date(timestamp));
      this.valueElement.innerHTML = value.toFixed(2);
    } else {
      this.dateElement.innerHTML = this.noReadingLabel;
      this.valueElement.innerHTML = "-.--";
    }
  }

  showLatest() {
    this.cursor.attr("visibility", "hidden");
    this.valueElement.innerHTML = this.initialValue;
    this.trendElement.style.visibility = "visible";
    this.dateLabelElement.innerHTML = this.initialDateLabel;
    this.dateElement.innerHTML = this.initialDate;
  }
}

export function setupReadings() {
  $(".reading").each(function(ix, element) {
    const reading = new Reading(element);
    reading.init();
  });
}

