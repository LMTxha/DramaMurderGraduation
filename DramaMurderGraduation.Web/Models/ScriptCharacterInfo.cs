namespace DramaMurderGraduation.Web.Models
{
    /// <summary>
    /// ScriptCharacterInfo 数据模型，用于在页面层和仓储层之间传递剧本杀业务数据。
    /// </summary>
    public class ScriptCharacterInfo
    {
        /// <summary>业务主键标识。</summary>
        public int Id { get; set; }
        /// <summary>页面或业务逻辑使用的数据字段。</summary>
        public int ScriptId { get; set; }
        /// <summary>业务对象名称。</summary>
        public string Name { get; set; }
        /// <summary>页面或业务逻辑使用的数据字段。</summary>
        public string Gender { get; set; }
        /// <summary>页面或业务逻辑使用的数据字段。</summary>
        public string AgeRange { get; set; }
        /// <summary>页面或业务逻辑使用的数据字段。</summary>
        public string Profession { get; set; }
        /// <summary>页面或业务逻辑使用的数据字段。</summary>
        public string Personality { get; set; }
        /// <summary>页面或业务逻辑使用的数据字段。</summary>
        public string SecretLine { get; set; }
        /// <summary>详细说明文案。</summary>
        public string Description { get; set; }
    }
}
