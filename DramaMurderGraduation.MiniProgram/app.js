App({
  globalData: {
    apiBase: 'http://localhost:5090/MiniApi.aspx',
    user: null
  },

  onLaunch() {
    const apiBase = wx.getStorageSync('apiBase');
    if (apiBase) {
      this.globalData.apiBase = apiBase;
    }
  }
});
