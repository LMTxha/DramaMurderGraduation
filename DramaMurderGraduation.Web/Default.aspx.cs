using System;
using DramaMurderGraduation.Web.Data;

namespace DramaMurderGraduation.Web
{
    public partial class DefaultPage : System.Web.UI.Page
    {
        protected void Page_Load(object sender, EventArgs e)
        {
            if (IsPostBack)
            {
                return;
            }

            var repository = new ContentRepository();
            var settings = repository.GetSiteSettings();
            var metrics = repository.GetSiteMetrics();

            litHeroTitle.Text = CleanCopy(settings.HeroTitle, "雾城剧本研究所");
            litHeroSubtitle.Text = CleanCopy(settings.HeroSubtitle, "从热门新本、当晚排期到同城组局，把今晚的快乐安排得明明白白。");
            litWelcomeText.Text = CleanCopy(settings.WelcomeText, "想先挑本、先看场次、先喊朋友，还是直接进房开玩，这里都能一步到位。");
            litAboutTitle.Text = "今晚的玩法导览";
            litAboutContent.Text = "先看看热门剧本和近期排期，再决定是直接预约、围观热局，还是去玩家中心和好友组车。";

            litScriptCount.Text = metrics.ScriptCount.ToString();
            litCharacterCount.Text = metrics.CharacterCount.ToString();
            litRoomCount.Text = metrics.RoomCount.ToString();
            litReservationCount.Text = metrics.ReservationCount.ToString();
            litAverageRating.Text = metrics.AverageRating.ToString("F1");

            rptAnnouncements.DataSource = repository.GetAnnouncements(3);
            rptAnnouncements.DataBind();

            rptFeaturedScripts.DataSource = repository.GetFeaturedScripts(4);
            rptFeaturedScripts.DataBind();

            rptUpcomingSessions.DataSource = repository.GetUpcomingSessions(5);
            rptUpcomingSessions.DataBind();

            rptLatestReviews.DataSource = repository.GetLatestReviews(4);
            rptLatestReviews.DataBind();
        }

        private static string CleanCopy(string value, string fallback)
        {
            if (string.IsNullOrWhiteSpace(value))
            {
                return fallback;
            }

            var cleaned = value
                .Replace("毕业设计版", string.Empty)
                .Replace("毕业设计", string.Empty)
                .Replace("数据库", "门店内容")
                .Replace("动态网页", "线上页面")
                .Replace("Web Forms", string.Empty)
                .Replace("SQL Server", string.Empty)
                .Replace("门店运营系统", "门店")
                .Replace("系统", string.Empty)
                .Replace("平台", "聚场")
                .Replace("驱动", "整理")
                .Trim();

            return string.IsNullOrWhiteSpace(cleaned) ? fallback : cleaned;
        }
    }
}
