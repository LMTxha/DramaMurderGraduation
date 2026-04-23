namespace DramaMurderGraduation.Web.Models
{
    public class ScriptAssetInfo
    {
        public int Id { get; set; }
        public int ScriptId { get; set; }
        public string AssetType { get; set; }
        public string Title { get; set; }
        public string FileName { get; set; }
        public string RelativePath { get; set; }
        public string PublicUrl { get; set; }
        public string FileExtension { get; set; }
        public long FileSizeBytes { get; set; }
        public bool IsPrimary { get; set; }
        public int SortOrder { get; set; }
    }
}
