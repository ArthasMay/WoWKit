/*
 * @Author: ArthasMay
 * @Date: 2020-11-19 10:24:46
 * @LastEditTime: 2020-11-19 17:25:27
 * @LastEditors: Please set LastEditors
 * @Description: In User Settings Edit
 * @FilePath: /WoWMiniProgramScaffold/packages/compiler/compiler-mp-template/compiler-javascript.js
 */
const reg = /\{\{([.|\w|\d]+?)\}\}/g;

/**
 * pre script
 * 在 Vue 中会获取该 __DATA__ 作为响应对象
 */
const prefixScript = `
window.__DATA__ = {}
window.__Def = function (key, value) {
  if (typeof window.__DATA__[key] === 'object') {
    window.__DATA__[key] = {...window.__DATA__[key], ...value}
  }
  window.__DATA__[key] = value
};
`;

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

module.exports = {
  compilerJavaScript: function(wxmlContent) {
    let script = prefixScript;
    while(true) {
      const result = reg.exec(wxmlContent);
      if (!result) break;
      const [key, value] = recombineObject(result[1]);
      script += `__Def(${JSON.stringify(key)}, ${JSON.stringify(value)});`;
    }
    return script;
  },
};

