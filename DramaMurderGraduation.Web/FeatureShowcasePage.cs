using System;
using System.IO;
using System.Web.UI;
using System.Web.UI.HtmlControls;
using System.Web.UI.WebControls;
using DramaMurderGraduation.Web.Data;
using DramaMurderGraduation.Web.Models;

namespace DramaMurderGraduation.Web
{
    /// <summary>
    /// 数据驱动功能展示页的公共基类。
    /// 多个中文功能页只保留统一的 aspx 模板，具体标题、按钮、统计卡片和分区内容都从 ShowcaseRepository 读取。
    /// </summary>
    public class FeatureShowcasePage : Page
    {
        private readonly ShowcaseRepository _repository = new ShowcaseRepository();

        /// <summary>
        /// 首次加载页面时绑定数据库内容。
        /// 回发时跳过绑定，避免覆盖用户在页面控件中的输入状态。
        /// </summary>
        protected override void OnLoad(EventArgs e)
        {
            base.OnLoad(e);

            if (IsPostBack)
            {
                return;
            }

            BindPage();
        }

        /// <summary>
        /// 分区 Repeater 绑定时继续绑定其内部条目 Repeater。
        /// Web Forms 的嵌套 Repeater 需要在 ItemDataBound 里手动设置内层数据源。
        /// </summary>
        protected void rptSections_ItemDataBound(object sender, RepeaterItemEventArgs e)
        {
            if (e.Item.ItemType != ListItemType.Item && e.Item.ItemType != ListItemType.AlternatingItem)
            {
                return;
            }

            var section = e.Item.DataItem as ShowcaseSectionInfo;
            if (section == null)
            {
                return;
            }

            var container = e.Item.FindControl("sectionContainer") as HtmlGenericControl;
            if (container != null && !string.IsNullOrWhiteSpace(section.LayoutCode))
            {
                container.Attributes["class"] = "section-block " + section.LayoutCode;
            }

            var entriesRepeater = e.Item.FindControl("rptEntries") as Repeater;
            if (entriesRepeater != null)
            {
                entriesRepeater.DataSource = section.Entries;
                entriesRepeater.DataBind();
            }
        }

        /// <summary>
        /// 根据当前 aspx 文件名查找展示页配置，并把配置写入模板控件。
        /// </summary>
        private void BindPage()
        {
            var pageKey = Path.GetFileNameWithoutExtension(Request.FilePath) ?? string.Empty;
            var pageInfo = _repository.GetPage(pageKey);
            if (pageInfo == null)
            {
                Response.StatusCode = 404;
                WriteLiteral("litDynamicTitle", pageKey + " | 功能页未找到");
                WriteLiteral("litPageName", "功能页未找到");
                WriteLiteral("litEyebrow", "SHOWCASE");
                WriteLiteral("litHeroTitle", "数据库中尚未初始化该功能页");
                WriteLiteral("litHeroSummary", "请检查 ShowcasePages 数据是否已经创建。");
                WriteLiteral("litHeroDescription", "当前页面文件已经生成，但数据库里还没有对应的展示内容。");
                return;
            }

            Title = pageInfo.PageName + " | 剧本杀系统";

            WriteLiteral("litDynamicTitle", pageInfo.PageName + " | 剧本杀系统");
            WriteLiteral("litPageName", pageInfo.PageName);
            WriteLiteral("litEyebrow", pageInfo.Eyebrow);
            WriteLiteral("litHeroTitle", pageInfo.HeroTitle);
            WriteLiteral("litHeroSummary", pageInfo.HeroSummary);
            WriteLiteral("litHeroDescription", pageInfo.HeroDescription);
            WriteLiteral("litBadgeText", pageInfo.BadgeText);

            BindHyperLink("lnkPrimaryAction", pageInfo.PrimaryActionText, pageInfo.PrimaryActionUrl);
            BindHyperLink("lnkSecondaryAction", pageInfo.SecondaryActionText, pageInfo.SecondaryActionUrl);

            BindRepeater("rptHeroStats", pageInfo.Stats);
            BindRepeater("rptSections", pageInfo.Sections);
        }

        /// <summary>
        /// 按控件 Id 查找 Literal 并写入文本。
        /// 使用递归查找是因为模板控件可能被 MasterPage 或 Repeater 容器包裹。
        /// </summary>
        private void WriteLiteral(string controlId, string value)
        {
            var literal = FindRecursive(this, controlId) as Literal;
            if (literal != null)
            {
                literal.Text = value ?? string.Empty;
            }
        }

        /// <summary>
        /// 按控件 Id 查找 Repeater 并绑定数据源。
        /// </summary>
        private void BindRepeater(string controlId, object dataSource)
        {
            var repeater = FindRecursive(this, controlId) as Repeater;
            if (repeater != null)
            {
                repeater.DataSource = dataSource;
                repeater.DataBind();
            }
        }

        /// <summary>
        /// 绑定按钮链接；文案或地址缺失时隐藏按钮。
        /// </summary>
        private void BindHyperLink(string controlId, string text, string url)
        {
            var link = FindRecursive(this, controlId) as HyperLink;
            if (link == null)
            {
                return;
            }

            var hasContent = !string.IsNullOrWhiteSpace(text) && !string.IsNullOrWhiteSpace(url);
            link.Visible = hasContent;
            link.Text = text ?? string.Empty;
            link.NavigateUrl = url ?? string.Empty;
        }

        /// <summary>
        /// 在当前控件树中递归查找指定 ID 的控件。
        /// </summary>
        private static Control FindRecursive(Control root, string id)
        {
            if (root == null)
            {
                return null;
            }

            if (root.ID == id)
            {
                return root;
            }

            foreach (Control child in root.Controls)
            {
                var result = FindRecursive(child, id);
                if (result != null)
                {
                    return result;
                }
            }

            return null;
        }
    }
}
