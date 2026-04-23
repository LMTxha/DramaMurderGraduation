using System;
using System.IO;
using System.Web.UI;
using System.Web.UI.HtmlControls;
using System.Web.UI.WebControls;
using DramaMurderGraduation.Web.Data;
using DramaMurderGraduation.Web.Models;

namespace DramaMurderGraduation.Web
{
    public class FeatureShowcasePage : Page
    {
        private readonly ShowcaseRepository _repository = new ShowcaseRepository();

        protected override void OnLoad(EventArgs e)
        {
            base.OnLoad(e);

            if (IsPostBack)
            {
                return;
            }

            BindPage();
        }

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

        private void WriteLiteral(string controlId, string value)
        {
            var literal = FindRecursive(this, controlId) as Literal;
            if (literal != null)
            {
                literal.Text = value ?? string.Empty;
            }
        }

        private void BindRepeater(string controlId, object dataSource)
        {
            var repeater = FindRecursive(this, controlId) as Repeater;
            if (repeater != null)
            {
                repeater.DataSource = dataSource;
                repeater.DataBind();
            }
        }

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
