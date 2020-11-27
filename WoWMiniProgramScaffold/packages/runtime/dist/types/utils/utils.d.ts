export declare function format(first: string, middle: string, last: string): string;
export declare type TouchTargetEvent = {
  target: HTMLElement;
} & TouchEvent;
export declare function same<T>(props: T, value: any): value is T;
export declare const enum InvokeNativeType {
  log = 0,
  lifeCycle = 1,
  event = 2
}
export declare function invokeNative(type: InvokeNativeType, payload: any): void;
export declare function log(...messages: any): void;
export declare function eventToNative(bindFunctionName: any, payload: any): void;
export declare function getTouchs(touchs: TouchList): {
  clientX: number;
  clientY: number;
  force: number;
  identifier: number;
  pageX: number;
  pageY: number;
}[];
export declare function createEvent(event: TouchTargetEvent): {
  type: string;
  timeStamp: number;
  detail: {
    x: number;
    y: number;
  };
  target: {
    offsetLeft: number;
    offsetTop: number;
    dataset: {
      [x: string]: string;
    };
  };
  currentTarget: {
    offsetLeft: number;
    offsetTop: number;
    dataset: {
      [x: string]: string;
    };
  };
  changedTouches: {
    clientX: number;
    clientY: number;
    force: number;
    identifier: number;
    pageX: number;
    pageY: number;
  }[];
  touches: {
    clientX: number;
    clientY: number;
    force: number;
    identifier: number;
    pageX: number;
    pageY: number;
  }[];
  _requireActive: boolean;
};
