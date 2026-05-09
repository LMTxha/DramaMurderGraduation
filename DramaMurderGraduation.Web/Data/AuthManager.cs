using System;
using System.Security.Cryptography;
using System.Text;
using System.Web;
using DramaMurderGraduation.Web.Models;

namespace DramaMurderGraduation.Web.Data
{
    /// <summary>
    /// 登录态、密码哈希和权限检查的集中管理类。
    /// 页面层只需要调用 RequireXxx/HasXxx 方法，不需要直接了解 Session 键名或角色编码细节。
    /// </summary>
    public static class AuthManager
    {
        // Session 中保存的是裁剪后的 CurrentUserInfo，而不是完整 Users 表记录，
        // 这样可以减少页面层误用敏感字段的概率。
        private const string SessionKey = "CurrentUser";

        /// <summary>
        /// 从当前 HTTP Session 读取登录用户；没有登录或 Session 不可用时返回 null。
        /// </summary>
        public static CurrentUserInfo GetCurrentUser()
        {
            return HttpContext.Current?.Session?[SessionKey] as CurrentUserInfo;
        }

        /// <summary>
        /// 判断用户是否处于有效登录态。
        /// 已登录但尚未通过审核的用户会被强制退出，防止旧 Session 绕过审核状态。
        /// </summary>
        public static bool IsLoggedIn()
        {
            var currentUser = GetCurrentUser();
            if (currentUser == null)
            {
                return false;
            }

            if (HasApprovedUserAccess(currentUser))
            {
                return true;
            }

            SignOut();
            return false;
        }

        /// <summary>
        /// 写入当前登录用户信息。
        /// 调用前通常已经完成密码校验、审核状态校验和 CurrentUserInfo 映射。
        /// </summary>
        public static void SignIn(CurrentUserInfo user)
        {
            HttpContext.Current.Session[SessionKey] = user;
        }

        /// <summary>
        /// 将数据库用户模型转换成页面 Session 使用的轻量用户模型。
        /// 这里不保留密码哈希、邮箱等不需要频繁展示的字段。
        /// </summary>
        public static CurrentUserInfo CreateCurrentUser(UserAccountInfo user)
        {
            if (user == null)
            {
                return null;
            }

            return new CurrentUserInfo
            {
                UserId = user.Id,
                Username = user.Username,
                DisplayName = user.DisplayName,
                PublicUserCode = user.PublicUserCode,
                Phone = user.Phone,
                RoleCode = user.RoleCode,
                ReviewStatus = user.ReviewStatus,
                Balance = user.Balance
            };
        }

        /// <summary>
        /// 根据用户角色给出登录后的默认落地页；未登录时回到首页。
        /// 具体角色到页面的映射在 CurrentUserInfo.DefaultLandingUrl 中维护。
        /// </summary>
        public static string GetDefaultLandingUrl(CurrentUserInfo currentUser)
        {
            return currentUser == null ? "~/Default.aspx" : currentUser.DefaultLandingUrl;
        }

        /// <summary>
        /// 清理当前 Session 中的登录用户。
        /// </summary>
        public static void SignOut()
        {
            if (HttpContext.Current?.Session == null)
            {
                return;
            }

            HttpContext.Current.Session.Remove(SessionKey);
        }

        /// <summary>
        /// 使用 SHA-256 生成密码哈希。
        /// 该项目是教学/毕业设计场景，生产环境建议改成带盐的 PBKDF2/BCrypt/Argon2。
        /// </summary>
        public static string HashPassword(string rawPassword)
        {
            using (var sha256 = SHA256.Create())
            {
                var bytes = Encoding.UTF8.GetBytes(rawPassword ?? string.Empty);
                var hash = sha256.ComputeHash(bytes);
                var builder = new StringBuilder(hash.Length * 2);

                foreach (var b in hash)
                {
                    builder.Append(b.ToString("x2"));
                }

                return builder.ToString();
            }
        }

        /// <summary>
        /// 页面保护入口：只要求用户已登录且账号已通过审核。
        /// </summary>
        public static void RequireLogin()
        {
            if (IsLoggedIn())
            {
                return;
            }

            RedirectToLogin();
        }

        /// <summary>
        /// 要求账号已经通过审核，适合普通玩家中心、预约、钱包等页面。
        /// </summary>
        public static void RequireApprovedUser()
        {
            RequireAccess(HasApprovedUserAccess, "approval_required");
        }

        /// <summary>
        /// 要求系统管理员权限。
        /// </summary>
        public static void RequireAdmin()
        {
            RequireAccess(HasAdminAccess, "admin_required");
        }

        /// <summary>
        /// 要求可以进入后台工作台的角色。
        /// 包含管理员、财务、运营、客服、内容审核等后台角色。
        /// </summary>
        public static void RequireAdminConsole()
        {
            RequireAccess(HasAdminConsoleAccess, "admin_console_required");
        }

        /// <summary>
        /// 要求具备运营分析查看权限。
        /// </summary>
        public static void RequireAnalytics()
        {
            RequireAccess(HasAnalyticsAccess, "analytics_required");
        }

        /// <summary>
        /// 要求具备 DM/主持/控场相关权限。
        /// </summary>
        public static void RequireGameManager()
        {
            RequireAccess(HasGameManagerAccess, "dm_required");
        }

        /// <summary>
        /// 判断用户是否存在且审核通过。
        /// </summary>
        public static bool HasApprovedUserAccess(CurrentUserInfo currentUser)
        {
            return currentUser != null && currentUser.IsApproved;
        }

        /// <summary>
        /// 判断用户是否是系统管理员。
        /// </summary>
        public static bool HasAdminAccess(CurrentUserInfo currentUser)
        {
            return HasApprovedUserAccess(currentUser) && currentUser.IsAdmin;
        }

        /// <summary>
        /// 判断用户是否可以访问后台控制台。
        /// </summary>
        public static bool HasAdminConsoleAccess(CurrentUserInfo currentUser)
        {
            return HasApprovedUserAccess(currentUser) && currentUser.CanAccessAdminConsole;
        }

        /// <summary>
        /// 判断用户是否可以查看运营分析数据。
        /// </summary>
        public static bool HasAnalyticsAccess(CurrentUserInfo currentUser)
        {
            return HasApprovedUserAccess(currentUser) && currentUser.CanViewAnalytics;
        }

        /// <summary>
        /// 判断用户是否可以管理游戏房间。
        /// </summary>
        public static bool HasGameManagerAccess(CurrentUserInfo currentUser)
        {
            return HasApprovedUserAccess(currentUser) && currentUser.CanManageGameRoom;
        }

        /// <summary>
        /// 获取管理员用户；权限不足时返回 null，适合需要可选判断的页面。
        /// </summary>
        public static CurrentUserInfo GetAdminUser()
        {
            var currentUser = GetCurrentUser();
            return HasAdminAccess(currentUser) ? currentUser : null;
        }

        /// <summary>
        /// 获取游戏管理用户；权限不足时返回 null。
        /// </summary>
        public static CurrentUserInfo GetGameManagerUser()
        {
            var currentUser = GetCurrentUser();
            return HasGameManagerAccess(currentUser) ? currentUser : null;
        }

        /// <summary>
        /// 获取后台用户；权限不足时返回 null。
        /// </summary>
        public static CurrentUserInfo GetBackofficeUser()
        {
            var currentUser = GetCurrentUser();
            return HasAdminConsoleAccess(currentUser) ? currentUser : null;
        }

        /// <summary>
        /// 统一的访问控制实现。
        /// 未登录跳登录页；未审核会清 Session 并提示审核原因；角色不足则回首页。
        /// </summary>
        private static void RequireAccess(Func<CurrentUserInfo, bool> accessPredicate, string deniedReason = null)
        {
            var currentUser = GetCurrentUser();
            if (accessPredicate != null && accessPredicate(currentUser))
            {
                return;
            }

            if (currentUser == null)
            {
                RedirectToLogin();
                return;
            }

            if (!HasApprovedUserAccess(currentUser))
            {
                SignOut();
                RedirectToLogin(string.IsNullOrWhiteSpace(deniedReason) ? "approval_required" : deniedReason);
                return;
            }

            HttpContext.Current.Response.Redirect("~/Default.aspx", true);
        }

        /// <summary>
        /// 跳转登录页，并把当前地址放入 returnUrl，登录成功后可回到原页面。
        /// notice 用于向登录页传递“需要审核/需要后台权限”等提示。
        /// </summary>
        private static void RedirectToLogin(string notice = null)
        {
            var returnUrl = HttpUtility.UrlEncode(HttpContext.Current.Request.RawUrl);
            var redirectUrl = "~/Login.aspx?returnUrl=" + returnUrl;
            if (!string.IsNullOrWhiteSpace(notice))
            {
                redirectUrl += "&notice=" + HttpUtility.UrlEncode(notice);
            }

            HttpContext.Current.Response.Redirect(redirectUrl, true);
        }
    }
}
