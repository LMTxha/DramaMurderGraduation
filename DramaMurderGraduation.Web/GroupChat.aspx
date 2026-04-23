<%@ Page Title="群聊 | 雾城剧本研究所" Language="C#" MasterPageFile="~/Site.Master" AutoEventWireup="true" CodeBehind="GroupChat.aspx.cs" Inherits="DramaMurderGraduation.Web.GroupChatPage" %>
<asp:Content ID="Content1" ContentPlaceHolderID="TitleContent" runat="server">
    群聊 | 雾城剧本研究所
</asp:Content>
<asp:Content ID="Content2" ContentPlaceHolderID="MainContent" runat="server">
    <section class="wechat-workbench group-chat-workbench" id="group-chat-panel">
        <aside class="wechat-list-pane group-member-pane">
            <a class="wx-secondary-btn" href="Friends.aspx#group-list">返回好友互动</a>
            <div class="wechat-pane-title compact">
                <h1><asp:Literal ID="litGroupNameSide" runat="server" /></h1>
                <span><asp:Literal ID="litMemberCount" runat="server" /> 位成员</span>
            </div>
            <asp:Repeater ID="rptMembers" runat="server">
                <ItemTemplate>
                    <article class="wechat-contact-row static">
                        <img src='<%# GetAvatarUrl(Eval("AvatarUrl")) %>' alt='<%# Eval("DisplayName") %>' />
                        <span><%# Eval("DisplayName") %></span>
                        <small><%# Convert.ToBoolean(Eval("IsOwner")) ? "群主" : Eval("PublicUserCode") %></small>
                    </article>
                </ItemTemplate>
            </asp:Repeater>
        </aside>

        <main class="wechat-main-pane">
            <section class="wechat-chat-view">
                <header class="wechat-chat-header">
                    <div>
                        <h1><asp:Literal ID="litGroupName" runat="server" /></h1>
                        <p><asp:Literal ID="litAnnouncement" runat="server" /></p>
                    </div>
                    <div class="wechat-chat-tools">
                        <asp:Button ID="btnTogglePinGroup" runat="server" Text="置顶" CssClass="wx-icon-button" OnClick="btnTogglePinGroup_Click" />
                        <details class="wechat-more-actions">
                            <summary class="wx-icon-button">更多</summary>
                            <div>
                                <a class="wx-plain-link" href="Friends.aspx#group-list">返回好友互动</a>
                                <asp:Button ID="btnMuteGroup" runat="server" Text="免打扰" CssClass="wx-plain-action" OnClick="btnMuteGroup_Click" />
                                <asp:Button ID="btnHideGroup" runat="server" Text="隐藏群聊" CssClass="wx-plain-action danger" OnClick="btnHideGroup_Click" />
                            </div>
                        </details>
                    </div>
                </header>

                <asp:Panel ID="pnlGroupMessage" runat="server" Visible="false" CssClass="status-message wx-chat-status">
                    <asp:Literal ID="litGroupMessage" runat="server" />
                </asp:Panel>

                <div class="wechat-message-thread">
                    <asp:Repeater ID="rptGroupMessages" runat="server">
                        <ItemTemplate>
                            <article class='<%# GetGroupBubbleClass(Eval("SenderUserId")) %>'>
                                <img class="wx-message-avatar" src='<%# GetAvatarUrl(Eval("SenderAvatarUrl")) %>' alt='<%# Eval("SenderDisplayName") %>' />
                                <div class="wx-bubble-body">
                                    <div class="chat-bubble-head">
                                        <strong><%# Eval("SenderDisplayName") %></strong>
                                        <span><%# GetMessageTypeLabel(Eval("MessageType")) %> · <%# Eval("CreatedAt", "{0:MM-dd HH:mm}") %></span>
                                    </div>
                                    <p><%# HtmlEncode(Eval("Content")) %></p>
                                    <%# RenderAttachment(Eval("AttachmentUrl")) %>
                                    <%# RenderLocation(Eval("LocationText")) %>
                                </div>
                            </article>
                        </ItemTemplate>
                    </asp:Repeater>
                </div>

                <footer class="wechat-input-panel">
                    <asp:DropDownList ID="ddlGroupMessageType" runat="server" CssClass="wx-mode-select" />
                    <asp:TextBox ID="txtGroupContent" runat="server" CssClass="wechat-compose" TextMode="MultiLine" Rows="4" placeholder="输入群聊内容，讨论组局、线索和到店安排" />
                    <details class="wechat-compose-options">
                        <summary>附件 / 位置</summary>
                        <div class="wechat-extra-inputs group-extra-inputs">
                            <asp:TextBox ID="txtGroupAttachmentUrl" runat="server" CssClass="wx-input" placeholder="附件地址，可为空" />
                            <asp:FileUpload ID="fuGroupAttachment" runat="server" CssClass="wx-input" />
                            <asp:TextBox ID="txtGroupLocation" runat="server" CssClass="wx-input" placeholder="位置说明" />
                        </div>
                    </details>
                    <asp:Button ID="btnSendGroupMessage" runat="server" Text="发送群消息" CssClass="wechat-send-btn" OnClick="btnSendGroupMessage_Click" />
                </footer>
            </section>
        </main>
    </section>
</asp:Content>
