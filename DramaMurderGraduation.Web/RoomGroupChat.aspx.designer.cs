namespace DramaMurderGraduation.Web
{
    /// <summary>
    /// 房间群聊页控件字段声明，连接成员列表和聊天输入区。
    /// </summary>
    public partial class RoomGroupChatPage
    {
        protected global::System.Web.UI.WebControls.Panel pnlNotFound;
        protected global::System.Web.UI.WebControls.Panel pnlChat;
        protected global::System.Web.UI.WebControls.Literal litRoomName;
        protected global::System.Web.UI.WebControls.Literal litScriptName;
        protected global::System.Web.UI.WebControls.Literal litSessionTime;
        protected global::System.Web.UI.WebControls.HyperLink lnkBackRoom;
        protected global::System.Web.UI.WebControls.HyperLink lnkBackLobby;
        protected global::System.Web.UI.WebControls.Repeater rptParticipants;
        protected global::System.Web.UI.WebControls.Panel pnlFeedback;
        protected global::System.Web.UI.WebControls.Literal litFeedback;
        protected global::System.Web.UI.WebControls.Repeater rptMessages;
        protected global::System.Web.UI.WebControls.TextBox txtMessage;
        protected global::System.Web.UI.WebControls.Button btnSend;
        protected global::System.Web.UI.WebControls.Button btnRefresh;
    }
}
