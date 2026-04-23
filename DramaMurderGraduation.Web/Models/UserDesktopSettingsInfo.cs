namespace DramaMurderGraduation.Web.Models
{
    public class UserDesktopSettingsInfo
    {
        public int UserId { get; set; }
        public string LoginConfirmMode { get; set; }
        public bool KeepChatHistory { get; set; }
        public string StoragePath { get; set; }
        public int AutoDownloadMaxMb { get; set; }
        public bool NotificationEnabled { get; set; }
        public string ShortcutScheme { get; set; }
        public bool PluginEnabled { get; set; }
        public bool FriendRequestEnabled { get; set; }
        public bool PhoneSearchEnabled { get; set; }
        public bool ShowMomentsToStrangers { get; set; }
        public bool UseEnterToSend { get; set; }
    }
}
