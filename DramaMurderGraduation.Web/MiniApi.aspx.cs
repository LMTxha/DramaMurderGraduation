using System;
using System.Collections.Generic;
using System.Linq;
using System.Web.Script.Serialization;
using DramaMurderGraduation.Web.Data;
using DramaMurderGraduation.Web.Models;

namespace DramaMurderGraduation.Web
{
    /// <summary>
    /// 移动端接口后台逻辑，为移动端提供首页、剧本、预约和个人中心数据。
    /// </summary>
    public partial class MiniApiPage : System.Web.UI.Page
    {
        private readonly ContentRepository _contentRepository = new ContentRepository();
        private readonly AccountRepository _accountRepository = new AccountRepository();
        private readonly FeatureRepository _featureRepository = new FeatureRepository();
        private readonly JavaScriptSerializer _serializer = new JavaScriptSerializer();

        protected void Page_Load(object sender, EventArgs e)
        {
            Response.ContentType = "application/json";
            Response.ContentEncoding = System.Text.Encoding.UTF8;
            Response.Cache.SetCacheability(System.Web.HttpCacheability.NoCache);

            try
            {
                var action = (Request["action"] ?? string.Empty).Trim().ToLowerInvariant();
                switch (action)
                {
                    case "home":
                        WriteOk(new
                        {
                            settings = _contentRepository.GetSiteSettings(),
                            metrics = _contentRepository.GetSiteMetrics(),
                            announcements = _contentRepository.GetAnnouncements(5),
                            featuredScripts = _contentRepository.GetFeaturedScripts(6),
                            sessions = _contentRepository.GetUpcomingSessions(6),
                            reviews = _contentRepository.GetLatestReviews(5)
                        });
                        break;
                    case "genres":
                        WriteOk(_contentRepository.GetGenres());
                        break;
                    case "scripts":
                        WriteOk(_contentRepository.GetScripts(Request["keyword"], ParseNullableInt(Request["genreId"])));
                        break;
                    case "scriptdetail":
                        WriteScriptDetail();
                        break;
                    case "sessions":
                        WriteOk(_contentRepository.GetUpcomingSessions(50, ParseNullableInt(Request["scriptId"])));
                        break;
                    case "rooms":
                        WriteOk(_contentRepository.GetRooms());
                        break;
                    case "reviews":
                        WriteOk(_contentRepository.GetLatestReviews(30, ParseNullableInt(Request["scriptId"])));
                        break;
                    case "login":
                        Login();
                        break;
                    case "register":
                        Register();
                        break;
                    case "logout":
                        AuthManager.SignOut();
                        WriteOk(new { loggedIn = false });
                        break;
                    case "me":
                        WriteMe();
                        break;
                    case "reservations":
                        RequireLogin(user => WriteOk(_contentRepository.GetReservationsForUser(user.UserId, 30)));
                        break;
                    case "createreservation":
                        RequireLogin(CreateReservation);
                        break;
                    case "confirmreservation":
                        RequireLogin(ConfirmReservation);
                        break;
                    case "completereservation":
                        RequireLogin(CompleteReservation);
                        break;
                    case "createreview":
                        RequireLogin(CreateReview);
                        break;
                    case "createaftersale":
                        RequireLogin(CreateAfterSale);
                        break;
                    case "wallet":
                        RequireLogin(user => WriteOk(new
                        {
                            user,
                            transactions = _accountRepository.GetWalletTransactions(user.UserId, 30),
                            recharges = _accountRepository.GetRechargeRequests(user.UserId, 20)
                        }));
                        break;
                    case "recharge":
                        RequireLogin(SubmitRecharge);
                        break;
                    case "recommendations":
                        WriteOk(_featureRepository.GetTodayRecommendations(10));
                        break;
                    default:
                        WriteFail("未知接口动作。");
                        break;
                }
            }
            catch (Exception ex)
            {
                Response.StatusCode = 500;
                WriteFail("接口处理失败：" + ex.Message);
            }
        }

        private void WriteScriptDetail()
        {
            var scriptId = ParseInt(Request["id"]);
            var script = _contentRepository.GetScriptDetail(scriptId);
            if (script == null)
            {
                WriteFail("剧本不存在。");
                return;
            }

            WriteOk(new
            {
                script,
                characters = _contentRepository.GetCharactersByScript(scriptId),
                sessions = _contentRepository.GetUpcomingSessions(20, scriptId),
                reviews = _contentRepository.GetLatestReviews(10, scriptId),
                assets = _contentRepository.GetScriptAssets(scriptId)
            });
        }

        private void Login()
        {
            var body = ReadBody();
            var username = GetString(body, "username");
            var password = GetString(body, "password");
            var user = _accountRepository.Authenticate(username, password, Request.UserHostAddress, Request.UserAgent, out var message);
            if (user == null)
            {
                WriteFail(message);
                return;
            }

            var currentUser = AuthManager.CreateCurrentUser(user);
            AuthManager.SignIn(currentUser);
            WriteOk(currentUser, message);
        }

        private void Register()
        {
            var body = ReadBody();
            var request = new UserRegistrationRequest
            {
                Username = GetString(body, "username"),
                Password = GetString(body, "password"),
                DisplayName = GetString(body, "displayName"),
                Phone = GetString(body, "phone"),
                Email = GetString(body, "email")
            };

            var success = _accountRepository.Register(request, out var message, autoApprove: true);
            if (success)
            {
                WriteOk(new { registered = true }, "注册成功，可以直接登录。");
                return;
            }

            WriteFail(message);
        }

        private void WriteMe()
        {
            var user = AuthManager.GetCurrentUser();
            if (user == null)
            {
                WriteOk(new { loggedIn = false });
                return;
            }

            WriteOk(new { loggedIn = true, user });
        }

        private void CreateReservation(CurrentUserInfo user)
        {
            var body = ReadBody();
            var request = new BookingCreateRequest
            {
                UserId = user.UserId,
                SessionId = GetInt(body, "sessionId"),
                ContactName = GetString(body, "contactName"),
                Phone = GetString(body, "phone"),
                PlayerCount = GetInt(body, "playerCount"),
                Remark = GetString(body, "remark"),
                CouponId = GetNullableInt(body, "couponId")
            };

            var success = _contentRepository.CreateReservation(request, out var reservationId, out var message);
            if (success)
            {
                WriteOk(new { reservationId }, message);
                return;
            }

            WriteFail(message);
        }

        private void ConfirmReservation(CurrentUserInfo user)
        {
            var body = ReadBody();
            var reservationId = GetInt(body, "reservationId");
            var success = _contentRepository.ConfirmReservationByPlayer(reservationId, user.UserId, out var message);
            if (success)
            {
                WriteOk(new { reservationId }, message);
                return;
            }

            WriteFail(message);
        }

        private void CompleteReservation(CurrentUserInfo user)
        {
            var body = ReadBody();
            var reservationId = GetInt(body, "reservationId");
            var success = _contentRepository.CompleteReservationByPlayer(reservationId, user.UserId, out var message);
            if (success)
            {
                WriteOk(new { reservationId }, message);
                return;
            }

            WriteFail(message);
        }

        private void CreateReview(CurrentUserInfo user)
        {
            var body = ReadBody();
            var success = _contentRepository.CreateReservationReview(
                GetInt(body, "reservationId"),
                user.UserId,
                GetInt(body, "rating"),
                GetString(body, "content"),
                GetString(body, "highlightTag"),
                out var message);

            if (success)
            {
                WriteOk(new { reviewed = true }, message);
                return;
            }

            WriteFail(message);
        }

        private void CreateAfterSale(CurrentUserInfo user)
        {
            var body = ReadBody();
            var success = _contentRepository.CreateAfterSaleRequest(
                GetInt(body, "reservationId"),
                user.UserId,
                GetString(body, "requestType"),
                GetString(body, "reason"),
                GetDecimal(body, "requestedAmount"),
                string.Empty,
                out var message);

            if (success)
            {
                WriteOk(new { submitted = true }, message);
                return;
            }

            WriteFail(message);
        }

        private void SubmitRecharge(CurrentUserInfo user)
        {
            var body = ReadBody();
            var success = _accountRepository.SubmitRechargeRequest(
                user.UserId,
                GetString(body, "paymentMethod"),
                GetDecimal(body, "amount"),
                GetString(body, "paymentAccount"),
                out var message);

            if (success)
            {
                WriteOk(new { submitted = true }, message);
                return;
            }

            WriteFail(message);
        }

        private void RequireLogin(Action<CurrentUserInfo> action)
        {
            var user = AuthManager.GetCurrentUser();
            if (user == null || !user.IsApproved)
            {
                Response.StatusCode = 401;
                WriteFail("请先登录并确认账号已审核通过。");
                return;
            }

            action(user);
        }

        private Dictionary<string, object> ReadBody()
        {
            Request.InputStream.Position = 0;
            using (var reader = new System.IO.StreamReader(Request.InputStream))
            {
                var json = reader.ReadToEnd();
                if (string.IsNullOrWhiteSpace(json))
                {
                    return new Dictionary<string, object>();
                }

                return _serializer.Deserialize<Dictionary<string, object>>(json);
            }
        }

        private void WriteOk(object data, string message = "OK")
        {
            Response.Write(_serializer.Serialize(new { success = true, message, data }));
        }

        private void WriteFail(string message)
        {
            Response.Write(_serializer.Serialize(new { success = false, message, data = (object)null }));
        }

        private static int ParseInt(string value)
        {
            return int.TryParse(value, out var result) ? result : 0;
        }

        private static int? ParseNullableInt(string value)
        {
            return int.TryParse(value, out var result) ? (int?)result : null;
        }

        private static string GetString(IDictionary<string, object> values, string key)
        {
            return values.ContainsKey(key) && values[key] != null ? Convert.ToString(values[key]).Trim() : string.Empty;
        }

        private static int GetInt(IDictionary<string, object> values, string key)
        {
            return values.ContainsKey(key) && values[key] != null ? Convert.ToInt32(values[key]) : 0;
        }

        private static int? GetNullableInt(IDictionary<string, object> values, string key)
        {
            if (!values.ContainsKey(key) || values[key] == null || string.IsNullOrWhiteSpace(Convert.ToString(values[key])))
            {
                return null;
            }

            return Convert.ToInt32(values[key]);
        }

        private static decimal GetDecimal(IDictionary<string, object> values, string key)
        {
            return values.ContainsKey(key) && values[key] != null ? Convert.ToDecimal(values[key]) : 0M;
        }
    }
}
