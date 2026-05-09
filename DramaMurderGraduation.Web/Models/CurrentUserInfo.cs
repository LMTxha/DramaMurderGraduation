namespace DramaMurderGraduation.Web.Models
{
    /// <summary>
    /// 当前登录用户在 Session 中保存的轻量视图模型。
    /// 它只保留页面授权和导航需要的字段，并把角色判断封装成可读的布尔属性。
    /// </summary>
    public class CurrentUserInfo
    {
        /// <summary>Users 表主键。</summary>
        public int UserId { get; set; }

        /// <summary>登录用户名。</summary>
        public string Username { get; set; }

        /// <summary>页面上展示的昵称。</summary>
        public string DisplayName { get; set; }

        /// <summary>对外展示的用户编号，用于好友搜索，避免暴露自增 Id。</summary>
        public string PublicUserCode { get; set; }

        /// <summary>用户手机号，页面可按需要脱敏展示。</summary>
        public string Phone { get; set; }

        /// <summary>角色编码，例如 Admin、DM、Finance、Ops、Service、Content、Player。</summary>
        public string RoleCode { get; set; }

        /// <summary>账号审核状态；只有 Approved 才允许进入受保护页面。</summary>
        public string ReviewStatus { get; set; }

        /// <summary>现金钱包余额。</summary>
        public decimal Balance { get; set; }

        /// <summary>
        /// 账号是否已通过管理员审核。
        /// </summary>
        public bool IsApproved
        {
            get { return string.Equals(ReviewStatus, "Approved", System.StringComparison.OrdinalIgnoreCase); }
        }

        /// <summary>
        /// 是否为系统管理员。管理员拥有所有后台能力。
        /// </summary>
        public bool IsAdmin
        {
            get { return string.Equals(RoleCode, "Admin", System.StringComparison.OrdinalIgnoreCase); }
        }

        /// <summary>
        /// 是否属于正式 DM 角色。
        /// Host、Director 不再默认获得游戏房间控制台权限。
        /// </summary>
        public bool IsDm
        {
            get
            {
                return string.Equals(RoleCode, "DM", System.StringComparison.OrdinalIgnoreCase);
            }
        }

        /// <summary>
        /// 是否为财务审核角色。
        /// </summary>
        public bool IsFinance
        {
            get { return string.Equals(RoleCode, "Finance", System.StringComparison.OrdinalIgnoreCase); }
        }

        /// <summary>
        /// 是否为运营排期角色；兼容 Ops 与 Operations 两种写法。
        /// </summary>
        public bool IsOperations
        {
            get
            {
                return string.Equals(RoleCode, "Ops", System.StringComparison.OrdinalIgnoreCase)
                    || string.Equals(RoleCode, "Operations", System.StringComparison.OrdinalIgnoreCase);
            }
        }

        /// <summary>
        /// 是否为客服/售后角色。
        /// </summary>
        public bool IsService
        {
            get
            {
                return string.Equals(RoleCode, "Service", System.StringComparison.OrdinalIgnoreCase)
                    || string.Equals(RoleCode, "CustomerService", System.StringComparison.OrdinalIgnoreCase);
            }
        }

        /// <summary>
        /// 是否为内容审核角色；用于剧本提交和内容审核相关页面。
        /// </summary>
        public bool IsContentReviewer
        {
            get
            {
                return string.Equals(RoleCode, "Content", System.StringComparison.OrdinalIgnoreCase)
                    || string.Equals(RoleCode, "Editor", System.StringComparison.OrdinalIgnoreCase);
            }
        }

        /// <summary>
        /// 是否可以进入 DM 主持台和游戏房间管理动作。
        /// </summary>
        public bool CanManageGameRoom
        {
            get { return IsAdmin || IsDm; }
        }

        /// <summary>
        /// 是否可以访问后台审核中心。
        /// </summary>
        public bool CanAccessAdminConsole
        {
            get { return IsAdmin || IsFinance || IsOperations || IsService || IsContentReviewer; }
        }

        /// <summary>
        /// 是否可以查看运营分析页面。
        /// </summary>
        public bool CanViewAnalytics
        {
            get { return IsAdmin || IsFinance || IsOperations; }
        }

        /// <summary>
        /// 是否可以管理会员账号和角色。
        /// </summary>
        public bool CanManageMembers
        {
            get { return IsAdmin; }
        }

        /// <summary>
        /// 是否可以处理充值、钱包和财务审核。
        /// </summary>
        public bool CanManageFinance
        {
            get { return IsAdmin || IsFinance; }
        }

        /// <summary>
        /// 是否可以处理预约、到店、售后等运营动作。
        /// </summary>
        public bool CanManageOperations
        {
            get { return IsAdmin || IsOperations || IsService; }
        }

        /// <summary>
        /// 是否可以审核和管理剧本内容。
        /// </summary>
        public bool CanManageContent
        {
            get { return IsAdmin || IsContentReviewer; }
        }

        /// <summary>
        /// 根据角色编码输出中文角色名，供导航和个人中心展示。
        /// </summary>
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

        /// <summary>
        /// 登录成功后的默认落地页。
        /// 后台角色优先进入审核中心，DM 进入主持台，普通玩家进入创作者/玩家入口。
        /// </summary>
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
