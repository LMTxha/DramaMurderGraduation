namespace DramaMurderGraduation.Web.Models
{
    public class AiResponseInfo
    {
        public bool Success { get; set; }
        public string Content { get; set; }
        public string ErrorMessage { get; set; }
        public string ProviderDisplayName { get; set; }
        public string Model { get; set; }
        public long DurationMs { get; set; }
    }
}