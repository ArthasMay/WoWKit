import { ComponentInterface } from "../../stencil-public-runtime";
import { TouchTargetEvent } from "../../utils/utils";
export declare class WxText implements ComponentInterface {
  render(): any;
  /**
   * 通用事件
   */
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
}
