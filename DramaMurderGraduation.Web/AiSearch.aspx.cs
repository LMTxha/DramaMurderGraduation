using System;

namespace DramaMurderGraduation.Web
{
    public partial class AiSearchPage : System.Web.UI.Page
    {
        private const string QwenChatUrl = "https://chat.qwen.ai/";

        protected void Page_Load(object sender, EventArgs e)
        {
            Response.Redirect(QwenChatUrl, false);
            Context.ApplicationInstance.CompleteRequest();
        }
    }
}
