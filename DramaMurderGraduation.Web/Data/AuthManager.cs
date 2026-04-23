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
            return GetCurrentUser() != null;
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
            var currentUser = GetCurrentUser();
            if (currentUser != null)
            {
                return;
            }

            var returnUrl = HttpUtility.UrlEncode(HttpContext.Current.Request.RawUrl);
            HttpContext.Current.Response.Redirect("~/Login.aspx?returnUrl=" + returnUrl, true);
        }

        public static void RequireAdmin()
        {
            var currentUser = GetCurrentUser();
            if (currentUser != null && currentUser.IsAdmin)
            {
                return;
            }

            HttpContext.Current.Response.Redirect("~/Login.aspx", true);
        }
    }
}
