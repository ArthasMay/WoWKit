/*
 * @Author: your name
 * @Date: 2020-11-19 10:39:27
 * @LastEditTime: 2020-11-19 17:07:04
 * @LastEditors: Please set LastEditors
 * @Description: In User Settingscon
 * @FilePath: /WoWMiniProgramScaffold/packages/compiler/test.js
 */
const mod = require('./module')
console.log(mod.text)

let htmlTest = `
<view wx:for="{{array}}">
  {{index}}: {{item.message}}
</view>`;

let res = htmlTest.replace(/\{\{(.*?)\}\}/g, "$1");
console.log(res);

let current;
let root = (current = 2)
console.log(root)
console.log(current);

function recombineObject(interpolationExpression) {
  let current;
  let root = (current = {});
  const keys = interpolationExpression.split(".");
  const len = keys.length;
  for (let index = 0; index < len; index++) {
    const key = keys[index];
    current[key] = len === index + 1 ? "" : {}
    current = current[key];
  }
  return [keys[0], root[keys[0]]];
}

let result = recombineObject("data.user.name")
console.log(result)