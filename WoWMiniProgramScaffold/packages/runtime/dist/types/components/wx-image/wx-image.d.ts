import { ComponentInterface } from "../../stencil-public-runtime";
import { TouchTargetEvent } from "../../utils/utils";
export declare class WxImage implements ComponentInterface {
  src: string;
  mode:
    | "scaleToFill"
    | "aspectFit"
    | "aspectFill"
    | "top"
    | "bottom"
    | "left"
    | "center"
    | "right"
    | "topLeft"
    | "topRight"
    | "bottomLeft"
    | "bottomRight";
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
  bindtap: string;
  bindLongpress: string;
  bindLongtap: string;
  catchTouchstart: string;
  catchTouchmove: string;
  catchTouchcancel: string;
  catchTouchend: string;
  catchtap: string;
  catchLongpress: string;
  catchLongtap: string;
  handlerTouchstart(event: TouchTargetEvent): void;
  handlerTouchmove(event: TouchTargetEvent): void;
  handlerTouchcancel(event: TouchTargetEvent): void;
  handlerTouchend(event: TouchTargetEvent): void;
  handlerTap(event: TouchTargetEvent): void;
}
