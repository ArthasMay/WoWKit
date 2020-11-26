/*
 * @Author: Arthas
 * @Date: 2020-11-24 16:54:03
 * @LastEditTime: 2020-11-24 19:52:01
 * @LastEditors: Arthas
 * @Description:
 * @FilePath: /WoWMiniProgramScaffold/packages/runtime/src/global/script.ts
 */

import Vue from "vue/dist/vue";
import { log, invokeNative, InvokeNativeType } from "../utils/utils";

export default function() {
  // 忽略 wx- 开头的组件
  Vue.config.ignoredElements.push(/^wx-/);

  console.log(Vue.config.ignoredElements);
  function def(target: any, key: string, value: any) {
    Reflect.set(target, key, value);
  }

  const vm = new Vue({
    el: document.getElementById("app"),
    data: Reflect.get(window, "__DATA__") || {}
  });

  def(window, "__setData", function(values: { [key: string]: any }) {
    log(values);
    Reflect.ownKeys(values).forEach((key: string) => {
      vm[key] = values[key];
    });
  });

  invokeNative(InvokeNativeType.lifeCycle, "ready");

  window.onerror = function(e) {
    document.write(`<h1>${String(e)}</h1><p>${(e as any).stack}</p>`);
  };
}
