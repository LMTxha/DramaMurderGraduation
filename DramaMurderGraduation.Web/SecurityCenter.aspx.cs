using System;
using System.Linq;
using DramaMurderGraduation.Web.Data;

namespace DramaMurderGraduation.Web
{
    public partial class SecurityCenterPage : System.Web.UI.Page
    {
        private readonly AccountRepository _accountRepository = new AccountRepository();
        private readonly FriendWorkspaceRepository _workspaceRepository = new FriendWorkspaceRepository();

        protected void Page_Load(object sender, EventArgs e)
        {
            AuthManager.RequireApprovedUser();

            if (!IsPostBack)
            {
                BindPage();
            }
        }

        private void BindPage()
        {
            var currentUser = AuthManager.GetCurrentUser();
            litRoleName.Text = currentUser.RoleDisplayName;

            var loginLogs = _accountRepository.GetRecentLoginSecurityLogs(currentUser.UserId, 12);
            var profileLogs = _workspaceRepository.GetRecentProfileChangeLogs(currentUser.UserId, 12);

            var latestLogin = loginLogs.FirstOrDefault();
            litLatestLoginResult.Text = latestLogin == null ? "暂无记录" : Convert.ToString(latestLogin.ResultType);
            litLatestLoginTime.Text = latestLogin == null ? "还没有登录日志" : latestLogin.CreatedAt.ToString("yyyy-MM-dd HH:mm");

            rptLoginLogs.DataSource = loginLogs;
            rptLoginLogs.DataBind();

            rptProfileChangeLogs.DataSource = profileLogs;
            rptProfileChangeLogs.DataBind();
        }
    }
}
