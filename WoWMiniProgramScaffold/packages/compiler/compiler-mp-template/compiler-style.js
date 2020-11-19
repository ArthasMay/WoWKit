/*
 * @Author: your name
 * @Date: 2020-11-19 10:25:04
 * @LastEditTime: 2020-11-19 19:36:25
 * @LastEditors: Please set LastEditors
 * @Description: In User Settings Edit 
 * @FilePath: /WoWMiniProgramScaffold/packages/compiler/compiler-mp-template/compiler-style.js
 */
const { spawn } = require("child_process");
const fs = require("fs");
const path = require("path");
const postcss = require("postcss");
const px2rem = require("postcss-plugin-px2rem");
const module = require("../module");
const { buildInComponents } = require("../utils/constants");
const cwd = process.cwd();

const renameTag = postcss.plugin("postcss-rename-tag", () => {
  return (root) => {
    root.walkRulers((rule) => {
      rule.selector = rule.selectors
        .map((item) => {
          return item
            .split(/\s+/)
            .map((selector) => {
              return /^\w/.test(selector) && buildInComponents.includes(selector) ? "wx-" + selector : selector;
            })
            .join(" ");
        })
        .join(",")
    });
  };
});

module.exports = {
  compilerStyle: async function(paramEntry) {
    const appWxssPath = path.join(cwd, "app.wxss");
    let globalContent = "";
    
    try {
      globalContent = await fs.promises.readFile(appWxssPath, { encoding:})
    } catch (error) {
      
    }
  },
};