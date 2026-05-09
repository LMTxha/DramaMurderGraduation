const app = getApp();

function request(action, data = {}, method = 'GET') {
  const cookie = wx.getStorageSync('cookie') || '';
  const apiBase = wx.getStorageSync('apiBase') || app.globalData.apiBase;

  return new Promise((resolve, reject) => {
    wx.request({
      url: `${apiBase}?action=${action}`,
      method,
      data,
      header: {
        'content-type': 'application/json',
        Cookie: cookie
      },
      success(res) {
        const setCookie = res.header['Set-Cookie'] || res.header['set-cookie'];
        if (setCookie) {
          wx.setStorageSync('cookie', normalizeCookie(setCookie));
        }

        const payload = res.data || {};
        if (res.statusCode >= 200 && res.statusCode < 300 && payload.success !== false) {
          resolve(payload.data);
          return;
        }

        reject(new Error(payload.message || '请求失败'));
      },
      fail(err) {
        reject(new Error(err.errMsg || '网络连接失败'));
      }
    });
  });
}

function normalizeCookie(rawCookie) {
  const source = Array.isArray(rawCookie) ? rawCookie.join(',') : rawCookie;
  return source
    .split(',')
    .map(part => part.split(';')[0].trim())
    .filter(Boolean)
    .join('; ');
}

module.exports = {
  get: (action, data) => request(action, data, 'GET'),
  post: (action, data) => request(action, data, 'POST')
};
