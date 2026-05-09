const api = require('../../utils/api');
const format = require('../../utils/format');
const demo = require('../../utils/demo');

Page({
  data: {
    loading: true,
    loggedIn: false,
    sessions: [],
    sessionIndex: 0,
    form: {
      sessionId: 0,
      contactName: '',
      phone: '',
      playerCount: 1,
      remark: ''
    }
  },

  onLoad(query) {
    this.query = query || {};
    this.load();
  },

  async load() {
    this.setData({ loading: true });
    await this.loadMe();
    await this.loadSessions();
    this.setData({ loading: false });
  },

  async loadMe() {
    try {
      const data = await api.get('me');
      const user = data.loggedIn ? data.user : wx.getStorageSync('demoUser');
      this.setData({
        loggedIn: !!user,
        'form.contactName': user ? (user.DisplayName || user.Username || '') : '',
        'form.phone': user ? (user.Phone || '') : ''
      });
    } catch (err) {
      this.setData({ loggedIn: false });
    }
  },

  async loadSessions() {
    try {
      const raw = await api.get('sessions', { scriptId: this.query.scriptId || '' });
      const source = raw && raw.length ? raw : demo.sessions(this.query.scriptId || '');
      const sessions = source
        .filter(item => Number(item.RemainingSeats || 0) > 0)
        .map(item => ({
          ...item,
          TimeText: format.formatDateTime(item.SessionDateTime),
          Label: `${format.formatDateTime(item.SessionDateTime)} · ${item.ScriptName} · ${item.RoomName} · 余${item.RemainingSeats}席`
        }));

      const index = Math.max(0, sessions.findIndex(item => String(item.Id) === String(this.query.sessionId)));
      this.setData({
        sessions,
        sessionIndex: index,
        'form.sessionId': sessions[index] ? sessions[index].Id : 0
      });
    } catch (err) {
      const sessions = demo.sessions(this.query.scriptId || '').map(item => ({
        ...item,
        TimeText: format.formatDateTime(item.SessionDateTime),
        Label: `${format.formatDateTime(item.SessionDateTime)} · ${item.ScriptName} · ${item.RoomName} · 余${item.RemainingSeats}席`
      }));
      this.setData({
        sessions,
        sessionIndex: 0,
        'form.sessionId': sessions[0] ? sessions[0].Id : 0
      });
    }
  },

  pickSession(event) {
    const index = Number(event.detail.value);
    this.setData({
      sessionIndex: index,
      'form.sessionId': this.data.sessions[index].Id
    });
  },

  input(event) {
    this.setData({ [`form.${event.currentTarget.dataset.field}`]: event.detail.value });
  },

  addPlayer() {
    const next = Math.min(12, Number(this.data.form.playerCount || 1) + 1);
    this.setData({ 'form.playerCount': next });
  },

  removePlayer() {
    const next = Math.max(1, Number(this.data.form.playerCount || 1) - 1);
    this.setData({ 'form.playerCount': next });
  },

  goLogin() {
    wx.switchTab({ url: '/pages/profile/profile' });
  },

  async submit() {
    const form = this.data.form;
    if (!this.data.loggedIn) {
      wx.showToast({ title: '请先登录', icon: 'none' });
      return;
    }

    if (!form.sessionId) {
      wx.showToast({ title: '请选择场次', icon: 'none' });
      return;
    }

    if (!form.contactName || !form.phone) {
      wx.showToast({ title: '请填写联系人和电话', icon: 'none' });
      return;
    }

    try {
      const session = this.data.sessions.find(item => String(item.Id) === String(form.sessionId));
      if (String(form.sessionId).indexOf('demo-session-') === 0) {
        demo.createLocalOrder(form, session);
        wx.showToast({ title: '预约已提交' });
        setTimeout(() => wx.switchTab({ url: '/pages/orders/orders' }), 700);
        return;
      }

      await api.post('createreservation', {
        ...form,
        playerCount: Number(form.playerCount || 1)
      });
      wx.showToast({ title: '预约已提交' });
      setTimeout(() => wx.switchTab({ url: '/pages/orders/orders' }), 700);
    } catch (err) {
      wx.showToast({ title: err.message, icon: 'none' });
    }
  }
});
