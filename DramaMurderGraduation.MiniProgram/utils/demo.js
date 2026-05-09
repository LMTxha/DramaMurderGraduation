const scripts = [
  {
    Id: 'demo-1',
    Name: '雾城旧案',
    GenreName: '本格推理',
    GenreId: 'reasoning',
    PlayerMin: 5,
    PlayerMax: 6,
    DurationMinutes: 240,
    Difficulty: '进阶',
    Price: 128,
    AverageRating: 4.8,
    SoldCount: 238,
    Slogan: '一封迟到十年的信，把所有人重新带回那场雨夜。',
    StoryBackground: '雾城老剧院重开前夜，旧案卷宗突然出现在后台。六名当事人被邀请回到剧院，每个人都记得不同版本的真相。',
    Characters: [
      { Id: 'c1', Name: '林晚', Gender: '女', AgeRange: '24', Profession: '记者', Personality: '敏锐克制', Description: '追查旧案的调查记者。' },
      { Id: 'c2', Name: '周赫', Gender: '男', AgeRange: '31', Profession: '律师', Personality: '理性强势', Description: '曾代理剧院纠纷。' },
      { Id: 'c3', Name: '许知遥', Gender: '女', AgeRange: '28', Profession: '演员', Personality: '优雅疏离', Description: '最后一场演出的主角。' }
    ]
  },
  {
    Id: 'demo-2',
    Name: '海棠无声',
    GenreName: '情感沉浸',
    GenreId: 'emotion',
    PlayerMin: 4,
    PlayerMax: 6,
    DurationMinutes: 210,
    Difficulty: '标准',
    Price: 108,
    AverageRating: 4.7,
    SoldCount: 196,
    Slogan: '有人守着一座院子，有人守着一句没说出口的话。',
    StoryBackground: '民国海棠院内，一封家书牵出三代人的选择。适合喜欢沉浸演绎和情感复盘的玩家。',
    Characters: [
      { Id: 'c4', Name: '沈青禾', Gender: '女', AgeRange: '22', Profession: '学生', Personality: '温柔坚定', Description: '带着秘密回到海棠院。' },
      { Id: 'c5', Name: '顾承安', Gender: '男', AgeRange: '26', Profession: '医生', Personality: '沉稳隐忍', Description: '一直留在旧城的人。' }
    ]
  },
  {
    Id: 'demo-3',
    Name: '机械心脏',
    GenreName: '机制阵营',
    GenreId: 'mechanism',
    PlayerMin: 6,
    PlayerMax: 8,
    DurationMinutes: 260,
    Difficulty: '硬核',
    Price: 158,
    AverageRating: 4.9,
    SoldCount: 165,
    Slogan: '当城市由算法审判，人类还剩多少选择。',
    StoryBackground: '近未来地下城，玩家分别代表财团、研究所和自由民阵营，在资源、线索和投票中争夺机械心脏。',
    Characters: [
      { Id: 'c6', Name: '零号', Gender: '未知', AgeRange: '未知', Profession: '仿生人', Personality: '冷静', Description: '掌握核心协议。' },
      { Id: 'c7', Name: '秦泊', Gender: '男', AgeRange: '35', Profession: '工程师', Personality: '谨慎', Description: '机械心脏的维护者。' }
    ]
  }
];

const genres = [
  { Id: 'reasoning', Name: '本格推理' },
  { Id: 'emotion', Name: '情感沉浸' },
  { Id: 'mechanism', Name: '机制阵营' }
];

function listScripts(keyword = '', genreId = '') {
  const key = String(keyword || '').trim();
  return scripts.filter(item => {
    const matchKeyword = !key || item.Name.indexOf(key) >= 0 || item.GenreName.indexOf(key) >= 0 || item.Slogan.indexOf(key) >= 0;
    const matchGenre = !genreId || String(item.GenreId) === String(genreId);
    return matchKeyword && matchGenre;
  });
}

function getScript(id) {
  return scripts.find(item => String(item.Id) === String(id));
}

function sessions(scriptId = '') {
  const source = scriptId ? scripts.filter(item => String(item.Id) === String(scriptId)) : scripts;
  return source.slice(0, 6).map((item, index) => ({
    Id: `demo-session-${item.Id}-${index}`,
    ScriptId: item.Id,
    ScriptName: item.Name,
    RoomName: index % 2 === 0 ? '雾城一号房' : '海棠包厢',
    HostName: index % 2 === 0 ? 'DM 阿岚' : 'DM 小顾',
    BasePrice: item.Price,
    RemainingSeats: Math.max(2, item.PlayerMax - index),
    SessionDateTime: new Date(Date.now() + (index + 1) * 24 * 60 * 60 * 1000).toISOString()
  }));
}

function createLocalOrder(form, session) {
  const orders = wx.getStorageSync('demoOrders') || [];
  const order = {
    Id: `local-${Date.now()}`,
    SessionId: form.sessionId,
    ScriptId: session.ScriptId,
    ScriptName: session.ScriptName,
    RoomName: session.RoomName,
    HostName: session.HostName,
    PlayerCount: Number(form.playerCount || 1),
    TotalAmount: Number(session.BasePrice || 0) * Number(form.playerCount || 1),
    ContactName: form.contactName,
    Phone: form.phone,
    Remark: form.remark,
    Status: '待到店',
    PaymentStatus: '线下确认',
    CreatedAt: new Date().toISOString(),
    SessionDateTime: session.SessionDateTime,
    HasReview: false,
    IsLocal: true
  };
  wx.setStorageSync('demoOrders', [order].concat(orders));
  return order;
}

function localOrders() {
  return wx.getStorageSync('demoOrders') || [];
}

function updateLocalOrder(id, patch) {
  const orders = localOrders().map(item => String(item.Id) === String(id) ? { ...item, ...patch } : item);
  wx.setStorageSync('demoOrders', orders);
}

module.exports = {
  genres,
  listScripts,
  getScript,
  sessions,
  createLocalOrder,
  localOrders,
  updateLocalOrder
};
