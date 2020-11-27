import { r as registerInstance, h, e as Host } from './index-86fbaafa.js';

const baseComponentCss = ":host{display:block}";

/**
 * 将事件发送给原生
 * @param bindFunctionName
 * @param data
 */
function eventToNative(bindFunctionName, payload) {
  const webkit = Reflect.get(window, "webkit");
  webkit.messageHandlers.triggerEvent.postMessage(JSON.stringify({
    method: bindFunctionName,
    payload
  }));
}
function getTouchs(touchs) {
  return Array.from(touchs !== null && touchs !== void 0 ? touchs : []).map(item => ({
    clientX: item.clientX,
    clientY: item.clientY,
    force: item.force,
    identifier: item.identifier,
    pageX: item.pageX,
    pageY: item.pageY
  }));
}
/**
 * 同步小程序事件参数
 * @param event
 */
function createEvent(event) {
  var _a, _b, _c, _d, _e;
  const touches = getTouchs(event.touches);
  const changedTouches = getTouchs(event.changedTouches);
  const target = {
    offsetLeft: (_a = event.target) === null || _a === void 0 ? void 0 : _a.offsetLeft,
    offsetTop: (_b = event.target) === null || _b === void 0 ? void 0 : _b.offsetTop,
    dataset: Object.assign({}, (_c = event.target) === null || _c === void 0 ? void 0 : _c.dataset)
  };
  return {
    type: event.type,
    timeStamp: Date.now(),
    detail: {
      x: (_d = touches[0]) === null || _d === void 0 ? void 0 : _d.pageX,
      y: (_e = touches[0]) === null || _e === void 0 ? void 0 : _e.pageY
    },
    target,
    currentTarget: target,
    changedTouches,
    touches,
    _requireActive: true
  };
}
const BaseComponent = class {
  constructor(hostRef) {
    registerInstance(this, hostRef);
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
    const startInfo = (_a = this.touchStartInfo) !== null && _a !== void 0 ? _a : { target: null, time: 0 };
    const isLongTap = startInfo.target === event.target && Date.now() > startInfo.time + 350;
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
    console.log("BaseComponent -> handlerTap -> event", event);
    if (this.catchTap) {
      event.stopPropagation();
      eventToNative(this.catchTap, createEvent(event));
    }
    if (this.bindTap) {
      eventToNative(this.bindTap, createEvent(event));
    }
  }
  render() {
    return (h(Host, null, h("slot", null)));
  }
};
BaseComponent.style = baseComponentCss;

export { BaseComponent as base_component };
