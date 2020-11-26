import { r as registerInstance, h, e as Host } from "./index-86fbaafa.js";

const wxInputCss = ":host{display:block}";

const WxInput = class {
  constructor(hostRef) {
    registerInstance(this, hostRef);
  }
  render() {
    return h(Host, null, h("input", { value: this.value }));
  }
};
WxInput.style = wxInputCss;

export { WxInput as wx_input };
