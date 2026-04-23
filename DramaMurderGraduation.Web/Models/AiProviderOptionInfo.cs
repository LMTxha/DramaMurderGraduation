namespace DramaMurderGraduation.Web.Models
{
    public class AiProviderOptionInfo
    {
        public string Key { get; set; }
        public string DisplayName { get; set; }
        public string RegionLabel { get; set; }
        public string BaseUrl { get; set; }
        public string ApiKey { get; set; }
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
