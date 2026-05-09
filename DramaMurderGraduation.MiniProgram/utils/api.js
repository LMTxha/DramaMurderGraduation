const app = getApp();

function request(action, data = {}, method = 'GET') {
  const apiBase = wx.getStorageSync('apiBase') || app.globalData.apiBase;
  const cookie = wx.getStorageSync('cookie') || '';

  return new Promise((resolve, reject) => {
    sendRequest(apiBase, action, data, method, cookie, resolve, reject);
  });
}

function sendRequest(apiBase, action, data, method, cookie, resolve, reject) {
  wx.request({
    url: buildUrl(apiBase, action, method === 'GET' ? data : {}),
    method,
    data: method === 'GET' ? {} : data,
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

      reject(new Error(payload.message || `请求失败(${res.statusCode})`));
    },
    fail(err) {
      reject(new Error(formatNetworkError(err, apiBase)));
    }
  });
}

function buildUrl(apiBase, action, params) {
  const pairs = [`action=${encodeURIComponent(action)}`];
  Object.keys(params || {}).forEach(key => {
    const value = params[key];
    if (value !== undefined && value !== null && value !== '') {
      pairs.push(`${encodeURIComponent(key)}=${encodeURIComponent(value)}`);
    }
  });

  return `${apiBase}${apiBase.indexOf('?') >= 0 ? '&' : '?'}${pairs.join('&')}`;
}

function formatNetworkError(err, apiBase) {
  const raw = err && err.errMsg ? err.errMsg : '';
  if (raw.indexOf('url not in domain list') >= 0) {
    return '请求被小程序域名校验拦截，请在开发者工具勾选“不校验合法域名”。';
  }

  if (raw.indexOf('fail') >= 0) {
    return `接口连接失败，请确认 Web 项目已启动，并且接口地址是 ${apiBase}`;
  }

  return raw || `接口连接失败，请确认 Web 项目已启动：${apiBase}`;
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
