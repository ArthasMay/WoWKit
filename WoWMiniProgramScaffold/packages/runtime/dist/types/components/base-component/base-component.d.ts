declare type TouchTargetEvent = {
  target: HTMLElement;
} & TouchEvent;
export declare class BaseComponent {
  touchStartInfo: null | {
    target: HTMLElement;
    time: number;
  };
  bindTouchstart: string;
  bindTouchmove: string;
  bindTouchcancel: string;
  bindTouchend: string;
  bindTap: string;
  bindLongpress: string;
  bindLongtap: string;
  catchTouchstart: string;
  catchTouchmove: string;
  catchTouchcancel: string;
  catchTouchend: string;
  catchTap: string;
  catchLongpress: string;
  catchLongtap: string;
  handlerTouchstart(event: TouchTargetEvent): void;
  handlerTouchmove(event: TouchTargetEvent): void;
  handlerTouchcancel(event: TouchTargetEvent): void;
  handlerTouchend(event: TouchTargetEvent): void;
  handlerTap(event: TouchTargetEvent): void;
  render(): any;
}
export {};
