using System;

namespace DramaMurderGraduation.Web.Models
{
    /// <summary>
    /// ProfileChangeLogInfo 数据模型，用于在页面层和仓储层之间传递剧本杀业务数据。
    /// </summary>
    public class ProfileChangeLogInfo
    {
        /// <summary>业务主键标识。</summary>
        public int Id { get; set; }
        /// <summary>关联的用户主键。</summary>
        public int UserId { get; set; }
        /// <summary>页面或业务逻辑使用的数据字段。</summary>
        public string FieldName { get; set; }
        /// <summary>页面或业务逻辑使用的数据字段。</summary>
        public string BeforeValue { get; set; }
        /// <summary>页面或业务逻辑使用的数据字段。</summary>
        public string AfterValue { get; set; }
        /// <summary>对应业务动作的发生时间。</summary>
        public DateTime ChangedAt { get; set; }
    }
}
