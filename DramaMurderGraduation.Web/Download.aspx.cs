using System;
using System.Linq;
using System.Text;
using DramaMurderGraduation.Web.Data;

namespace DramaMurderGraduation.Web
{
    /// <summary>
    /// Download.aspx 页面后台逻辑，负责当前 Web Forms 页面的权限校验、数据绑定和事件处理。
    /// </summary>
    public partial class DownloadPage : System.Web.UI.Page
    {
        private readonly ContentRepository _contentRepository = new ContentRepository();

        /// <summary>
        /// 页面生命周期入口，负责权限校验和首次加载时的数据初始化。
        /// </summary>
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

        /// <summary>
        /// 页面辅助方法，封装当前页面使用的局部业务逻辑。
        /// </summary>
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
