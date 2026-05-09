namespace DramaMurderGraduation.Web.Models
{
    /// <summary>
    /// UserDesktopSettingsInfo 数据模型，用于在页面层和仓储层之间传递剧本杀业务数据。
    /// </summary>
    public class UserDesktopSettingsInfo
    {
        /// <summary>关联的用户主键。</summary>
        public int UserId { get; set; }
        /// <summary>页面或业务逻辑使用的数据字段。</summary>
        public string LoginConfirmMode { get; set; }
        /// <summary>页面或业务逻辑使用的数据字段。</summary>
        public bool KeepChatHistory { get; set; }
        /// <summary>页面或业务逻辑使用的数据字段。</summary>
        public string StoragePath { get; set; }
        /// <summary>页面或业务逻辑使用的数据字段。</summary>
        public int AutoDownloadMaxMb { get; set; }
        /// <summary>页面或业务逻辑使用的数据字段。</summary>
        public bool NotificationEnabled { get; set; }
        /// <summary>页面或业务逻辑使用的数据字段。</summary>
        public string ShortcutScheme { get; set; }
        /// <summary>页面或业务逻辑使用的数据字段。</summary>
        public bool PluginEnabled { get; set; }
        /// <summary>页面或业务逻辑使用的数据字段。</summary>
        public bool FriendRequestEnabled { get; set; }
        /// <summary>页面或业务逻辑使用的数据字段。</summary>
        public bool PhoneSearchEnabled { get; set; }
        /// <summary>页面或业务逻辑使用的数据字段。</summary>
        public bool ShowMomentsToStrangers { get; set; }
        /// <summary>页面或业务逻辑使用的数据字段。</summary>
        public bool UseEnterToSend { get; set; }
    }
}
