import { r as registerInstance, h, e as Host } from "./index-86fbaafa.js";
import { e as eventToNative, c as createEvent } from "./utils-41bad5d1.js";

const wxViewCss = ":host{display:block;font-size:0.28rem}";

const WxView = class {
  constructor(hostRef) {
    registerInstance(this, hostRef);
  }
  render() {
    return h(Host, null, h("slot", null));
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
    if (this.catchTap) {
      event.stopPropagation();
      eventToNative(this.catchTap, createEvent(event));
    }
    if (this.bindTap) {
      eventToNative(this.bindTap, createEvent(event));
    }
  }
};
WxView.style = wxViewCss;

export { WxView as wx_view };
