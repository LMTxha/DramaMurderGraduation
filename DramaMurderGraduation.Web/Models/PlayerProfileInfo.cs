namespace DramaMurderGraduation.Web.Models
{
    /// <summary>
    /// PlayerProfileInfo 数据模型，用于在页面层和仓储层之间传递剧本杀业务数据。
    /// </summary>
    public class PlayerProfileInfo
    {
        /// <summary>关联的用户主键。</summary>
        public int UserId { get; set; }
        /// <summary>页面展示名称。</summary>
        public string DisplayName { get; set; }
        /// <summary>页面或业务逻辑使用的数据字段。</summary>
        public string DisplayTitle { get; set; }
        /// <summary>页面或业务逻辑使用的数据字段。</summary>
        public string Motto { get; set; }
        /// <summary>资源或页面访问地址。</summary>
        public string AvatarUrl { get; set; }
        /// <summary>页面或业务逻辑使用的数据字段。</summary>
        public string FavoriteGenre { get; set; }
        /// <summary>页面或业务逻辑使用的数据字段。</summary>
        public int JoinDays { get; set; }
        /// <summary>页面或业务逻辑使用的数据字段。</summary>
        public int CompletedScripts { get; set; }
        /// <summary>比例指标，通常按百分比展示。</summary>
        public decimal WinRate { get; set; }
        /// <summary>页面或业务逻辑使用的数据字段。</summary>
        public string ReputationLevel { get; set; }
    }
}
