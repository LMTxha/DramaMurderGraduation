namespace DramaMurderGraduation.Web.Models
{
    /// <summary>
    /// AiProviderOptionInfo 数据模型，用于在页面层和仓储层之间传递剧本杀业务数据。
    /// </summary>
    public class AiProviderOptionInfo
    {
        /// <summary>页面或业务逻辑使用的数据字段。</summary>
        public string Key { get; set; }
        /// <summary>页面展示名称。</summary>
        public string DisplayName { get; set; }
        /// <summary>页面或业务逻辑使用的数据字段。</summary>
        public string RegionLabel { get; set; }
        /// <summary>资源或页面访问地址。</summary>
        public string BaseUrl { get; set; }
        /// <summary>页面或业务逻辑使用的数据字段。</summary>
        public string ApiKey { get; set; }
        /// <summary>页面或业务逻辑使用的数据字段。</summary>
        public string DefaultModel { get; set; }
        public bool Enabled { get { return !string.IsNullOrWhiteSpace(ApiKey); } }
        public string StatusText { get { return Enabled ? "已配置" : "未配置"; } }
        public string DisplayLabel { get { return Enabled ? DisplayName : DisplayName + "（未配置）"; } }
        public string EndpointSummary
        {
            get
            {
                if (string.IsNullOrWhiteSpace(BaseUrl))
                {
                    return string.IsNullOrWhiteSpace(RegionLabel) ? "未配置地址" : RegionLabel + " · 未配置地址";
                }

                return string.IsNullOrWhiteSpace(RegionLabel) ? BaseUrl : RegionLabel + " · " + BaseUrl;
            }
        }
    }
}
