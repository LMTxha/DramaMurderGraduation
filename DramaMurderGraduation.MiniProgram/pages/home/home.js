const api = require('../../utils/api');

Page({
  data: {
    settings: {},
    metrics: {},
    featuredScripts: [],
    sessions: []
  },

  onLoad() {
    this.load();
  },

  async load() {
    try {
      const data = await api.get('home');
      this.setData({
        settings: data.settings || {},
        metrics: data.metrics || {},
        featuredScripts: data.featuredScripts || [],
        sessions: (data.sessions || []).map(item => ({
          ...item,
          SessionDateTimeText: this.formatTime(item.SessionDateTime)
        }))
      });
    } catch (err) {
      wx.showToast({ title: err.message, icon: 'none' });
    }
  },

  formatTime(value) {
    if (!value) return '';
    const match = String(value).match(/\d+/);
    const date = match ? new Date(Number(match[0])) : new Date(value);
    const hour = date.getHours() < 10 ? `0${date.getHours()}` : `${date.getHours()}`;
    return `${date.getMonth() + 1}/${date.getDate()} ${hour}:00`;
  },

  goScripts() {
    wx.switchTab({ url: '/pages/scripts/scripts' });
  },

  openDetail(event) {
    wx.navigateTo({ url: `/pages/detail/detail?id=${event.currentTarget.dataset.id}` });
  }
});
