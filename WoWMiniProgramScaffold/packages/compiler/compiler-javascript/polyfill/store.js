/*
 * @Author: Arthas
 * @Date: 2020-11-26 16:42:55
 * @LastEditTime: 2020-11-26 16:46:15
 * @LastEditors: Arthas
 * @Description:
 * @FilePath: /WoWMiniProgramScaffold/packages/compiler/compiler-javascript/polyfill/store.js
 */
const store = {
  /**
   * 这两个属性用 rollup 注入
   */
  appConfig: __APPCONFIG__,

  projectConfig: __PROJECTCONFIG__,

  app: {},

  pages: {},

  routeStacks: [],

  currentWebviewId: ""
};

/**
 * export
 */

export const createApp = app => {
  store.app = app;
};

export const createPage = (page, instance) => {
  store.pages[page] = instance;
};

export const getApp = () => store.app;

export const getPage = pageId => store.pages[pageId];

export const getPages = () => store.pages;

export const getCurrentRouter = () =>
  store.routeStacks[store.routeStacks.length - 1];

export const pushRouter = pageController => {
  store.currentWebviewId = pageController.webviewId;
  store.routeStacks.push(pageController);
};

export const popRouter = () => {
  store.routeStacks.pop();
  store.currentWebviewId = getCurrentRouter()?.webviewId;
};

export const getRouteStacks = () => store.routeStacks;

export const getRouteByWebviewId = webviewId =>
  store.routeStacks.filter(
    pageController => Number(pageController.webviewId) === Number(webviewId)
  )[0];

export const getCurrentWebviewId = () => store.currentWebviewId;

export const getAppConfig = () => store.appConfig;

export const getProjectConfig = () => store.projectConfig;
