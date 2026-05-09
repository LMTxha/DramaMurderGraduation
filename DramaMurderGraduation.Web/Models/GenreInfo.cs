namespace DramaMurderGraduation.Web.Models
{
    /// <summary>
    /// GenreInfo 数据模型，用于在页面层和仓储层之间传递剧本杀业务数据。
    /// </summary>
    public class GenreInfo
    {
        /// <summary>业务主键标识。</summary>
        public int Id { get; set; }
        /// <summary>业务对象名称。</summary>
        public string Name { get; set; }
        /// <summary>详细说明文案。</summary>
        public string Description { get; set; }
    }
}
