const app = getApp();
const api = require('../../utils/api');

Page({
  data: {
    apiBase: '',
    user: null,
    userInitial: '我',
    login: {
      username: '',
      password: ''
    }
  },

  onShow() {
    this.setData({ apiBase: wx.getStorageSync('apiBase') || app.globalData.apiBase });
    this.loadMe();
  },

  async loadMe() {
    try {
      const data = await api.get('me');
      const user = data.loggedIn ? data.user : null;
      this.setData({ user, userInitial: this.getInitial(user) });
    } catch (err) {
      this.setData({ user: null, userInitial: '我' });
    }
  },

  loginInput(event) {
    this.setData({ [`login.${event.currentTarget.dataset.field}`]: event.detail.value });
  },

  async doLogin() {
    try {
      const user = await api.post('login', this.data.login);
      app.globalData.user = user;
      this.setData({ user, userInitial: this.getInitial(user) });
      wx.showToast({ title: '登录成功' });
    } catch (err) {
      wx.showToast({ title: err.message, icon: 'none' });
    }
  },

  setApiBase(event) {
    this.setData({ apiBase: event.detail.value });
  },

  getInitial(user) {
    const name = user && (user.DisplayName || user.Username);
    return name ? name.substring(0, 1) : '我';
  },

  saveApiBase() {
    wx.setStorageSync('apiBase', this.data.apiBase);
    app.globalData.apiBase = this.data.apiBase;
    wx.showToast({ title: '已保存' });
  },

  async logout() {
    await api.post('logout');
    wx.removeStorageSync('cookie');
    this.setData({ user: null, userInitial: '我' });
  }
});
