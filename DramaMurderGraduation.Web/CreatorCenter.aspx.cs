using System;
using System.Web.UI.WebControls;
using DramaMurderGraduation.Web.Data;
using DramaMurderGraduation.Web.Models;

namespace DramaMurderGraduation.Web
{
    /// <summary>
    /// CreatorCenter.aspx 页面后台逻辑，负责当前 Web Forms 页面的权限校验、数据绑定和事件处理。
    /// </summary>
    public partial class CreatorCenterPage : System.Web.UI.Page
    {
        private readonly ContentRepository _repository = new ContentRepository();

        /// <summary>
        /// 页面生命周期入口，负责权限校验和首次加载时的数据初始化。
        /// </summary>
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

        /// <summary>
        /// 处理页面按钮点击事件，并根据当前表单输入刷新或提交业务数据。
        /// </summary>
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

        /// <summary>
        /// 页面辅助方法，封装当前页面使用的局部业务逻辑。
        /// </summary>
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

        /// <summary>
        /// 绑定页面展示数据到对应控件。
        /// </summary>
        private void BindGenres()
        {
            ddlGenres.Items.Clear();
            foreach (var genre in _repository.GetGenres())
            {
                ddlGenres.Items.Add(new ListItem(genre.Name, genre.Id.ToString()));
            }
        }

        /// <summary>
        /// 绑定页面展示数据到对应控件。
        /// </summary>
        private void BindMyScripts()
        {
            var currentUser = AuthManager.GetCurrentUser();
            rptMyScripts.DataSource = _repository.GetScriptsByCreator(currentUser.UserId);
            rptMyScripts.DataBind();
        }

        /// <summary>
        /// 设置页面控件状态或提示信息。
        /// </summary>
        private void ShowMessage(string message, bool success)
        {
            pnlMessage.CssClass = success ? "status-message success" : "status-message error";
            litMessage.Text = message;
        }
    }
}
