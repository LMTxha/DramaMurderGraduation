using System;
using System.Web;
using DramaMurderGraduation.Web.Data;

namespace DramaMurderGraduation.Web
{
    public partial class ScriptDetailsPage : System.Web.UI.Page
    {
        protected void Page_Load(object sender, EventArgs e)
        {
            if (IsPostBack)
            {
                return;
            }

            if (!int.TryParse(Request.QueryString["id"], out var scriptId))
            {
                ShowNotFound();
                return;
            }

            var repository = new ContentRepository();
            var detail = repository.GetScriptDetail(scriptId);
            if (detail == null)
            {
                ShowNotFound();
                return;
            }

            pnlNotFound.Visible = false;
            pnlContent.Visible = true;

            imgCover.ImageUrl = detail.CoverImage;
            imgCover.AlternateText = detail.Name;
            litGenre.Text = detail.GenreName;
            litName.Text = detail.Name;
            litSlogan.Text = detail.Slogan;
            litDuration.Text = detail.DurationMinutes + " 分钟";
            litPlayers.Text = detail.PlayerMin + "-" + detail.PlayerMax + " 人";
            litDifficulty.Text = detail.Difficulty;
            litAuthor.Text = detail.AuthorName;
            litPrice.Text = detail.Price.ToString("F0");
            litAverageRating.Text = detail.AverageRating.ToString("F1");
            litReviewCount.Text = detail.ReviewCount.ToString();
            litStoryBackground.Text = detail.StoryBackground;

            if (!string.IsNullOrWhiteSpace(detail.FullScriptContent))
            {
                phFullScriptContent.Visible = true;
                litFullScriptContent.Text = HttpUtility.HtmlEncode(detail.FullScriptContent).Replace("\r\n", "<br />").Replace("\n", "<br />");
            }
            else
            {
                phFullScriptContent.Visible = false;
            }

            rptCharacters.DataSource = repository.GetCharactersByScript(scriptId);
            rptCharacters.DataBind();

            var scriptAssets = repository.GetScriptAssets(scriptId);
            phScriptAssets.Visible = scriptAssets.Count > 0;
            rptScriptAssets.DataSource = scriptAssets;
            rptScriptAssets.DataBind();

            rptSessions.DataSource = repository.GetUpcomingSessions(8, scriptId);
            rptSessions.DataBind();

            rptReviews.DataSource = repository.GetLatestReviews(8, scriptId);
            rptReviews.DataBind();
        }

        public string TranslateAssetType(object assetType)
        {
            switch (Convert.ToString(assetType))
            {
                case "manual":
                    return "主持手册";
                case "document":
                    return "剧本文档";
                case "image":
                    return "图片素材";
                case "cover":
                    return "封面海报";
                case "audio":
                    return "音频素材";
                case "video":
                    return "视频素材";
                case "archive":
                    return "压缩包";
                case "spreadsheet":
                    return "表格资料";
                case "text":
                    return "文本资料";
                default:
                    return string.IsNullOrWhiteSpace(Convert.ToString(assetType)) ? "资料文件" : Convert.ToString(assetType);
            }
        }

        private void ShowNotFound()
        {
            pnlContent.Visible = false;
            pnlNotFound.Visible = true;
        }
    }
}
