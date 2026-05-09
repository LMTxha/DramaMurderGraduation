const api = require('../../utils/api');

Page({
  data: {
    keyword: '',
    genreId: null,
    genres: [],
    scripts: []
  },

  onLoad() {
    this.loadGenres();
    this.loadScripts();
  },

  async loadGenres() {
    try {
      this.setData({ genres: await api.get('genres') });
    } catch (err) {
      wx.showToast({ title: err.message, icon: 'none' });
    }
  },

  async loadScripts() {
    try {
      const scripts = await api.get('scripts', { keyword: this.data.keyword, genreId: this.data.genreId || '' });
      this.setData({ scripts });
    } catch (err) {
      wx.showToast({ title: err.message, icon: 'none' });
    }
  },

  onKeyword(event) {
    this.setData({ keyword: event.detail.value });
  },

  pickGenre(event) {
    this.setData({ genreId: event.currentTarget.dataset.id });
    this.loadScripts();
  },

  clearGenre() {
    this.setData({ genreId: null });
    this.loadScripts();
  },

  openDetail(event) {
    wx.navigateTo({ url: `/pages/detail/detail?id=${event.currentTarget.dataset.id}` });
  }
});
