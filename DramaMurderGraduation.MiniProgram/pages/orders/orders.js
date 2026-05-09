const api = require('../../utils/api');

Page({
  data: {
    loggedIn: true,
    orders: []
  },

  onShow() {
    this.load();
  },

  async load() {
    try {
      this.setData({ orders: await api.get('reservations'), loggedIn: true });
    } catch (err) {
      this.setData({ loggedIn: false, orders: [] });
    }
  },

  async confirm(event) {
    try {
      await api.post('confirmreservation', { reservationId: event.currentTarget.dataset.id });
      wx.showToast({ title: '已确认' });
      this.load();
    } catch (err) {
      wx.showToast({ title: err.message, icon: 'none' });
    }
  },

  goProfile() {
    wx.switchTab({ url: '/pages/profile/profile' });
  }
});
