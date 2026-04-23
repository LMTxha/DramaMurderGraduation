using System;
using System.Linq;
using System.Text;
using DramaMurderGraduation.Web.Data;

namespace DramaMurderGraduation.Web
{
    public partial class DownloadPage : System.Web.UI.Page
    {
        private readonly ContentRepository _contentRepository = new ContentRepository();

        protected void Page_Load(object sender, EventArgs e)
        {
            var platform = Request.QueryString["platform"];
            if (!string.IsNullOrWhiteSpace(platform))
            {
                SendDownload(platform.Trim());
                return;
            }

            if (IsPostBack)
            {
                return;
            }

            var options = _contentRepository.GetDownloadOptions();
            rptDownloadOptions.DataSource = options;
            rptDownloadOptions.DataBind();

            rptReleaseNotes.DataSource = options
                .OrderByDescending(option => option.ReleaseDate)
                .Take(3)
                .ToList();
            rptReleaseNotes.DataBind();
        }

        private void SendDownload(string platformCode)
        {
            var option = _contentRepository.GetDownloadOption(platformCode);
            if (option == null)
            {
                Response.Redirect("~/Download.aspx");
                return;
            }

            var content = new StringBuilder()
                .AppendLine("剧本杀玩家客户端下载说明")
                .AppendLine()
                .AppendLine("平台：" + option.PlatformName)
                .AppendLine("版本：" + option.VersionText)
                .AppendLine("说明：" + option.Summary)
                .AppendLine("发布日期：" + option.ReleaseDate.ToString("yyyy-MM-dd"))
                .AppendLine()
                .AppendLine("当前毕业设计演示系统已提供网页版完整功能。")
                .AppendLine("如需替换为真实安装包，请在数据库 DownloadOptions 表中把 DownloadUrl 改为实际安装包地址。")
                .AppendLine()
                .AppendLine("网页版入口：" + ResolveUrl("~/Default.aspx"))
                .ToString();

            var fileName = "DramaMurder-" + option.PlatformCode + "-download.txt";
            Response.Clear();
            Response.ContentType = "text/plain";
            Response.ContentEncoding = Encoding.UTF8;
            Response.AddHeader("Content-Disposition", "attachment; filename=" + fileName);
            Response.Write(content);
            Response.End();
        }
    }
}
