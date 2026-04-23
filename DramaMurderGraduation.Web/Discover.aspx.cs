using DramaMurderGraduation.Web.Data;

namespace DramaMurderGraduation.Web
{
    public partial class DiscoverPage : System.Web.UI.Page
    {
        private readonly FeatureRepository _repository = new FeatureRepository();

        protected void Page_Load(object sender, System.EventArgs e)
        {
            if (IsPostBack)
            {
                return;
            }

            BindPage();
        }

        private void BindPage()
        {
            var recommendations = _repository.GetTodayRecommendations(4);
            var challenges = _repository.GetChallenges(3);
            var liveSessions = _repository.GetLiveSessions(4);
            var membershipPlans = _repository.GetMembershipPlans();
            var identityOptions = _repository.GetIdentityOptions();

            foreach (var recommendation in recommendations)
            {
                recommendation.Title = CleanCopy(recommendation.Title, recommendation.Title);
                recommendation.Summary = CleanCopy(recommendation.Summary, "适合今晚直接组车开玩的热门剧本。");
                recommendation.HighlightTag = CleanCopy(recommendation.HighlightTag, recommendation.HighlightTag);
            }

            foreach (var challenge in challenges)
            {
                challenge.Title = CleanCopy(challenge.Title, challenge.Title);
                challenge.Description = CleanCopy(challenge.Description, "限时活动正在火热进行中，点开就能直接参与。");
                challenge.RewardSummary = CleanCopy(challenge.RewardSummary, challenge.RewardSummary);
                challenge.StatusTag = CleanCopy(challenge.StatusTag, challenge.StatusTag);
            }

            foreach (var liveSession in liveSessions)
            {
                liveSession.Title = CleanCopy(liveSession.Title, liveSession.Title);
                liveSession.Summary = CleanCopy(liveSession.Summary, "先围观气氛，再决定要不要加入这一车。");
                liveSession.StatusText = CleanCopy(liveSession.StatusText, liveSession.StatusText);
            }

            var heroRecommendation = recommendations.Count > 0 ? recommendations[0] : null;
            litHeroTitle.Text = heroRecommendation != null ? heroRecommendation.Title : "今晚去哪玩";
            litHeroSummary.Text = heroRecommendation != null
                ? CleanCopy(heroRecommendation.Summary, "从热门剧本、限时活动到观战房间，先逛一圈再决定今晚的去向。")
                : "从热门剧本、限时活动到观战房间，先逛一圈再决定今晚的去向。";

            litRecommendationCount.Text = recommendations.Count.ToString();
            litChallengeCount.Text = challenges.Count.ToString();
            litLiveCount.Text = liveSessions.Count.ToString();

            rptRecommendations.DataSource = recommendations;
            rptRecommendations.DataBind();

            rptChallenges.DataSource = challenges;
            rptChallenges.DataBind();

            rptLiveSessions.DataSource = liveSessions;
            rptLiveSessions.DataBind();

            rptMembershipPlans.DataSource = membershipPlans;
            rptMembershipPlans.DataBind();

            rptIdentityOptions.DataSource = identityOptions;
            rptIdentityOptions.DataBind();
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
                .Replace("数据库", "内容")
                .Replace("Web Forms", string.Empty)
                .Replace("SQL Server", string.Empty)
                .Replace("系统", string.Empty)
                .Replace("平台", "聚场")
                .Trim();

            return string.IsNullOrWhiteSpace(cleaned) ? fallback : cleaned;
        }
    }
}
