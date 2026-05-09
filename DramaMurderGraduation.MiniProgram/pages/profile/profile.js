const app = getApp();
const api = require('../../utils/api');
const format = require('../../utils/format');

Page({
  data: {
    loading: true,
    mode: 'login',
    apiBase: '',
    user: null,
    userInitial: '我',
    wallet: {
      transactions: [],
      recharges: []
    },
    login: {
      username: '',
      password: ''
    },
    register: {
      username: '',
      password: '',
      displayName: '',
      phone: '',
      email: ''
    },
    recharge: {
      amount: '',
      paymentMethod: '微信支付',
      paymentAccount: ''
    }
  },

  onShow() {
    this.setData({ apiBase: wx.getStorageSync('apiBase') || app.globalData.apiBase });
    this.loadMe();
  },

  async loadMe() {
    this.setData({ loading: true });
    try {
      const data = await api.get('me');
      const user = data.loggedIn ? data.user : wx.getStorageSync('demoUser');
      this.setData({
        user,
        userInitial: this.getInitial(user),
        mode: user ? 'profile' : this.data.mode
      });
      if (user) {
        await this.loadWallet();
      }
    } catch (err) {
      const user = wx.getStorageSync('demoUser');
      this.setData({ user: user || null, userInitial: this.getInitial(user) });
      if (user) {
        await this.loadWallet();
      }
    } finally {
      this.setData({ loading: false });
    }
  },

  async loadWallet() {
    if (this.data.user && this.data.user.IsLocal) {
      this.setData({
        wallet: {
          transactions: wx.getStorageSync('demoWalletTransactions') || [],
          recharges: wx.getStorageSync('demoRecharges') || []
        }
      });
      return;
    }

    try {
      const data = await api.get('wallet');
      this.setData({
        wallet: {
          transactions: (data.transactions || []).map(item => ({
            ...item,
            AmountText: format.money(item.Amount),
            TimeText: format.formatDateTime(item.CreatedAt)
          })),
          recharges: (data.recharges || []).map(item => ({
            ...item,
            AmountText: format.money(item.Amount),
            TimeText: format.formatDateTime(item.SubmittedAt)
          }))
        }
      });
    } catch (err) {
      wx.showToast({ title: err.message, icon: 'none' });
    }
  },

  demoLogin() {
    const user = {
      UserId: 'demo-user',
      Username: 'demo',
      DisplayName: '演示玩家',
      Phone: '13800000000',
      RoleDisplayName: '玩家',
      ReviewStatus: 'Approved',
      Balance: wx.getStorageSync('demoBalance') || 300,
      IsLocal: true
    };
    wx.setStorageSync('demoUser', user);
    this.setData({ user, userInitial: this.getInitial(user), mode: 'profile' });
    this.loadWallet();
  },

  switchMode(event) {
    this.setData({ mode: event.currentTarget.dataset.mode });
  },

  loginInput(event) {
    this.setData({ [`login.${event.currentTarget.dataset.field}`]: event.detail.value });
  },

  registerInput(event) {
    this.setData({ [`register.${event.currentTarget.dataset.field}`]: event.detail.value });
  },

  rechargeInput(event) {
    this.setData({ [`recharge.${event.currentTarget.dataset.field}`]: event.detail.value });
  },

  async doLogin() {
    try {
      const user = await api.post('login', this.data.login);
      app.globalData.user = user;
      this.setData({ user, userInitial: this.getInitial(user), mode: 'profile' });
      wx.showToast({ title: '登录成功' });
      this.loadWallet();
    } catch (err) {
      wx.showToast({ title: err.message, icon: 'none' });
    }
  },

  async doRegister() {
    try {
      await api.post('register', this.data.register);
      wx.showToast({ title: '注册成功' });
      this.setData({
        mode: 'login',
        login: {
          username: this.data.register.username,
          password: this.data.register.password
        }
      });
    } catch (err) {
      wx.showToast({ title: err.message, icon: 'none' });
    }
  },

  async submitRecharge() {
    const amount = Number(this.data.recharge.amount || 0);
    if (amount <= 0) {
      wx.showToast({ title: '请输入充值金额', icon: 'none' });
      return;
    }

    try {
      if (this.data.user && this.data.user.IsLocal) {
        const user = { ...this.data.user, Balance: Number(this.data.user.Balance || 0) + amount };
        const recharge = {
          Id: `recharge-${Date.now()}`,
          AmountText: format.money(amount),
          PaymentMethod: this.data.recharge.paymentMethod,
          RequestStatus: '已通过',
          TimeText: format.formatDateTime(new Date().toISOString())
        };
        const transaction = {
          Id: `wallet-${Date.now()}`,
          Summary: '小程序演示充值',
          AmountText: format.money(amount),
          TimeText: recharge.TimeText
        };
        wx.setStorageSync('demoUser', user);
        wx.setStorageSync('demoBalance', user.Balance);
        wx.setStorageSync('demoRecharges', [recharge].concat(this.data.wallet.recharges));
        wx.setStorageSync('demoWalletTransactions', [transaction].concat(this.data.wallet.transactions));
        this.setData({ user, recharge: { amount: '', paymentMethod: '微信支付', paymentAccount: '' } });
        this.loadWallet();
        wx.showToast({ title: '充值成功' });
        return;
      }

      await api.post('recharge', {
        ...this.data.recharge,
        amount
      });
      wx.showToast({ title: '已提交审核' });
      this.setData({ recharge: { amount: '', paymentMethod: '微信支付', paymentAccount: '' } });
      this.loadWallet();
    } catch (err) {
      wx.showToast({ title: err.message, icon: 'none' });
    }
  },

  setApiBase(event) {
    this.setData({ apiBase: event.detail.value });
  },

  saveApiBase() {
    wx.setStorageSync('apiBase', this.data.apiBase);
    app.globalData.apiBase = this.data.apiBase;
    wx.removeStorageSync('cookie');
    wx.showToast({ title: '接口已保存' });
    this.loadMe();
  },

  async logout() {
    await api.post('logout').catch(() => null);
    wx.removeStorageSync('cookie');
    wx.removeStorageSync('demoUser');
    app.globalData.user = null;
    this.setData({ user: null, userInitial: '我', mode: 'login', wallet: { transactions: [], recharges: [] } });
  },

  getInitial(user) {
    const name = user && (user.DisplayName || user.Username);
    return name ? name.substring(0, 1) : '我';
  }
});
