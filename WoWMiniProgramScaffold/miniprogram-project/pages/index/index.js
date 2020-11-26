//index.js
//获取应用实例
const app = getApp()

Page({
  data: {
    motto: '秋季赛战胜湘北',
    userInfo: {
      nickName: '藤真健司',
      avatarUrl: 'http://cdnimg103.lizhi.fm/audio_cover/2016/03/09/26984744269887751_320x320.jpg'
    },
    count: 0,
    desc: '藤真健司是日本著名动画、漫画《灌篮高手》中的人物，翔阳高中的教练兼球员，与海南的牧绅一并称为神奈川双雄。\n藤真外表秀美温和，内心倔强刚烈强硬淡漠。蜜发棕眸，清秀的面容，拥有一大堆疯狂的女球迷。他一般不首先出场比赛，而是在休息区履行教练的职责，冷酷而睿智。一旦局面不利于翔阳，他就会上场，翔阳也会因为他的加入从一支普通的强队变成全国大赛的常胜队伍'
  },
  //事件处理函数
  bindViewTap: function() {
    // TODO: 微信小程序需要改成: ../logs/logs
    wx.navigateTo({
      url: '/logs/logs'
    })
  },
  
  onLoad: function () {
    this.setData({ count: 20 })
  },

  add: function(e) {
    this.setData({ count: this.data.count + 1 })
  },

  reduce: function() {
    this.setData({ count: this.data.count - 1 })
  }
})
