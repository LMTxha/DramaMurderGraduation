namespace DramaMurderGraduation.Web.Models
{
    /// <summary>
    /// PlayerAbilityInfo 数据模型，用于在页面层和仓储层之间传递剧本杀业务数据。
    /// </summary>
    public class PlayerAbilityInfo
    {
        /// <summary>关联的用户主键。</summary>
        public int UserId { get; set; }
        /// <summary>页面或业务逻辑使用的数据字段。</summary>
        public int DeductionPower { get; set; }
        /// <summary>页面或业务逻辑使用的数据字段。</summary>
        public int ObservationPower { get; set; }
        /// <summary>页面或业务逻辑使用的数据字段。</summary>
        public int CreativityPower { get; set; }
        /// <summary>页面或业务逻辑使用的数据字段。</summary>
        public int CollaborationPower { get; set; }
        /// <summary>页面或业务逻辑使用的数据字段。</summary>
        public int ExecutionPower { get; set; }
    }
}
