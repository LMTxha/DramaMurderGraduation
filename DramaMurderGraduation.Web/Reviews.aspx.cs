using System;
using System.Linq;
using System.Web.UI.WebControls;
using DramaMurderGraduation.Web.Data;

namespace DramaMurderGraduation.Web
{
    public partial class ReviewsPage : System.Web.UI.Page
    {
        private readonly ContentRepository _repository = new ContentRepository();

        protected void Page_Load(object sender, EventArgs e)
        {
            if (!IsPostBack)
            {
                BindScripts();
                BindReviews();
            }
        }

        protected void btnFilter_Click(object sender, EventArgs e)
        {
            BindReviews();
        }

        private void BindScripts()
        {
            ddlScripts.Items.Clear();
            ddlScripts.Items.Add(new ListItem("全部剧本", string.Empty));

            foreach (var script in _repository.GetScripts(string.Empty, null))
            {
                ddlScripts.Items.Add(new ListItem(script.Name, script.Id.ToString()));
            }
        }

        private void BindReviews()
        {
            int? scriptId = null;
            if (int.TryParse(ddlScripts.SelectedValue, out var parsedScriptId))
            {
                scriptId = parsedScriptId;
            }

            var reviews = _repository.GetLatestReviews(200, scriptId);
            litReviewTotal.Text = reviews.Count.ToString();
            litAverageScore.Text = reviews.Count == 0 ? "0.0" : reviews.Average(item => item.Rating).ToString("F1");

            rptReviews.DataSource = reviews;
            rptReviews.DataBind();
        }
    }
}
