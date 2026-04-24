namespace DramaMurderGraduation.Web.Models
{
    public class CurrentUserInfo
    {
        public int UserId { get; set; }
        public string Username { get; set; }
        public string DisplayName { get; set; }
        public string PublicUserCode { get; set; }
        public string Phone { get; set; }
        public string RoleCode { get; set; }
        public string ReviewStatus { get; set; }
        public decimal Balance { get; set; }

        public bool IsApproved
        {
            get { return string.Equals(ReviewStatus, "Approved", System.StringComparison.OrdinalIgnoreCase); }
        }

        public bool IsAdmin
        {
            get { return string.Equals(RoleCode, "Admin", System.StringComparison.OrdinalIgnoreCase); }
        }

        public bool IsDm
        {
            get
            {
                return string.Equals(RoleCode, "DM", System.StringComparison.OrdinalIgnoreCase)
                    || string.Equals(RoleCode, "Host", System.StringComparison.OrdinalIgnoreCase)
                    || string.Equals(RoleCode, "Director", System.StringComparison.OrdinalIgnoreCase);
            }
        }

        public bool CanManageGameRoom
        {
            get { return IsAdmin || IsDm; }
        }

        public string RoleDisplayName
        {
            get
            {
                if (IsAdmin)
                {
                    return "系统管理员";
                }

                if (string.Equals(RoleCode, "DM", System.StringComparison.OrdinalIgnoreCase))
                {
                    return "主持 DM";
                }

                if (string.Equals(RoleCode, "Host", System.StringComparison.OrdinalIgnoreCase))
                {
                    return "主持人";
                }

                if (string.Equals(RoleCode, "Director", System.StringComparison.OrdinalIgnoreCase))
                {
                    return "控场导演";
                }

                return "玩家";
            }
        }

        public string DefaultLandingUrl
        {
            get
            {
                if (IsAdmin)
                {
                    return "~/AdminReview.aspx";
                }

                if (CanManageGameRoom)
                {
                    return "~/DmDashboard.aspx";
                }

                return "~/CreatorCenter.aspx";
            }
        }
    }
}
