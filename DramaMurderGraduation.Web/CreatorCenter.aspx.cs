using System;
using System.Web.UI.WebControls;
using DramaMurderGraduation.Web.Data;
using DramaMurderGraduation.Web.Models;

namespace DramaMurderGraduation.Web
{
    public partial class CreatorCenterPage : System.Web.UI.Page
    {
        private readonly ContentRepository _repository = new ContentRepository();

        protected void Page_Load(object sender, EventArgs e)
        {
            AuthManager.RequireApprovedUser();

            if (!IsPostBack)
            {
                BindGenres();
                var currentUser = AuthManager.GetCurrentUser();
                txtAuthorName.Text = currentUser.DisplayName;
                txtCoverImage.Text = "https://images.unsplash.com/photo-1516321318423-f06f85e504b3?auto=format&fit=crop&w=1200&q=80";
                BindMyScripts();
            }
        }

        protected void btnSubmitScript_Click(object sender, EventArgs e)
        {
            pnlMessage.Visible = true;
            var currentUser = AuthManager.GetCurrentUser();

            if (!int.TryParse(ddlGenres.SelectedValue, out var genreId) ||
                !int.TryParse(txtDuration.Text.Trim(), out var durationMinutes) ||
                !int.TryParse(txtPlayerMin.Text.Trim(), out var playerMin) ||
                !int.TryParse(txtPlayerMax.Text.Trim(), out var playerMax) ||
                !decimal.TryParse(txtPrice.Text.Trim(), out var price))
            {
                ShowMessage("请检查分类、时长、人数和价格字段。", false);
                return;
            }

            if (string.IsNullOrWhiteSpace(txtScriptName.Text) ||
                string.IsNullOrWhiteSpace(txtSlogan.Text) ||
                string.IsNullOrWhiteSpace(txtStoryBackground.Text) ||
                string.IsNullOrWhiteSpace(txtCoverImage.Text) ||
                string.IsNullOrWhiteSpace(txtAuthorName.Text))
            {
                ShowMessage("请完整填写剧本投稿信息。", false);
                return;
            }

            if (playerMin > playerMax)
            {
                ShowMessage("最少人数不能大于最多人数。", false);
                return;
            }

            var request = new ScriptSubmissionRequest
            {
                GenreId = genreId,
                Name = txtScriptName.Text.Trim(),
                Slogan = txtSlogan.Text.Trim(),
                StoryBackground = txtStoryBackground.Text.Trim(),
                CoverImage = txtCoverImage.Text.Trim(),
                DurationMinutes = durationMinutes,
                PlayerMin = playerMin,
                PlayerMax = playerMax,
                Difficulty = ddlDifficulty.SelectedValue,
                Price = price,
                AuthorName = txtAuthorName.Text.Trim()
            };

            var success = _repository.CreateScriptSubmission(currentUser.UserId, request, out var message);
            ShowMessage(message, success);

            if (success)
            {
                txtScriptName.Text = string.Empty;
                txtSlogan.Text = string.Empty;
                txtStoryBackground.Text = string.Empty;
                txtDuration.Text = "240";
                txtPrice.Text = "198";
                txtPlayerMin.Text = "6";
                txtPlayerMax.Text = "7";
                BindMyScripts();
            }
        }

        public string TranslateAuditStatus(object value)
        {
            var status = Convert.ToString(value);
            switch (status)
            {
                case "Approved":
                    return "已通过";
                case "Rejected":
                    return "已驳回";
                default:
                    return "待审核";
            }
        }

        private void BindGenres()
        {
            ddlGenres.Items.Clear();
            foreach (var genre in _repository.GetGenres())
            {
                ddlGenres.Items.Add(new ListItem(genre.Name, genre.Id.ToString()));
            }
        }

        private void BindMyScripts()
        {
            var currentUser = AuthManager.GetCurrentUser();
            rptMyScripts.DataSource = _repository.GetScriptsByCreator(currentUser.UserId);
            rptMyScripts.DataBind();
        }

        private void ShowMessage(string message, bool success)
        {
            pnlMessage.CssClass = success ? "status-message success" : "status-message error";
            litMessage.Text = message;
        }
    }
}
