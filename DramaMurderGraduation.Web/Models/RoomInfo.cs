namespace DramaMurderGraduation.Web.Models
{
    /// <summary>
    /// RoomInfo 数据模型，用于在页面层和仓储层之间传递剧本杀业务数据。
    /// </summary>
    public class RoomInfo
    {
        /// <summary>业务主键标识。</summary>
        public int Id { get; set; }
        /// <summary>业务对象名称。</summary>
        public string Name { get; set; }
        /// <summary>页面或业务逻辑使用的数据字段。</summary>
        public string Theme { get; set; }
        /// <summary>页面或业务逻辑使用的数据字段。</summary>
        public int Capacity { get; set; }
        /// <summary>详细说明文案。</summary>
        public string Description { get; set; }
        /// <summary>资源或页面访问地址。</summary>
        public string ImageUrl { get; set; }
        /// <summary>当前业务状态。</summary>
        public string Status { get; set; }
        /// <summary>统计数量。</summary>
        public int UpcomingSessionCount { get; set; }
        /// <summary>页面或业务逻辑使用的数据字段。</summary>
        public int PrimarySessionId { get; set; }
    }
}
