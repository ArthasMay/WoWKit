/*
 * @Author: your name
 * @Date: 2020-11-18 18:03:37
 * @LastEditTime: 2020-11-19 15:33:25
 * @LastEditors: your name
 * @Description: In User Settings Edit
 * @FilePath: /WoWMiniProgramScaffold/packages/compiler/compiler-mp-template/index.js
 */
const path = require("path")
const fs = require("fs")

const template = {
    head: `
    <!DOCTYPE html>
    <html lang="en" style="font-size: __FONT_SIZE__px">
    <head>
        <meta charset="UTF-8">
        <meta name="viewport" content="width=device-width,user-scalable=no,initial-scale=__SCALE__,maximum-scale=__SCALE__,minimum-scale=__SCALE__">
        <meta http-equiv="X-UA-Compatible" content="ie-edge">
    `,
    body: `
    </head>
    <body>
        <div id="app">
    `,
    foot: `
        </div>
    </body>
    <script type="text/javascript">
    `,
    tail: `
    </script>
    </html>
    `,
};

exports.compileHtml = function(entryDir, appConfig, projectConfig) {
    if (!appConfig.pages || !appConfig.pages.length) {
        throw new Error("No pages found!")
    }

    
}