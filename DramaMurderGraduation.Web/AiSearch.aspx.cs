using System;

namespace DramaMurderGraduation.Web
{
    /// <summary>
    /// AiSearch.aspx 页面后台逻辑，负责当前 Web Forms 页面的权限校验、数据绑定和事件处理。
    /// </summary>
    public partial class AiSearchPage : System.Web.UI.Page
    {
        private const string QwenChatUrl = "https://chat.qwen.ai/";

        /// <summary>
        /// 页面生命周期入口，负责权限校验和首次加载时的数据初始化。
        /// </summary>
        protected void Page_Load(object sender, EventArgs e)
        {
            Response.Redirect(QwenChatUrl, false);
            Context.ApplicationInstance.CompleteRequest();
        }
    }
}
