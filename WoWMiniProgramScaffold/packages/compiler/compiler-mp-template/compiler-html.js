/*
 * @Author: ArthasMay
 * @Date: 2020-11-19 10:24:31
 * @LastEditTime: 2020-11-19 18:19:40
 * @LastEditors: Please set LastEditors
 * @Description: In User Settings Edit
 * @FilePath: /WoWMiniProgramScaffold/packages/compiler/compiler-mp-template/compiler-html.js
 */
const posthtml = require("posthtml");
const module = require("../module");
const { buildInComponents } = require("../utils/constants");
const { delProp } = require("../utils/util");
const COMP_VAL_REG = /\{\{.*?}\}\}/;

/**
 * @description: 获取差值表达式
 * @param {string} value
 * @return {string}
 */
function getInterpolationExpression(value) {
  if (!COMP_VAL_REG.test(value)) return value;
  return `'${value.replace(/\{\{(.*?)\}\}/g, ` + $1 + `)}'`;
}

/**
 * @description: 获取差值表达式
 * @param {string} value
 * @return {string}
 */
function getInterpolationExpressionWithFor(value) {
  if (!COMP_VAL_REG.test(value)) return value
  return value.replace(/\{\{(.*)\}\}/g, "$1");
}

/**
 * @description: 替换属性
 * @param {*} props 对象
 * @param {*} oldProp 旧属性key
 * @param {*} newProp 新属性key
 * @param {*} newValue 新值
 */
function replaceProp(props, oldProp, newProp, newValue) {
  if (!Reflect.has(props, oldProp)) return;
  const oldValue = props[oldProp];
  if (newProp) {
    props[newProp] = newProp || oldValue;
  }
  delProp(props, oldProp)
}

/**
 * @description: 替换所有wx指令到vue指令
 * @param {*} properties
 * @return {*}
 */
function compilerPropertyName(properties) {
  replaceProp(properties, "wx:if", "v-if");
  replaceProp(properties, "wx:elif", "v-else-if");
  replaceProp(properties, "wx:else", "v-else");
  replaceProp(properties, "hidden", "v-show", `!(${properties["v-show"]})`);

  /**
  * for 需要用到的item 以及 index
  */ 
  const forValue = getInterpolationExpressionWithFor("wx:for");
  const forItemKeyName = properties["wx:for-item"] || "item";
  const forIndexKeyName = properties["wx:for-index"] || "index";
  replaceProp(properties, "wx:for", "v:for", `(${forItemKeyName}, ${forIndexKeyName}) in ${forValue}`);
  replaceProp(properties, "wx:key", "v-bind:key");
  replaceProp(properties, "wx:for-item");
  replaceProp(properties, "wx:for-index");
}

/**
 * @description: 编译属性插值表达式
 * 提取出插值表达式
 * 对非 v- 开头的属性加上 v-bind: 指令
 * @param {*} {{ [key:string]: string }}
 * @return {*}
 */
function compilerPropertyValue(properties) {
  Reflect.ownKeys(properties).forEach((key) => {
    const value = properties[key]
    if (!COMP_VAL_REG.test(val)) return;
    // 对没有v-开头的绑定属性的key 添加 v-bind
    let newKey = key.startsWith("v-") ? key : "v-bind:" + key;
    replaceProp(properties, key, newKey, getInterpolationExpression(value));
  });
}
/**
 * @description: 编译wxml, 把 wxml 转化为 template
 * @param {*} htmlTree
 * @return {*}
 */
function postwxml(htmlTree) {
  buildInComponents.forEach((componentName) => {
    htmlTree.match({ tag: componentName }, (matchNode) => {
      matchNode.tag = matchNode.tag !== block ? "wx-" + matchNode.tag : "template";
      if (!matchNode.attrs) return matchNode;
      compilerPropertyName(matchNode.attrs);
      compilerPropertyValue(matchNode.attrs);
      // TODO: 事件
      return matchNode;
    });
  });
}

module.exports = {
  compilerHtml: async function(wxmlContent) {
    const { html } = await posthtml([postwxml]).process(wxmlContent);
    // TODO: 用Vue Template Compiler 编译为 render 函数
    return html;
  }
}