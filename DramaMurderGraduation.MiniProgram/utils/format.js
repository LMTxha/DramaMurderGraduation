function formatDateTime(value) {
  const date = parseDate(value);
  if (!date) return '时间待定';

  const month = pad(date.getMonth() + 1);
  const day = pad(date.getDate());
  const hour = pad(date.getHours());
  const minute = pad(date.getMinutes());
  return `${month}/${day} ${hour}:${minute}`;
}

function formatDate(value) {
  const date = parseDate(value);
  if (!date) return '待定';

  return `${date.getFullYear()}-${pad(date.getMonth() + 1)}-${pad(date.getDate())}`;
}

function parseDate(value) {
  if (!value) return null;
  const text = String(value);
  const match = text.match(/\/Date\((\d+)\)\//);
  const date = match ? new Date(Number(match[1])) : new Date(text);
  return isNaN(date.getTime()) ? null : date;
}

function money(value) {
  const number = Number(value || 0);
  return number.toFixed(number % 1 === 0 ? 0 : 2);
}

function imageUrl(value) {
  if (!value) return '';
  if (/^https?:\/\//i.test(value) || value.indexOf('/') === 0) return value;

  const apiBase = wx.getStorageSync('apiBase') || getApp().globalData.apiBase;
  const root = apiBase.replace(/\/MiniApi\.aspx.*$/i, '');
  return `${root}/${value.replace(/^~?\//, '')}`;
}

function text(value, fallback) {
  return value === undefined || value === null || value === '' ? fallback : value;
}

function pad(value) {
  return value < 10 ? `0${value}` : `${value}`;
}

module.exports = {
  formatDateTime,
  formatDate,
  imageUrl,
  money,
  text
};
