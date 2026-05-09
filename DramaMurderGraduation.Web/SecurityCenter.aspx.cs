using System;
using System.Linq;
using DramaMurderGraduation.Web.Data;

namespace DramaMurderGraduation.Web
{
    /// <summary>
    /// SecurityCenter.aspx 页面后台逻辑，负责当前 Web Forms 页面的权限校验、数据绑定和事件处理。
    /// </summary>
    public partial class SecurityCenterPage : System.Web.UI.Page
    {
        private readonly AccountRepository _accountRepository = new AccountRepository();
        private readonly FriendWorkspaceRepository _workspaceRepository = new FriendWorkspaceRepository();

        /// <summary>
        /// 页面生命周期入口，负责权限校验和首次加载时的数据初始化。
        /// </summary>
        protected void Page_Load(object sender, EventArgs e)
        {
            AuthManager.RequireApprovedUser();

            if (!IsPostBack)
            {
                BindPage();
            }
        }

        /// <summary>
        /// 绑定页面展示数据到对应控件。
        /// </summary>
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
