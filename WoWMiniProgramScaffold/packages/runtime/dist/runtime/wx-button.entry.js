import { r as registerInstance, h, e as Host } from "./index-86fbaafa.js";
import {
  s as same,
  e as eventToNative,
  c as createEvent
} from "./utils-41bad5d1.js";

const wxButtonCss =
  ':host{position:relative;display:block;margin-left:auto;margin-right:auto;box-sizing:border-box;text-align:center;text-decoration:none;overflow:hidden;-webkit-tap-highlight-color:transparent;user-select:none;cursor:pointer}:host::after{content:" ";width:200%;height:200%;position:absolute;top:0;left:0;border:0.02rem solid rgba(0, 0, 0, 0.2);-webkit-transform:scale(0.5);transform:scale(0.5);-webkit-transform-origin:0 0;transform-origin:0 0;box-sizing:border-box;border-radius:0.2rem}:host(.size-default){width:100%;height:0.94rem;line-height:0.94rem;border-radius:0.1rem;font-size:0.36rem}:host(.size-mini){display:inline-block;min-width:1.2rem;height:0.6rem;line-height:0.6rem;padding:0 0.3rem;font-size:0.28rem;text-align:center;border-radius:0.06rem}:host(.type-default){background-color:#F8F8F8;color:rgba(0,0,0, 1)}:host(.type-default.button-hover){background-color:#DEDEDE;color:rgba(0,0,0, 1)}:host(.type-default.button-disabled){background-color:#F7F7F7;color:rgba(0,0,0, 0.3)}:host(.type-primary){background-color:#1AAD19;color:rgba(255,255,255, 1)}:host(.type-primary.button-hover){background-color:#179B16;color:rgba(255,255,255, 1)}:host(.type-primary.button-disabled){background-color:#9ED99D;color:rgba(255,255,255, 0.3)}:host(.type-warn){background-color:#E64340;color:rgba(255,255,255, 1)}:host(.type-warn.button-hover){background-color:#CE3C39;color:rgba(255,255,255, 1)}:host(.type-warn.button-disabled){background-color:#EC8B89;color:rgba(255,255,255, 0.3)}';

const WxButton = class {
  constructor(hostRef) {
    registerInstance(this, hostRef);
    this.hoved = false;
    /**
     * 按钮的大小
     */
    this.size = "default";
    /**
     * 按钮的样式类型
     */
    this.type = "default";
    /**
     * 按钮是否镂空，背景色透明
     */
    this.plain = false;
    /**
     * 是否禁用
     */
    this.disabled = false;
    /**
     * 名称前是否带 loading 图标
     */
    this.loading = false;
  }
  render() {
    return h(
      Host,
      {
        class: {
          "size-default": same(this.size, "default"),
          "size-mini": same(this.size, "mini"),
          "type-default": same(this.type, "default"),
          "type-primary": same(this.type, "primary"),
          "type-warn": same(this.type, "warn"),
          "button-plain": this.plain,
          "button-disabled": this.disabled,
          "button-hover": this.hoved
        }
      },
      h("slot", null)
    );
  }
  handlerTouchstart(event) {
    if (this.disabled) return;
    this.hoved = true;
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
    if (this.disabled) return;
    if (this.catchTouchmove) {
      event.stopPropagation();
      eventToNative(this.catchTouchmove, createEvent(event));
    }
    if (this.bindTouchmove) {
      eventToNative(this.bindTouchmove, createEvent(event));
    }
  }
  handlerTouchcancel(event) {
    if (this.disabled) return;
    this.hoved = false;
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
    if (this.disabled) return;
    this.hoved = false;
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
  // XXX: 点击太快会有一次触发丢失
  handlerTap(event) {
    if (this.disabled) return;
    if (this.catchtap) {
      event.stopPropagation();
      eventToNative(this.catchtap, createEvent(event));
    }
    if (this.bindtap) {
      eventToNative(this.bindtap, createEvent(event));
    }
  }
};
WxButton.style = wxButtonCss;

export { WxButton as wx_button };
