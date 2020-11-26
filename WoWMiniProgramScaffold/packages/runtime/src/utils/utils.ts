/*
 * @Author: Arthas
 * @Date: 2020-11-24 17:33:05
 * @LastEditTime: 2020-11-24 18:09:18
 * @LastEditors: Arthas
 * @Description:
 * @FilePath: /WoWMiniProgramScaffold/packages/runtime/src/utils/utils.ts
 */

export function format(first: string, middle: string, last: string): string {
  return (first || "") + (middle ? `${middle}` : "") + (last ? `${last}` : "");
}

export type TouchTargetEvent = { target: HTMLElement } & TouchEvent;

export function same<T>(props: T, value: any): value is T {
  return props === value;
}

export const enum InvokeNativeType {
  log = 0,
  lifeCycle = 1,
  event = 2
}

export function invokeNative(type: InvokeNativeType, payload: any) {
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

export function log(...messages: any) {
  invokeNative(InvokeNativeType.log, messages);
  if (typeof console !== "undefined") {
    console.log(...messages);
  }
}

export function eventToNative(bindFunctionName, payload) {
  invokeNative(InvokeNativeType.event, {
    method: bindFunctionName,
    payload
  });
}

export function getTouchs(touchs: TouchList) {
  return Array.from(touchs ?? []).map(item => ({
    clientX: item.clientX,
    clientY: item.clientY,
    force: item.force,
    identifier: item.identifier,
    pageX: item.pageX,
    pageY: item.pageY
  }));
}

export function createEvent(event: TouchTargetEvent) {
  const touches = getTouchs(event.touches);
  const changedTouches = getTouchs(event.changedTouches);

  const target = {
    offsetLeft: event.target?.offsetLeft,
    offsetTop: event.target?.offsetTop,
    dataset: { ...event.target?.dataset }
  };

  return {
    type: event.type,
    timeStamp: Date.now(),
    detail: {
      x: touches[0]?.pageX,
      y: touches[0]?.pageY
    },
    target,
    currentTarget: target,
    changedTouches,
    touches,
    _requireActive: true
  };
}
