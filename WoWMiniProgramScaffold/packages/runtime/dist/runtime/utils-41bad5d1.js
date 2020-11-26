/*
 * @Author: Arthas
 * @Date: 2020-11-24 17:33:05
 * @LastEditTime: 2020-11-24 18:09:18
 * @LastEditors: Arthas
 * @Description:
 * @FilePath: /WoWMiniProgramScaffold/packages/runtime/src/utils/utils.ts
 */
function format(first, middle, last) {
  return (first || "") + (middle ? `${middle}` : "") + (last ? `${last}` : "");
}
function same(props, value) {
  return props === value;
}
function invokeNative(type, payload) {
  let webkit = Reflect.get(window, "webkit");
  if (!webkit) {
    return;
  }
  webkit.messageHandlers.trigger.postMessage(
    JSON.stringify({
      type,
      payload
    })
  );
}
function log(...messages) {
  invokeNative(0 /* log */, messages);
  if (typeof console !== "undefined") {
    console.log(...messages);
  }
}
function eventToNative(bindFunctionName, payload) {
  invokeNative(2 /* event */, {
    method: bindFunctionName,
    payload
  });
}
function getTouchs(touchs) {
  return Array.from(touchs !== null && touchs !== void 0 ? touchs : []).map(
    item => ({
      clientX: item.clientX,
      clientY: item.clientY,
      force: item.force,
      identifier: item.identifier,
      pageX: item.pageX,
      pageY: item.pageY
    })
  );
}
function createEvent(event) {
  var _a, _b, _c, _d, _e;
  const touches = getTouchs(event.touches);
  const changedTouches = getTouchs(event.changedTouches);
  const target = {
    offsetLeft:
      (_a = event.target) === null || _a === void 0 ? void 0 : _a.offsetLeft,
    offsetTop:
      (_b = event.target) === null || _b === void 0 ? void 0 : _b.offsetTop,
    dataset: Object.assign(
      {},
      (_c = event.target) === null || _c === void 0 ? void 0 : _c.dataset
    )
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

export {
  createEvent as c,
  eventToNative as e,
  format as f,
  invokeNative as i,
  log as l,
  same as s
};
