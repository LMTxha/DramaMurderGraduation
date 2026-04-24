using System;
using System.Security.Cryptography;
using System.Text;
using System.Web;
using DramaMurderGraduation.Web.Models;

namespace DramaMurderGraduation.Web.Data
{
    public static class AuthManager
    {
        private const string SessionKey = "CurrentUser";

        public static CurrentUserInfo GetCurrentUser()
        {
            return HttpContext.Current?.Session?[SessionKey] as CurrentUserInfo;
        }

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

        public static void SignIn(CurrentUserInfo user)
        {
            HttpContext.Current.Session[SessionKey] = user;
        }

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

        public static void SignOut()
        {
            if (HttpContext.Current?.Session == null)
            {
                return;
            }

            HttpContext.Current.Session.Remove(SessionKey);
        }

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

        public static void RequireLogin()
        {
            if (IsLoggedIn())
            {
                return;
            }

            RedirectToLogin();
        }

        public static void RequireApprovedUser()
        {
            RequireAccess(HasApprovedUserAccess, "approval_required");
        }

        public static void RequireAdmin()
        {
            RequireAccess(HasAdminAccess, "admin_required");
        }

        public static void RequireGameManager()
        {
            RequireAccess(HasGameManagerAccess, "dm_required");
        }

        public static bool HasApprovedUserAccess(CurrentUserInfo currentUser)
        {
            return currentUser != null
                && string.Equals(currentUser.ReviewStatus, "Approved", StringComparison.OrdinalIgnoreCase);
        }

        public static bool HasAdminAccess(CurrentUserInfo currentUser)
        {
            return HasApprovedUserAccess(currentUser) && currentUser.IsAdmin;
        }

        public static bool HasGameManagerAccess(CurrentUserInfo currentUser)
        {
            return HasApprovedUserAccess(currentUser) && currentUser.CanManageGameRoom;
        }

        public static CurrentUserInfo GetAdminUser()
        {
            var currentUser = GetCurrentUser();
            return HasAdminAccess(currentUser) ? currentUser : null;
        }

        public static CurrentUserInfo GetGameManagerUser()
        {
            var currentUser = GetCurrentUser();
            return HasGameManagerAccess(currentUser) ? currentUser : null;
        }

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
