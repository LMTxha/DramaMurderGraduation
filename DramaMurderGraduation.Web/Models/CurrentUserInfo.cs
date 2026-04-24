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

        public bool IsFinance
        {
            get { return string.Equals(RoleCode, "Finance", System.StringComparison.OrdinalIgnoreCase); }
        }

        public bool IsOperations
        {
            get
            {
                return string.Equals(RoleCode, "Ops", System.StringComparison.OrdinalIgnoreCase)
                    || string.Equals(RoleCode, "Operations", System.StringComparison.OrdinalIgnoreCase);
            }
        }

        public bool IsService
        {
            get
            {
                return string.Equals(RoleCode, "Service", System.StringComparison.OrdinalIgnoreCase)
                    || string.Equals(RoleCode, "CustomerService", System.StringComparison.OrdinalIgnoreCase);
            }
        }

        public bool IsContentReviewer
        {
            get
            {
                return string.Equals(RoleCode, "Content", System.StringComparison.OrdinalIgnoreCase)
                    || string.Equals(RoleCode, "Editor", System.StringComparison.OrdinalIgnoreCase);
            }
        }

        public bool CanManageGameRoom
        {
            get { return IsAdmin || IsDm; }
        }

        public bool CanAccessAdminConsole
        {
            get { return IsAdmin || IsFinance || IsOperations || IsService || IsContentReviewer; }
        }

        public bool CanViewAnalytics
        {
            get { return IsAdmin || IsFinance || IsOperations; }
        }

        public bool CanManageMembers
        {
            get { return IsAdmin; }
        }

        public bool CanManageFinance
        {
            get { return IsAdmin || IsFinance; }
        }

        public bool CanManageOperations
        {
            get { return IsAdmin || IsOperations || IsService; }
        }

        public bool CanManageContent
        {
            get { return IsAdmin || IsContentReviewer; }
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

                if (IsFinance)
                {
                    return "财务审核";
                }

                if (IsOperations)
                {
                    return "运营排期";
                }

                if (IsService)
                {
                    return "客服售后";
                }

                if (IsContentReviewer)
                {
                    return "内容审核";
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

                if (CanAccessAdminConsole)
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
