using System;

namespace DramaMurderGraduation.Web.Models
{
    /// <summary>
    /// GameActionLogInfo 数据模型，用于在页面层和仓储层之间传递剧本杀业务数据。
    /// </summary>
    public class GameActionLogInfo
    {
        /// <summary>业务主键标识。</summary>
        public int Id { get; set; }
        /// <summary>页面或业务逻辑使用的数据字段。</summary>
        public int? ReservationId { get; set; }
        /// <summary>页面或业务逻辑使用的数据字段。</summary>
        public string PlayerName { get; set; }
        /// <summary>页面或业务逻辑使用的数据字段。</summary>
        public string ActionType { get; set; }
        /// <summary>页面或业务逻辑使用的数据字段。</summary>
        public string ActionTitle { get; set; }
        /// <summary>页面或业务逻辑使用的数据字段。</summary>
        public string ActionContent { get; set; }
        /// <summary>创建时间。</summary>
        public DateTime CreatedAt { get; set; }
    }
}
