const api = require('../../utils/api');
const format = require('../../utils/format');
const demo = require('../../utils/demo');

Page({
  data: {
    loading: true,
    loggedIn: true,
    orders: [],
    reviewingId: '',
    review: {
      rating: 5,
      content: '',
      highlightTag: '真实体验'
    },
    refundingId: '',
    refund: {
      requestType: '退款申请',
      requestedAmount: '',
      reason: ''
    }
  },

  onShow() {
    this.load();
  },

  onPullDownRefresh() {
    this.load().finally(() => wx.stopPullDownRefresh());
  },

  async load() {
    this.setData({ loading: true });
    try {
      const orders = await api.get('reservations');
      this.setData({ loggedIn: true, orders: (orders || []).concat(demo.localOrders()).map(this.mapOrder) });
    } catch (err) {
      const localOrders = demo.localOrders();
      this.setData({ loggedIn: localOrders.length > 0, orders: localOrders.map(this.mapOrder) });
    } finally {
      this.setData({ loading: false });
    }
  },

  mapOrder(item) {
    const status = item.Status || item.StatusCode || '';
    const isDone = status === '已完成' || status === '已到店';
    return {
      ...item,
      TimeText: format.formatDateTime(item.SessionDateTime || item.StartTime),
      CreatedText: format.formatDate(item.CreatedAt),
      AmountText: format.money(item.TotalAmount || item.PayAmount || item.Amount),
      StatusText: item.StatusText || status || '处理中',
      CanConfirm: status === 'Pending' || status === '待确认' || status === '已确认',
      CanComplete: !isDone && status !== '已取消',
      CanReview: isDone && !item.HasReview
    };
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

  async complete(event) {
    const id = event.currentTarget.dataset.id;
    const order = this.data.orders.find(item => String(item.Id) === String(id));
    try {
      if (order && order.IsLocal) {
        demo.updateLocalOrder(id, { Status: '已完成', CheckedInAt: new Date().toISOString() });
      } else {
        await api.post('completereservation', { reservationId: id });
      }
      wx.showToast({ title: '到店完成' });
      this.load();
    } catch (err) {
      wx.showToast({ title: err.message, icon: 'none' });
    }
  },

  startReview(event) {
    this.setData({
      reviewingId: event.currentTarget.dataset.id,
      review: { rating: 5, content: '', highlightTag: '真实体验' }
    });
  },

  cancelReview() {
    this.setData({ reviewingId: '' });
  },

  pickRating(event) {
    this.setData({ 'review.rating': Number(event.currentTarget.dataset.rating) });
  },

  reviewInput(event) {
    this.setData({ [`review.${event.currentTarget.dataset.field}`]: event.detail.value });
  },

  async submitReview(event) {
    const id = event.currentTarget.dataset.id;
    const order = this.data.orders.find(item => String(item.Id) === String(id));
    if (!this.data.review.content || this.data.review.content.length < 4) {
      wx.showToast({ title: '请填写评价内容', icon: 'none' });
      return;
    }

    try {
      if (order && order.IsLocal) {
        demo.updateLocalOrder(id, { HasReview: true, ReviewContent: this.data.review.content });
      } else {
        await api.post('createreview', {
          reservationId: id,
          rating: this.data.review.rating,
          content: this.data.review.content,
          highlightTag: this.data.review.highlightTag
        });
      }
      wx.showToast({ title: '评价已提交' });
      this.setData({ reviewingId: '' });
      this.load();
    } catch (err) {
      wx.showToast({ title: err.message, icon: 'none' });
    }
  },

  startRefund(event) {
    const id = event.currentTarget.dataset.id;
    const order = this.data.orders.find(item => String(item.Id) === String(id));
    this.setData({
      refundingId: id,
      refund: {
        requestType: '退款申请',
        requestedAmount: order ? order.AmountText : '',
        reason: ''
      }
    });
  },

  cancelRefund() {
    this.setData({ refundingId: '' });
  },

  refundInput(event) {
    this.setData({ [`refund.${event.currentTarget.dataset.field}`]: event.detail.value });
  },

  async submitRefund(event) {
    const id = event.currentTarget.dataset.id;
    const order = this.data.orders.find(item => String(item.Id) === String(id));
    if (!this.data.refund.reason || this.data.refund.reason.length < 4) {
      wx.showToast({ title: '请填写退款原因', icon: 'none' });
      return;
    }

    try {
      if (order && order.IsLocal) {
        demo.updateLocalOrder(id, {
          LatestAfterSaleType: this.data.refund.requestType,
          LatestAfterSaleStatus: '待处理',
          LatestAfterSaleCreatedAt: new Date().toISOString()
        });
      } else {
        await api.post('createaftersale', {
          reservationId: id,
          requestType: this.data.refund.requestType,
          requestedAmount: Number(this.data.refund.requestedAmount || 0),
          reason: this.data.refund.reason
        });
      }
      wx.showToast({ title: '退款申请已提交' });
      this.setData({ refundingId: '' });
      this.load();
    } catch (err) {
      wx.showToast({ title: err.message, icon: 'none' });
    }
  },

  goProfile() {
    wx.switchTab({ url: '/pages/profile/profile' });
  },

  goScripts() {
    wx.switchTab({ url: '/pages/scripts/scripts' });
  }
});
