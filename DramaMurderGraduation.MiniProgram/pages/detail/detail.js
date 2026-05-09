const api = require('../../utils/api');

Page({
  data: {
    script: {},
    characters: [],
    sessions: []
  },

  onLoad(query) {
    this.scriptId = query.id;
    this.load();
  },

  async load() {
    try {
      const data = await api.get('scriptdetail', { id: this.scriptId });
      this.setData({
        script: data.script || {},
        characters: data.characters || [],
        sessions: data.sessions || []
      });
    } catch (err) {
      wx.showToast({ title: err.message, icon: 'none' });
    }
  },

  book() {
    wx.navigateTo({ url: `/pages/booking/booking?scriptId=${this.data.script.Id}` });
  },

  bookSession(event) {
    wx.navigateTo({ url: `/pages/booking/booking?sessionId=${event.currentTarget.dataset.id}` });
  }
});
