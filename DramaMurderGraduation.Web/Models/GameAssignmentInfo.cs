namespace DramaMurderGraduation.Web.Models
{
    /// <summary>
    /// GameAssignmentInfo 数据模型，用于在页面层和仓储层之间传递剧本杀业务数据。
    /// </summary>
    public class GameAssignmentInfo
    {
        /// <summary>页面或业务逻辑使用的数据字段。</summary>
        public int ReservationId { get; set; }
        /// <summary>关联的用户主键。</summary>
        public int? UserId { get; set; }
        /// <summary>页面或业务逻辑使用的数据字段。</summary>
        public string PlayerName { get; set; }
        /// <summary>页面或业务逻辑使用的数据字段。</summary>
        public string ContactName { get; set; }
        /// <summary>统计数量。</summary>
        public int PlayerCount { get; set; }
        /// <summary>页面或业务逻辑使用的数据字段。</summary>
        public int CharacterId { get; set; }
        /// <summary>页面或业务逻辑使用的数据字段。</summary>
        public string CharacterName { get; set; }
        /// <summary>页面或业务逻辑使用的数据字段。</summary>
        public string Gender { get; set; }
        /// <summary>页面或业务逻辑使用的数据字段。</summary>
        public string AgeRange { get; set; }
        /// <summary>页面或业务逻辑使用的数据字段。</summary>
        public string Profession { get; set; }
        /// <summary>页面或业务逻辑使用的数据字段。</summary>
        public string Personality { get; set; }
        /// <summary>页面或业务逻辑使用的数据字段。</summary>
        public string CharacterDescription { get; set; }
        /// <summary>页面或业务逻辑使用的数据字段。</summary>
        public string SecretLine { get; set; }
        /// <summary>布尔状态标记。</summary>
        public bool IsReady { get; set; }
        public bool IsEliminated { get; set; }
        public System.DateTime? EliminatedAt { get; set; }
    }
}
