const api = require('../../utils/api');
const format = require('../../utils/format');
const demo = require('../../utils/demo');

Page({
  data: {
    loading: true,
    script: {},
    characters: [],
    sessions: [],
    reviews: [],
    assets: []
  },

  onLoad(query) {
    this.scriptId = query.id;
    this.load();
  },

  async load() {
    this.setData({ loading: true });
    if (String(this.scriptId).indexOf('demo-') === 0) {
      const script = demo.getScript(this.scriptId);
      this.setData({
        script: this.mapScript(script || {}),
        characters: script ? script.Characters : [],
        sessions: demo.sessions(this.scriptId).map(this.mapSession),
        reviews: [
          { Id: 'r1', ReviewerName: '体验玩家', Rating: 5, Content: '节奏紧凑，适合毕业设计演示完整预约流程。' }
        ],
        assets: [],
        loading: false
      });
      return;
    }

    try {
      const data = await api.get('scriptdetail', { id: this.scriptId });
      this.setData({
        script: this.mapScript(data.script || {}),
        characters: data.characters || [],
        sessions: (data.sessions || []).map(this.mapSession),
        reviews: data.reviews || [],
        assets: (data.assets || []).map(item => ({ ...item, Url: format.imageUrl(item.AssetUrl || item.Url) }))
      });
    } catch (err) {
      const script = demo.getScript(this.scriptId);
      if (script) {
        this.setData({
          script: this.mapScript(script),
          characters: script.Characters || [],
          sessions: demo.sessions(this.scriptId).map(this.mapSession),
          reviews: [],
          assets: []
        });
      } else {
        wx.showToast({ title: err.message, icon: 'none' });
      }
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
      Disabled: Number(item.RemainingSeats || 0) <= 0
    };
  },

  book() {
    wx.navigateTo({ url: `/pages/booking/booking?scriptId=${this.data.script.Id}` });
  },

  bookSession(event) {
    wx.navigateTo({ url: `/pages/booking/booking?sessionId=${event.currentTarget.dataset.id}` });
  }
});
