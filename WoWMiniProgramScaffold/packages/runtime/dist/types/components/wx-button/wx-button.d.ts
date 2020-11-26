import { ComponentInterface } from "../../stencil-public-runtime";
import { TouchTargetEvent } from "../../utils/utils";
export declare class WxButton implements ComponentInterface {
  hoved: boolean;
  /**
   * 按钮的大小
   */
  size: "default" | "mini";
  /**
   * 按钮的样式类型
   */
  type: "default" | "primary" | "warn";
  /**
   * 按钮是否镂空，背景色透明
   */
  plain: boolean;
  /**
   * 是否禁用
   */
  disabled: boolean;
  /**
   * 名称前是否带 loading 图标
   */
  loading: boolean;
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
