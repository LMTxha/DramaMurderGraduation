const api = require('../../utils/api');

Page({
  data: {
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
    this.query = query;
    this.loadSessions();
  },

  async loadSessions() {
    try {
      const raw = await api.get('sessions', { scriptId: this.query.scriptId || '' });
      const sessions = raw
        .filter(item => item.RemainingSeats > 0)
        .map(item => ({
          ...item,
          Label: `${item.ScriptName} · ${item.RoomName} · 余${item.RemainingSeats}席`
        }));
      const index = Math.max(0, sessions.findIndex(item => String(item.Id) === String(this.query.sessionId)));
      this.setData({
        sessions,
        sessionIndex: index,
        'form.sessionId': sessions[index] ? sessions[index].Id : 0
      });
    } catch (err) {
      wx.showToast({ title: err.message, icon: 'none' });
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

  async submit() {
    try {
      await api.post('createreservation', {
        ...this.data.form,
        playerCount: Number(this.data.form.playerCount)
      });
      wx.showToast({ title: '预约已提交' });
      setTimeout(() => wx.switchTab({ url: '/pages/orders/orders' }), 800);
    } catch (err) {
      wx.showToast({ title: err.message, icon: 'none' });
    }
  }
});
