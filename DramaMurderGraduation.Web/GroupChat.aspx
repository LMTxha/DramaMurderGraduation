<%@ Page Title="群聊 | 雾城剧本研究所" Language="C#" MasterPageFile="~/Site.Master" AutoEventWireup="true" CodeBehind="GroupChat.aspx.cs" Inherits="DramaMurderGraduation.Web.GroupChatPage" %>
<%-- 页面用途：GroupChat 页面负责承载对应功能的 Web Forms 标记、服务端控件和前端布局。 --%>
<asp:Content ID="Content1" ContentPlaceHolderID="TitleContent" runat="server">
    群聊 | 雾城剧本研究所
</asp:Content>
<asp:Content ID="Content2" ContentPlaceHolderID="MainContent" runat="server">
    <%-- 页面分区：把当前页面内容按业务模块拆分展示。 --%>
    <section class="wechat-workbench group-chat-workbench" id="group-chat-panel">
        <aside class="wechat-list-pane group-member-pane">
            <a class="wx-secondary-btn" href="Friends.aspx#group-list">返回好友互动</a>
            <div class="wechat-pane-title compact">
                <h1><asp:Literal ID="litGroupNameSide" runat="server" /></h1>
                <span><asp:Literal ID="litMemberCount" runat="server" /> 位成员</span>
            </div>
            <%-- 数据列表控件 rptMembers：后台绑定集合数据后，按 ItemTemplate 循环渲染每条记录。 --%>
            <asp:Repeater ID="rptMembers" runat="server">
                <%-- 列表项模板：定义 Repeater 中每一条业务记录的 HTML 结构和绑定字段。 --%>
                <ItemTemplate>
                    <%-- 内容卡片：用于组织当前模块中的一组相关信息。 --%>
                    <article class="wechat-contact-row static">
                        <img src='<%# GetAvatarUrl(Eval("AvatarUrl")) %>' alt='<%# Eval("DisplayName") %>' />
                        <span><%# Eval("DisplayName") %></span>
                        <small><%# Convert.ToBoolean(Eval("IsOwner")) ? "群主" : Eval("PublicUserCode") %></small>
                    </article>
                </ItemTemplate>
            </asp:Repeater>
        </aside>

        <main class="wechat-main-pane">
            <%-- 页面分区：把当前页面内容按业务模块拆分展示。 --%>
            <section class="wechat-chat-view">
                <header class="wechat-chat-header">
                    <div>
                        <h1><asp:Literal ID="litGroupName" runat="server" /></h1>
                        <p><asp:Literal ID="litAnnouncement" runat="server" /></p>
                    </div>
                    <div class="wechat-chat-tools">
                        <%-- 操作按钮 btnTogglePinGroup：点击后触发后台事件处理当前业务动作。 --%>
                        <asp:Button ID="btnTogglePinGroup" runat="server" Text="置顶" CssClass="wx-icon-button" OnClick="btnTogglePinGroup_Click" />
                        <details class="wechat-more-actions">
                            <summary class="wx-icon-button">更多</summary>
                            <div>
                                <a class="wx-plain-link" href="Friends.aspx#group-list">返回好友互动</a>
                                <%-- 操作按钮 btnMuteGroup：点击后触发后台事件处理当前业务动作。 --%>
                                <asp:Button ID="btnMuteGroup" runat="server" Text="免打扰" CssClass="wx-plain-action" OnClick="btnMuteGroup_Click" />
                                <%-- 操作按钮 btnHideGroup：点击后触发后台事件处理当前业务动作。 --%>
                                <asp:Button ID="btnHideGroup" runat="server" Text="隐藏群聊" CssClass="wx-plain-action danger" OnClick="btnHideGroup_Click" />
                            </div>
                        </details>
                    </div>
                </header>

                <%-- 面板控件 pnlGroupMessage：后台可通过 Visible/CssClass 控制整块内容是否显示以及提示样式。 --%>
                <asp:Panel ID="pnlGroupMessage" runat="server" Visible="false" CssClass="status-message wx-chat-status">
                    <asp:Literal ID="litGroupMessage" runat="server" />
                </asp:Panel>

                <div class="wechat-message-thread">
                    <%-- 数据列表控件 rptGroupMessages：后台绑定集合数据后，按 ItemTemplate 循环渲染每条记录。 --%>
                    <asp:Repeater ID="rptGroupMessages" runat="server">
                        <%-- 列表项模板：定义 Repeater 中每一条业务记录的 HTML 结构和绑定字段。 --%>
                        <ItemTemplate>
                            <%-- 内容卡片：用于组织当前模块中的一组相关信息。 --%>
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
                    <%-- 下拉控件 ddlGroupMessageType：提供状态、分类或角色等固定选项。 --%>
                    <asp:DropDownList ID="ddlGroupMessageType" runat="server" CssClass="wx-mode-select" />
                    <%-- 输入控件 txtGroupContent：接收用户输入或展示后台已有备注。 --%>
                    <asp:TextBox ID="txtGroupContent" runat="server" CssClass="wechat-compose" TextMode="MultiLine" Rows="4" placeholder="输入群聊内容，讨论组局、线索和到店安排" />
                    <details class="wechat-compose-options">
                        <summary>附件 / 位置</summary>
                        <div class="wechat-extra-inputs group-extra-inputs">
                            <%-- 输入控件 txtGroupAttachmentUrl：接收用户输入或展示后台已有备注。 --%>
                            <asp:TextBox ID="txtGroupAttachmentUrl" runat="server" CssClass="wx-input" placeholder="附件地址，可为空" />
                            <asp:FileUpload ID="fuGroupAttachment" runat="server" CssClass="wx-input" />
                            <%-- 输入控件 txtGroupLocation：接收用户输入或展示后台已有备注。 --%>
                            <asp:TextBox ID="txtGroupLocation" runat="server" CssClass="wx-input" placeholder="位置说明" />
                        </div>
                    </details>
                    <%-- 操作按钮 btnSendGroupMessage：点击后触发后台事件处理当前业务动作。 --%>
                    <asp:Button ID="btnSendGroupMessage" runat="server" Text="发送群消息" CssClass="wechat-send-btn" OnClick="btnSendGroupMessage_Click" />
                </footer>
            </section>
        </main>
    </section>
</asp:Content>
