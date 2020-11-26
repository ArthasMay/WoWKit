import { r as registerInstance, h, e as Host } from "./index-86fbaafa.js";
import {
  s as same,
  e as eventToNative,
  c as createEvent
} from "./utils-41bad5d1.js";

const wxImageCss =
  ":host{width:3.2rem;height:2.4rem;display:inline-block;overflow:hidden}.image{width:100%;height:100%;display:block;overflow:hidden}.scaleToFill{object-fit:fill}.aspectFit{object-fit:contain}.aspectFill{object-fit:cover}.center{object-position:center}.top{object-position:center top}.bottom{object-position:center bottom}.left{object-position:left center}.right{object-position:right center}.topLeft{object-position:left top}.topRight{object-position:right top}.bottomLeft{object-position:left bottom}.bottomRight{object-position:right bottom}";

const modes = [
  "scaleToFill",
  "aspectFit",
  "aspectFill",
  "top",
  "bottom",
  "left",
  "center",
  "right",
  "topLeft",
  "topRight",
  "bottomLeft",
  "bottomRight"
];
const WxImage = class {
  constructor(hostRef) {
    registerInstance(this, hostRef);
    this.mode = "aspectFill";
  }
  render() {
    const classList = modes.reduce(
      (p, c) => ((p[c] = same(this.mode, c)), p),
      {}
    );
    return h(
      Host,
      null,
      h("img", {
        class: Object.assign({ image: true }, classList),
        src: this.src
      })
    );
  }
  handlerTouchstart(event) {
    this.touchStartInfo = { target: event.target, time: Date.now() };
    if (this.catchTouchstart) {
      event.stopPropagation();
      eventToNative(this.catchTouchstart, createEvent(event));
    }
    if (this.bindTouchstart) {
      eventToNative(this.bindTouchstart, createEvent(event));
    }
  }
  handlerTouchmove(event) {
    if (this.catchTouchmove) {
      event.stopPropagation();
      eventToNative(this.catchTouchmove, createEvent(event));
    }
    if (this.bindTouchmove) {
      eventToNative(this.bindTouchmove, createEvent(event));
    }
  }
  handlerTouchcancel(event) {
    if (this.catchTouchcancel) {
      event.stopPropagation();
      eventToNative(this.catchTouchcancel, createEvent(event));
    }
    if (this.bindTouchcancel) {
      eventToNative(this.bindTouchcancel, createEvent(event));
    }
  }
  handlerTouchend(event) {
    var _a;
    if (this.catchTouchend) {
      event.stopPropagation();
      eventToNative(this.catchTouchend, createEvent(event));
    }
    if (this.bindTouchend) {
      eventToNative(this.bindTouchend, createEvent(event));
    }
    const startInfo =
      (_a = this.touchStartInfo) !== null && _a !== void 0
        ? _a
        : { target: null, time: 0 };
    const isLongTap =
      startInfo.target === event.target && Date.now() > startInfo.time + 350;
    if (isLongTap) {
      if (this.catchLongpress) {
        event.stopPropagation();
        eventToNative(this.catchLongpress, createEvent(event));
      }
      if (this.bindLongpress) {
        event.stopPropagation();
        eventToNative(this.bindLongpress, createEvent(event));
      }
    }
  }
  handlerTap(event) {
    if (this.catchtap) {
      event.stopPropagation();
      eventToNative(this.catchtap, createEvent(event));
    }
    if (this.bindtap) {
      eventToNative(this.bindtap, createEvent(event));
    }
  }
};
WxImage.style = wxImageCss;

export { WxImage as wx_image };
