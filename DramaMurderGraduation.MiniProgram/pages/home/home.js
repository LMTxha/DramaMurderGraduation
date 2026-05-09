const api = require('../../utils/api');
const format = require('../../utils/format');
const demo = require('../../utils/demo');

Page({
  data: {
    loading: true,
    settings: {},
    metrics: {},
    announcements: [],
    featuredScripts: [],
    sessions: [],
    recommendations: []
  },

  onLoad() {
    this.load();
  },

  onPullDownRefresh() {
    this.load().finally(() => wx.stopPullDownRefresh());
  },

  async load() {
    this.setData({ loading: true });
    try {
      const data = await api.get('home');
      const recommendations = await api.get('recommendations').catch(() => []);
      const featuredScripts = data.featuredScripts && data.featuredScripts.length ? data.featuredScripts : demo.listScripts();
      const sessions = data.sessions && data.sessions.length ? data.sessions : demo.sessions();
      this.setData({
        settings: data.settings || {},
        metrics: data.metrics || {},
        announcements: data.announcements || [],
        featuredScripts: featuredScripts.map(this.mapScript),
        sessions: sessions.map(this.mapSession),
        recommendations: recommendations || []
      });
    } catch (err) {
      this.setData({
        settings: { SiteName: '雾城剧本研究所' },
        metrics: { ScriptCount: demo.listScripts().length, RoomCount: 2, AverageRating: 4.8 },
        announcements: [{ Id: 'demo-notice', Title: '演示数据已启用', Content: '当前没有读取到后端剧本，已自动启用小程序演示数据。' }],
        featuredScripts: demo.listScripts().map(this.mapScript),
        sessions: demo.sessions().map(this.mapSession),
        recommendations: []
      });
    } finally {
      this.setData({ loading: false });
    }
  },

  mapScript(item) {
    return {
      ...item,
      CoverUrl: format.imageUrl(item.CoverImage),
      PriceText: format.money(item.Price),
      RatingText: format.text(item.AverageRating, '暂无')
    };
  },

  mapSession(item) {
    return {
      ...item,
      TimeText: format.formatDateTime(item.SessionDateTime),
      SeatText: `余${item.RemainingSeats || 0}席`
    };
  },

  goScripts() {
    wx.switchTab({ url: '/pages/scripts/scripts' });
  },

  goOrders() {
    wx.switchTab({ url: '/pages/orders/orders' });
  },

  openDetail(event) {
    wx.navigateTo({ url: `/pages/detail/detail?id=${event.currentTarget.dataset.id}` });
  },

  bookSession(event) {
    wx.navigateTo({ url: `/pages/booking/booking?sessionId=${event.currentTarget.dataset.id}` });
  }
});
