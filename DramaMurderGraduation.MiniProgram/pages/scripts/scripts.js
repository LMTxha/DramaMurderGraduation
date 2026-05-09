const api = require('../../utils/api');
const format = require('../../utils/format');
const demo = require('../../utils/demo');

Page({
  data: {
    loading: true,
    keyword: '',
    genreId: '',
    genres: [],
    scripts: []
  },

  onLoad() {
    this.load();
  },

  onPullDownRefresh() {
    this.loadScripts().finally(() => wx.stopPullDownRefresh());
  },

  async load() {
    await Promise.all([this.loadGenres(), this.loadScripts()]);
  },

  async loadGenres() {
    try {
      const genres = await api.get('genres');
      this.setData({ genres: genres && genres.length ? genres : demo.genres });
    } catch (err) {
      this.setData({ genres: demo.genres });
    }
  },

  async loadScripts() {
    this.setData({ loading: true });
    try {
      const scripts = await api.get('scripts', {
        keyword: this.data.keyword,
        genreId: this.data.genreId
      });
      const list = scripts && scripts.length ? scripts : demo.listScripts(this.data.keyword, this.data.genreId);
      this.setData({ scripts: list.map(this.mapScript) });
    } catch (err) {
      this.setData({ scripts: demo.listScripts(this.data.keyword, this.data.genreId).map(this.mapScript) });
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

  onKeyword(event) {
    this.setData({ keyword: event.detail.value });
  },

  search() {
    this.loadScripts();
  },

  pickGenre(event) {
    this.setData({ genreId: event.currentTarget.dataset.id || '' });
    this.loadScripts();
  },

  openDetail(event) {
    wx.navigateTo({ url: `/pages/detail/detail?id=${event.currentTarget.dataset.id}` });
  }
});
