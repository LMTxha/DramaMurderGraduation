<%@ Page Title="好友系统 | 雾城剧本研究所" Language="C#" MasterPageFile="~/Site.Master" AutoEventWireup="true" CodeBehind="Friends.aspx.cs" Inherits="DramaMurderGraduation.Web.FriendsPage" %>
<%-- 页面用途：Friends 页面负责承载对应功能的 Web Forms 标记、服务端控件和前端布局。 --%>
<asp:Content ID="Content1" ContentPlaceHolderID="TitleContent" runat="server">
    好友系统 | 雾城剧本研究所
</asp:Content>
<asp:Content ID="Content2" ContentPlaceHolderID="MainContent" runat="server">
    <%-- 页面分区：把当前页面内容按业务模块拆分展示。 --%>
    <section class="wechat-workbench <%= GetWorkbenchModeCss() %>" id="chat-panel">
        <aside class="wechat-rail">
            <a class="wechat-avatar-link" href="Settings.aspx">
                <img src="<%= GetCurrentAvatarUrl() %>" alt="<%= Server.HtmlEncode(GetCurrentDisplayName()) %>" />
            </a>
            <nav class="wechat-rail-nav">
                <a class="<%= GetModeCss("chat") %>" href="Friends.aspx" title="聊天"><span class="wx-icon wx-icon-chat"></span></a>
                <a class="<%= GetModeCss("contacts") %>" href="Friends.aspx?mode=contacts" title="通讯录"><span class="wx-icon wx-icon-contacts"></span></a>
                <a class="<%= GetModeCss("moments") %>" href="Friends.aspx?mode=moments" title="朋友圈"><span class="wx-icon wx-icon-moments"></span></a>
                <a class="<%= GetModeCss("wallet") %>" href="Friends.aspx?mode=wallet" title="红包与转账"><span class="wx-icon wx-icon-wallet"></span></a>
                <a class="<%= GetModeCss("settings") %>" href="Friends.aspx?mode=settings" title="账号设置"><span class="wx-icon wx-icon-settings"></span></a>
            </nav>
            <div class="wechat-rail-actions">
                <a class="wechat-rail-bottom" href="Default.aspx" title="返回首页"><span class="wx-icon wx-icon-home"></span></a>
                <a class="wechat-rail-bottom" href="Settings.aspx" title="完整设置"><span class="wx-icon wx-icon-menu"></span></a>
            </div>
        </aside>

        <aside class="wechat-list-pane">
            <div class="wechat-search-row">
                <div class="wechat-search-box">
                    <span></span>
                    <%-- 输入控件 txtFriendSearch：接收用户输入或展示后台已有备注。 --%>
                    <asp:TextBox ID="txtFriendSearch" runat="server" placeholder="搜索" />
                </div>
                <details class="wechat-plus-menu">
                    <summary title="更多">+</summary>
                    <div class="wechat-plus-popover">
                        <a href="Friends.aspx#group-create-panel"><span class="wx-menu-icon">群</span>发起群聊</a>
                        <a href="Friends.aspx?mode=contacts#friend-add-panel"><span class="wx-menu-icon">友</span>添加朋友</a>
                        <a href="Friends.aspx#quick-note-panel"><span class="wx-menu-icon">记</span>新建笔记</a>
                    </div>
                </details>
            </div>
            <div class="wechat-search-actions">
                <%-- 操作按钮 btnSearchFriends：点击后触发后台事件处理当前业务动作。 --%>
                <asp:Button ID="btnSearchFriends" runat="server" Text="搜索" CssClass="wx-text-btn" OnClick="btnSearchFriends_Click" />
                <%-- 操作按钮 btnClearFriendSearch：点击后触发后台事件处理当前业务动作。 --%>
                <asp:Button ID="btnClearFriendSearch" runat="server" Text="清空" CssClass="wx-text-btn" OnClick="btnClearFriendSearch_Click" />
            </div>

            <% if (IsContactsView) { %>
            <div class="wechat-contact-groups">
                <a href="#service-accounts"><span class="wx-chevron"></span><strong>服务号</strong><em><%= ServiceAccountCount %></em></a>
                <a href="#group-list"><span class="wx-chevron"></span><strong>群聊联系人</strong><em><%= GroupConversationCount %></em></a>
                <a href="#request-panel"><span class="wx-chevron"></span><strong>新的朋友</strong><em><asp:Literal ID="litPendingRequestCount" runat="server" /></em></a>
                <a href="#contact-directory" class="open"><span class="wx-chevron"></span><strong>联系人</strong><em><asp:Literal ID="litFriendCount" runat="server" /></em></a>
            </div>
            <div class="wechat-alpha">A</div>
            <%-- 数据列表控件 rptContactFriends：后台绑定集合数据后，按 ItemTemplate 循环渲染每条记录。 --%>
            <asp:Repeater ID="rptContactFriends" runat="server">
                <%-- 列表项模板：定义 Repeater 中每一条业务记录的 HTML 结构和绑定字段。 --%>
                <ItemTemplate>
                    <a class="wechat-contact-row" href='<%# GetFriendLink(Eval("UserId")) %>'>
                        <img src='<%# GetAvatarUrl(Eval("AvatarUrl")) %>' alt='<%# Eval("DisplayName") %>' />
                        <span><%# Eval("DisplayName") %></span>
                    </a>
                </ItemTemplate>
            </asp:Repeater>
            <% } else { %>
            <%-- 数据列表控件 rptFriendSummaries：后台绑定集合数据后，按 ItemTemplate 循环渲染每条记录。 --%>
            <asp:Repeater ID="rptFriendSummaries" runat="server">
                <%-- 列表项模板：定义 Repeater 中每一条业务记录的 HTML 结构和绑定字段。 --%>
                <ItemTemplate>
                    <a class='<%# GetFriendItemCss(Eval("FriendUserId")) %>' href='<%# GetFriendLink(Eval("FriendUserId")) %>'>
                        <img src='<%# GetAvatarUrl(Eval("AvatarUrl")) %>' alt='<%# Eval("DisplayName") %>' />
                        <div class="friend-summary-copy">
                            <div class="friend-summary-head">
                                <strong><%# Eval("DisplayName") %></strong>
                                <span><%# FormatChatSummaryTime(Eval("LastMessageAt")) %></span>
                            </div>
                            <p><%# RenderHighlightedPreview(Eval("LastMessagePreview")) %></p>
                            <small><%# Eval("ReputationLevel") %> · <%# Eval("FavoriteGenre") %> <%# RenderUnreadBadge(Eval("UnreadCount")) %></small>
                        </div>
                    </a>
                </ItemTemplate>
            </asp:Repeater>
            <% } %>
        </aside>

        <main class="wechat-main-pane">
            <a class="wechat-page-back" href="Default.aspx" data-history-back title="返回上一级">
                <span class="wechat-page-back-arrow" aria-hidden="true"></span>
                <span>返回上一级</span>
            </a>
            <% if (IsContactsView) { %>
            <%-- 页面分区：把当前页面内容按业务模块拆分展示。 --%>
            <section class="wechat-contact-home" id="contact-directory">
                <header class="wechat-pane-title contact-title">
                    <h1>通讯录</h1>
                    <span>好友、申请和群聊集中处理</span>
                </header>
                <div class="wx-contact-summary-grid">
                    <%-- 内容卡片：用于组织当前模块中的一组相关信息。 --%>
                    <article>
                        <strong><asp:Literal ID="litContactFriendTotal" runat="server" /></strong>
                        <span>联系人</span>
                    </article>
                    <%-- 内容卡片：用于组织当前模块中的一组相关信息。 --%>
                    <article>
                        <strong><asp:Literal ID="litContactRequestTotal" runat="server" /></strong>
                        <span>新的朋友</span>
                    </article>
                    <%-- 内容卡片：用于组织当前模块中的一组相关信息。 --%>
                    <article>
                        <strong><%= GroupConversationCount %></strong>
                        <span>群聊</span>
                    </article>
                </div>
                <div class="wx-contact-guide">
                    <h2>常用操作</h2>
                    <a href="#friend-add-panel">添加朋友</a>
                    <a href="#request-panel">处理新的朋友</a>
                    <a href="#group-list">查看群聊</a>
                </div>
            </section>
            <aside class="wechat-side-drawer">
                <%-- 页面分区：把当前页面内容按业务模块拆分展示。 --%>
                <section class="wx-card" id="friend-add-panel">
                    <h2>添加朋友</h2>
                    <p>通过推荐玩家或账号 ID 发起申请，申请记录会写入数据库。</p>
                    <%-- 面板控件 pnlFriendMessage：后台可通过 Visible/CssClass 控制整块内容是否显示以及提示样式。 --%>
                    <asp:Panel ID="pnlFriendMessage" runat="server" Visible="false" CssClass="status-message">
                        <asp:Literal ID="litFriendMessage" runat="server" />
                    </asp:Panel>
                    <label>选择玩家</label>
                    <%-- 下拉控件 ddlFriendCandidate：提供状态、分类或角色等固定选项。 --%>
                    <asp:DropDownList ID="ddlFriendCandidate" runat="server" CssClass="wx-input" />
                    <label>账号 ID</label>
                    <%-- 输入控件 txtFriendAccountId：接收用户输入或展示后台已有备注。 --%>
                    <asp:TextBox ID="txtFriendAccountId" runat="server" CssClass="wx-input" placeholder="例如 DM000123 或 PLAYER_1001" />
                    <label>申请留言</label>
                    <%-- 输入控件 txtFriendRequestMessage：接收用户输入或展示后台已有备注。 --%>
                    <asp:TextBox ID="txtFriendRequestMessage" runat="server" CssClass="wx-input" />
                    <div class="wx-action-row">
                        <%-- 操作按钮 btnSendFriendRequest：点击后触发后台事件处理当前业务动作。 --%>
                        <asp:Button ID="btnSendFriendRequest" runat="server" Text="从推荐列表发送" CssClass="wx-primary-btn" OnClick="btnSendFriendRequest_Click" />
                        <%-- 操作按钮 btnSendFriendRequestByCode：点击后触发后台事件处理当前业务动作。 --%>
                        <asp:Button ID="btnSendFriendRequestByCode" runat="server" Text="按 ID 添加" CssClass="wx-secondary-btn" OnClick="btnSendFriendRequestByCode_Click" />
                    </div>
                </section>

                <%-- 页面分区：把当前页面内容按业务模块拆分展示。 --%>
                <section class="wx-card" id="request-panel">
                    <h2>新的朋友</h2>
                    <p class="wx-section-hint">收到好友申请后，可以直接点击接受。接受成功后会自动建立好友关系并打开私聊。</p>
                    <% if (!HasPendingFriendRequests) { %>
                    <%-- 内容卡片：用于组织当前模块中的一组相关信息。 --%>
                    <article class="wx-request-empty">
                        <strong>暂无新的好友申请</strong>
                        <p>别人通过账号 ID 添加你时，会出现在这里。</p>
                    </article>
                    <% } %>
                    <%-- 数据列表控件 rptIncomingFriendRequests：后台绑定集合数据后，按 ItemTemplate 循环渲染每条记录。 --%>
                    <asp:Repeater ID="rptIncomingFriendRequests" runat="server" OnItemCommand="rptIncomingFriendRequests_ItemCommand">
                        <%-- 列表项模板：定义 Repeater 中每一条业务记录的 HTML 结构和绑定字段。 --%>
                        <ItemTemplate>
                            <%-- 内容卡片：用于组织当前模块中的一组相关信息。 --%>
                            <article class="wx-friend-request-card">
                                <img src='<%# GetAvatarUrl(Eval("SenderAvatarUrl")) %>' alt='<%# Eval("SenderDisplayName") %>' />
                                <div class="wx-request-main">
                                    <div class="wx-request-head">
                                        <strong><%# Eval("SenderDisplayName") %></strong>
                                        <small><%# Eval("CreatedAt", "{0:MM-dd HH:mm}") %></small>
                                    </div>
                                    <span><%# string.IsNullOrWhiteSpace(Convert.ToString(Eval("SenderPublicUserCode"))) ? "未设置账号 ID" : Eval("SenderPublicUserCode") %></span>
                                    <p><%# string.IsNullOrWhiteSpace(Convert.ToString(Eval("RequestMessage"))) ? "对方请求添加你为好友。" : Eval("RequestMessage") %></p>
                                </div>
                                <div class="wx-request-actions">
                                    <%-- 操作按钮 btnAcceptFriend：点击后触发后台事件处理当前业务动作。 --%>
                                    <asp:LinkButton ID="btnAcceptFriend" runat="server" CssClass="wx-accept-link" CommandName="Accept" CommandArgument='<%# GetFriendRequestCommandArgument(Eval("Id"), Eval("SenderUserId")) %>'>接受</asp:LinkButton>
                                    <%-- 操作按钮 btnRejectFriend：点击后触发后台事件处理当前业务动作。 --%>
                                    <asp:LinkButton ID="btnRejectFriend" runat="server" CssClass="wx-reject-link" CommandName="Reject" CommandArgument='<%# GetFriendRequestCommandArgument(Eval("Id"), Eval("SenderUserId")) %>'>拒绝</asp:LinkButton>
                                </div>
                            </article>
                        </ItemTemplate>
                    </asp:Repeater>
                </section>

                <%-- 页面分区：把当前页面内容按业务模块拆分展示。 --%>
                <section class="wx-card" id="group-list">
                    <h2>群聊</h2>
                    <%-- 数据列表控件 rptChatGroups：后台绑定集合数据后，按 ItemTemplate 循环渲染每条记录。 --%>
                    <asp:Repeater ID="rptChatGroups" runat="server">
                        <%-- 列表项模板：定义 Repeater 中每一条业务记录的 HTML 结构和绑定字段。 --%>
                        <ItemTemplate>
                            <a class="wx-request-card group-chat-card" href='GroupChat.aspx?groupId=<%# Eval("GroupId") %>'>
                                <strong><%# Eval("Name") %></strong>
                                <p><%# Eval("LastMessagePreview") %></p>
                                <small><%# Eval("MemberCount") %> 位成员 · <%# FormatChatSummaryTime(Eval("LastMessageAt")) %> <%# RenderUnreadBadge(Eval("UnreadCount")) %></small>
                            </a>
                        </ItemTemplate>
                    </asp:Repeater>
                </section>
            </aside>
            <% } else if (IsSettingsView) { %>
            <%-- 页面分区：把当前页面内容按业务模块拆分展示。 --%>
            <section class="wechat-settings-view">
                <a class="wx-close" href="Friends.aspx">×</a>
                <nav class="wx-settings-nav">
                    <a class="active" href="Settings.aspx"><span class="wx-icon wx-icon-contacts"></span>账号与存储</a>
                    <a href="Settings.aspx#general"><span class="wx-icon wx-icon-settings"></span>通用</a>
                    <a href="Settings.aspx#shortcut"><span class="wx-icon wx-icon-menu"></span>快捷键</a>
                    <a href="Settings.aspx#notice"><span class="wx-icon wx-icon-chat"></span>通知</a>
                    <a href="Settings.aspx#plugin"><span class="wx-icon wx-icon-moments"></span>插件</a>
                    <a href="Settings.aspx#about"><span class="wx-icon wx-icon-wallet"></span>关于系统</a>
                </nav>
                <div class="wx-settings-cards">
                    <%-- 页面分区：把当前页面内容按业务模块拆分展示。 --%>
                    <section class="wx-settings-card">
                        <div class="wx-account-head">
                            <img src="<%= GetCurrentAvatarUrl() %>" alt="<%= Server.HtmlEncode(GetCurrentDisplayName()) %>" />
                            <div>
                                <strong><%= Server.HtmlEncode(GetCurrentDisplayName()) %></strong>
                                <span><%= Server.HtmlEncode(GetCurrentPublicCode()) %></span>
                            </div>
                            <%-- 操作按钮 btnLogoutFromFriends：点击后触发后台事件处理当前业务动作。 --%>
                            <asp:LinkButton ID="btnLogoutFromFriends" runat="server" CssClass="wx-secondary-btn" OnClick="btnLogoutFromFriends_Click">退出登录</asp:LinkButton>
                        </div>
                        <div class="wx-setting-line">
                            <div><strong>登录方式</strong><p>在本机登录账号需手机确认或扫码登录。</p></div>
                            <span class="wx-choice"><%= Server.HtmlEncode(CurrentDesktopSettings.LoginConfirmMode) %></span>
                        </div>
                        <div class="wx-setting-line">
                            <strong>保留聊天记录</strong>
                            <span class='<%= CurrentDesktopSettings.KeepChatHistory ? "wx-switch on" : "wx-switch" %>'></span>
                        </div>
                    </section>
                    <%-- 页面分区：把当前页面内容按业务模块拆分展示。 --%>
                    <section class="wx-settings-card">
                        <div class="wx-setting-line">
                            <div><strong>存储空间</strong><p>含部分历史版本数据。</p></div>
                            <a class="wx-secondary-btn" href="Settings.aspx#storage">管理</a>
                        </div>
                        <div class="wx-setting-line">
                            <div><strong>存储位置</strong><p class="wx-path"><%= Server.HtmlEncode(CurrentDesktopSettings.StoragePath) %></p></div>
                            <a class="wx-secondary-btn" href="Settings.aspx#storage">更改</a>
                        </div>
                        <div class="wx-setting-line">
                            <strong>自动下载小于 <%= CurrentDesktopSettings.AutoDownloadMaxMb %> MB 的文件</strong>
                            <span class="wx-switch on"></span>
                        </div>
                        <a class="wx-secondary-btn clear-history" href="#hidden-chat-panel">清理/恢复会话</a>
                    </section>
                </div>
            </section>
            <% } else if (IsMomentsView) { %>
            <%-- 页面分区：把当前页面内容按业务模块拆分展示。 --%>
            <section class="wechat-moments-view" id="moments-panel">
                <header class="wechat-pane-title"><h1>朋友圈</h1><span><asp:Literal ID="litMomentCount" runat="server" /> 条动态</span></header>
                <%-- 页面分区：把当前页面内容按业务模块拆分展示。 --%>
                <section class="wx-card">
                    <%-- 面板控件 pnlMomentMessage：后台可通过 Visible/CssClass 控制整块内容是否显示以及提示样式。 --%>
                    <asp:Panel ID="pnlMomentMessage" runat="server" Visible="false" CssClass="status-message">
                        <asp:Literal ID="litMomentMessage" runat="server" />
                    </asp:Panel>
                    <label>分享内容</label>
                    <%-- 输入控件 txtMomentContent：接收用户输入或展示后台已有备注。 --%>
                    <asp:TextBox ID="txtMomentContent" runat="server" CssClass="wx-input wx-textarea" TextMode="MultiLine" Rows="4" />
                    <label>图片地址</label>
                    <%-- 输入控件 txtMomentImageUrl：接收用户输入或展示后台已有备注。 --%>
                    <asp:TextBox ID="txtMomentImageUrl" runat="server" CssClass="wx-input" />
                    <label>上传图片</label>
                    <asp:FileUpload ID="fuMomentImage" runat="server" CssClass="wx-input" />
                    <label>可见范围</label>
                    <%-- 下拉控件 ddlMomentVisibility：提供状态、分类或角色等固定选项。 --%>
                    <asp:DropDownList ID="ddlMomentVisibility" runat="server" CssClass="wx-input" />
                    <label>位置</label>
                    <%-- 输入控件 txtMomentLocation：接收用户输入或展示后台已有备注。 --%>
                    <asp:TextBox ID="txtMomentLocation" runat="server" CssClass="wx-input" />
                    <%-- 操作按钮 btnCreateMoment：点击后触发后台事件处理当前业务动作。 --%>
                    <asp:Button ID="btnCreateMoment" runat="server" Text="发布朋友圈" CssClass="wx-primary-btn" OnClick="btnCreateMoment_Click" />
                </section>
                <% if (HasReplyTarget) { %>
                <div class="status-message success reply-status">
                    <span>正在回复 <strong><%= Server.HtmlEncode(ReplyTargetDisplayName) %></strong> 的评论。</span>
                    <%-- 操作按钮 btnCancelReply：点击后触发后台事件处理当前业务动作。 --%>
                    <asp:LinkButton ID="btnCancelReply" runat="server" CssClass="text-link strong" OnClick="btnCancelReply_Click">取消回复</asp:LinkButton>
                </div>
                <% } %>
                <div class="moment-list wx-moment-list">
                    <%-- 数据列表控件 rptMoments：后台绑定集合数据后，按 ItemTemplate 循环渲染每条记录。 --%>
                    <asp:Repeater ID="rptMoments" runat="server" OnItemCommand="rptMoments_ItemCommand" OnItemDataBound="rptMoments_ItemDataBound">
                        <%-- 列表项模板：定义 Repeater 中每一条业务记录的 HTML 结构和绑定字段。 --%>
                        <ItemTemplate>
                            <%-- 内容卡片：用于组织当前模块中的一组相关信息。 --%>
                            <article class="moment-card">
                                <div class="moment-head">
                                    <img src='<%# GetAvatarUrl(Eval("AvatarUrl")) %>' alt='<%# Eval("DisplayName") %>' />
                                    <div><strong><%# Eval("DisplayName") %></strong><small><%# Eval("CreatedAt", "{0:yyyy-MM-dd HH:mm}") %></small></div>
                                </div>
                                <p><%# HtmlEncode(Eval("Content")) %></p>
                                <%# RenderMomentImage(Eval("ImageUrl")) %>
                                <%# RenderMomentLocation(Eval("LocationText")) %>
                                <div class="moment-actions">
                                    <%-- 操作按钮 btnToggleLike：点击后触发后台事件处理当前业务动作。 --%>
                                    <asp:LinkButton ID="btnToggleLike" runat="server" CssClass="wx-muted-link" CommandName="ToggleLike" CommandArgument='<%# Eval("Id") %>'><%# GetMomentLikeButtonText(Eval("IsLikedByCurrentUser"), Eval("LikeCount")) %></asp:LinkButton>
                                    <%-- 操作按钮 btnDeleteMoment：点击后触发后台事件处理当前业务动作。 --%>
                                    <asp:LinkButton ID="btnDeleteMoment" runat="server" CssClass="wx-muted-link" Visible='<%# CanDeleteOwnContent(Eval("UserId")) %>' CommandName="DeleteMoment" CommandArgument='<%# Eval("Id") %>' OnClientClick="return confirm('确认删除这条朋友圈吗？');">删除</asp:LinkButton>
                                    <span class="badge-inline"><%# GetMomentVisibilityLabel(Eval("Visibility")) %></span>
                                    <span class="badge-inline">评论 <%# Eval("CommentCount") %></span>
                                </div>
                                <div class="moment-comments">
                                    <%-- 数据列表控件 rptMomentComments：后台绑定集合数据后，按 ItemTemplate 循环渲染每条记录。 --%>
                                    <asp:Repeater ID="rptMomentComments" runat="server" OnItemCommand="rptMomentComments_ItemCommand">
                                        <%-- 列表项模板：定义 Repeater 中每一条业务记录的 HTML 结构和绑定字段。 --%>
                                        <ItemTemplate>
                                            <%-- 内容卡片：用于组织当前模块中的一组相关信息。 --%>
                                            <article class='<%# GetMomentCommentCss(Eval("ReplyDepth")) %>'>
                                                <strong><%# Eval("DisplayName") %></strong><span><%# Eval("CreatedAt", "{0:MM-dd HH:mm}") %></span>
                                                <%# RenderReplyTarget(Eval("ReplyToDisplayName")) %>
                                                <p><%# HtmlEncode(Eval("Content")) %></p>
                                                <%-- 操作按钮 btnReplyComment：点击后触发后台事件处理当前业务动作。 --%>
                                                <asp:LinkButton ID="btnReplyComment" runat="server" CssClass="wx-muted-link" CommandName="ReplyComment" CommandArgument='<%# Eval("Id") + "|" + Eval("MomentId") + "|" + Eval("DisplayName") %>'>回复</asp:LinkButton>
                                                <%-- 操作按钮 btnDeleteComment：点击后触发后台事件处理当前业务动作。 --%>
                                                <asp:LinkButton ID="btnDeleteComment" runat="server" CssClass="wx-muted-link" Visible='<%# CanDeleteOwnContent(Eval("UserId")) %>' CommandName="DeleteComment" CommandArgument='<%# Eval("Id") %>' OnClientClick="return confirm('确认删除这条评论吗？');">删除</asp:LinkButton>
                                            </article>
                                        </ItemTemplate>
                                    </asp:Repeater>
                                </div>
                                <div class="moment-comment-form">
                                    <%-- 输入控件 txtMomentComment：接收用户输入或展示后台已有备注。 --%>
                                    <asp:TextBox ID="txtMomentComment" runat="server" CssClass="wx-input" placeholder="写一条评论..." />
                                    <%-- 操作按钮 btnCommentMoment：点击后触发后台事件处理当前业务动作。 --%>
                                    <asp:LinkButton ID="btnCommentMoment" runat="server" CssClass="wx-primary-link" CommandName="Comment" CommandArgument='<%# Eval("Id") %>'>发送</asp:LinkButton>
                                </div>
                            </article>
                        </ItemTemplate>
                    </asp:Repeater>
                </div>
            </section>
            <% } else if (IsWalletView) { %>
            <%-- 页面分区：把当前页面内容按业务模块拆分展示。 --%>
            <section class="wechat-wallet-view" id="money-panel">
                <header class="wechat-pane-title"><h1>红包与转账</h1><span>余额与礼物记录写入钱包流水</span></header>
                <div class="wx-two-column">
                    <%-- 页面分区：把当前页面内容按业务模块拆分展示。 --%>
                    <section class="wx-card" id="gift-panel">
                        <h2>礼物互动</h2>
                        <%-- 面板控件 pnlGiftMessage：后台可通过 Visible/CssClass 控制整块内容是否显示以及提示样式。 --%>
                        <asp:Panel ID="pnlGiftMessage" runat="server" Visible="false" CssClass="status-message"><asp:Literal ID="litGiftMessage" runat="server" /></asp:Panel>
                        <%-- 下拉控件 ddlGiftReceiver：提供状态、分类或角色等固定选项。 --%>
                        <asp:DropDownList ID="ddlGiftReceiver" runat="server" CssClass="wx-input" />
                        <%-- 下拉控件 ddlGiftCatalog：提供状态、分类或角色等固定选项。 --%>
                        <asp:DropDownList ID="ddlGiftCatalog" runat="server" CssClass="wx-input" />
                        <%-- 输入控件 txtGiftQuantity：接收用户输入或展示后台已有备注。 --%>
                        <asp:TextBox ID="txtGiftQuantity" runat="server" CssClass="wx-input" Text="1" />
                        <%-- 操作按钮 btnSendGift：点击后触发后台事件处理当前业务动作。 --%>
                        <asp:Button ID="btnSendGift" runat="server" Text="立即送礼" CssClass="wx-primary-btn" OnClick="btnSendGift_Click" />
                    </section>
                    <%-- 页面分区：把当前页面内容按业务模块拆分展示。 --%>
                    <section class="wx-card" id="transfer-panel">
                        <h2>红包 / 转账</h2>
                        <%-- 面板控件 pnlTransferMessage：后台可通过 Visible/CssClass 控制整块内容是否显示以及提示样式。 --%>
                        <asp:Panel ID="pnlTransferMessage" runat="server" Visible="false" CssClass="status-message"><asp:Literal ID="litTransferMessage" runat="server" /></asp:Panel>
                        <div class="wx-money-composer">
                            <div class="wx-money-row">
                                <%-- 下拉控件 ddlTransferReceiver：提供状态、分类或角色等固定选项。 --%>
                                <asp:DropDownList ID="ddlTransferReceiver" runat="server" CssClass="wx-input" />
                                <%-- 下拉控件 ddlTransferType：提供状态、分类或角色等固定选项。 --%>
                                <asp:DropDownList ID="ddlTransferType" runat="server" CssClass="wx-input" />
                            </div>
                            <div class="wx-money-amount">
                                <span>￥</span>
                                <%-- 输入控件 txtTransferAmount：接收用户输入或展示后台已有备注。 --%>
                                <asp:TextBox ID="txtTransferAmount" runat="server" CssClass="wx-money-input" Text="6.60" />
                            </div>
                            <%-- 输入控件 txtTransferNote：接收用户输入或展示后台已有备注。 --%>
                            <asp:TextBox ID="txtTransferNote" runat="server" CssClass="wx-input" placeholder="备注" />
                            <div class="wx-money-preview">
                                <span class="wx-money-preview-icon">￥</span>
                                <div>
                                    <strong>好友资金互动</strong>
                                    <small>现金余额</small>
                                </div>
                            </div>
                            <%-- 操作按钮 btnSendTransfer：点击后触发后台事件处理当前业务动作。 --%>
                            <asp:Button ID="btnSendTransfer" runat="server" Text="发送红包 / 转账" CssClass="wx-primary-btn wx-money-submit" OnClick="btnSendTransfer_Click" />
                        </div>
                    </section>
                </div>
                <%-- 页面分区：把当前页面内容按业务模块拆分展示。 --%>
                <section class="wx-card">
                    <h2>最近资金互动</h2>
                    <%-- 数据列表控件 rptTransferRecords：后台绑定集合数据后，按 ItemTemplate 循环渲染每条记录。 --%>
                    <asp:Repeater ID="rptTransferRecords" runat="server">
                        <%-- 列表项模板：定义 Repeater 中每一条业务记录的 HTML 结构和绑定字段。 --%>
                        <ItemTemplate>
                            <%-- 内容卡片：用于组织当前模块中的一组相关信息。 --%>
                            <article class='<%# GetTransferRecordClass(Eval("TransferType")) %>'>
                                <strong><%# GetTransferLabel(Eval("TransferType")) %> · ￥<%# Eval("Amount", "{0:F2}") %></strong>
                                <p><%# Eval("SenderDisplayName") %> → <%# Eval("ReceiverDisplayName") %></p>
                                <small><%# string.IsNullOrWhiteSpace(Convert.ToString(Eval("Note"))) ? "未填写备注" : Eval("Note") %> · <%# GetTransferStatusLabel(Eval("Status")) %> · <%# Eval("CreatedAt", "{0:MM-dd HH:mm}") %></small>
                            </article>
                        </ItemTemplate>
                    </asp:Repeater>
                </section>
            </section>
            <% } else { %>
            <%-- 页面分区：把当前页面内容按业务模块拆分展示。 --%>
            <section class="wechat-chat-view">
                <% if (HasSelectedFriend) { %>
                <header class="wechat-chat-header">
                    <h1><%= Server.HtmlEncode(SelectedFriendSummary.DisplayName) %></h1>
                    <div class="wechat-chat-tools">
                        <%-- 操作按钮 btnTogglePinConversation：点击后触发后台事件处理当前业务动作。 --%>
                        <asp:Button ID="btnTogglePinConversation" runat="server" Text="置顶会话" CssClass="wx-icon-button" OnClick="btnTogglePinConversation_Click" />
                        <details class="wechat-more-actions">
                            <summary class="wx-icon-button">更多</summary>
                            <div>
                                <a class="wx-plain-link" href="<%= GetFriendProfileLink(SelectedFriendSummary.FriendUserId) %>">好友主页</a>
                                <%-- 操作按钮 btnHideConversation：点击后触发后台事件处理当前业务动作。 --%>
                                <asp:Button ID="btnHideConversation" runat="server" Text="隐藏会话" CssClass="wx-plain-action" OnClick="btnHideConversation_Click" />
                                <%-- 操作按钮 btnRemoveFriend：点击后触发后台事件处理当前业务动作。 --%>
                                <asp:Button ID="btnRemoveFriend" runat="server" Text="删除好友" CssClass="wx-plain-action danger" OnClick="btnRemoveFriend_Click" OnClientClick="return confirm('确认解除当前好友关系吗？');" />
                                <%-- 操作按钮 btnBlockFriend：点击后触发后台事件处理当前业务动作。 --%>
                                <asp:Button ID="btnBlockFriend" runat="server" Text="拉黑好友" CssClass="wx-plain-action danger" OnClick="btnBlockFriend_Click" OnClientClick="return confirm('确认将当前好友加入黑名单吗？');" />
                            </div>
                        </details>
                    </div>
                </header>
                <%-- 面板控件 pnlChatMessage：后台可通过 Visible/CssClass 控制整块内容是否显示以及提示样式。 --%>
                <asp:Panel ID="pnlChatMessage" runat="server" Visible="false" CssClass="status-message wx-chat-status"><asp:Literal ID="litChatMessage" runat="server" /></asp:Panel>
                <div class="wechat-conversation-search">
                    <%-- 输入控件 txtConversationSearch：接收用户输入或展示后台已有备注。 --%>
                    <asp:TextBox ID="txtConversationSearch" runat="server" CssClass="wx-input" placeholder="搜索当前会话中的关键词..." />
                    <%-- 操作按钮 btnSearchConversation：点击后触发后台事件处理当前业务动作。 --%>
                    <asp:Button ID="btnSearchConversation" runat="server" Text="搜索" CssClass="wx-text-btn" OnClick="btnSearchConversation_Click" />
                    <%-- 操作按钮 btnClearConversationSearch：点击后触发后台事件处理当前业务动作。 --%>
                    <asp:Button ID="btnClearConversationSearch" runat="server" Text="清空" CssClass="wx-text-btn" OnClick="btnClearConversationSearch_Click" />
                </div>
                <div class="wechat-message-thread">
                    <%-- 数据列表控件 rptConversation：后台绑定集合数据后，按 ItemTemplate 循环渲染每条记录。 --%>
                    <asp:Repeater ID="rptConversation" runat="server" OnItemCommand="rptConversation_ItemCommand">
                        <%-- 列表项模板：定义 Repeater 中每一条业务记录的 HTML 结构和绑定字段。 --%>
                        <ItemTemplate>
                            <%-- 内容卡片：用于组织当前模块中的一组相关信息。 --%>
                            <article class='<%# GetChatBubbleClass(Eval("SenderUserId"), Eval("MessageType")) %>'>
                                                    <img class="wx-message-avatar" src='<%# GetAvatarUrl(Eval("SenderAvatarUrl")) %>' alt='<%# Eval("SenderDisplayName") %>' />
                                <div class="wx-bubble-body">
                                    <div class="chat-bubble-head">
                                        <strong><%# Eval("SenderDisplayName") %></strong>
                                        <span><%# GetMessageTypeLabel(Eval("MessageType")) %> · <%# Eval("CreatedAt", "{0:MM-dd HH:mm}") %></span>
                                    </div>
                                    <%# RenderChatMessageContent(Eval("MessageType"), Eval("Content"), Eval("IsRevoked"), Eval("MoneyTransferStatus"), Eval("MoneyClaimedAt")) %>
                                    <%# RenderChatAttachment(Eval("AttachmentUrl")) %>
                                    <%# RenderHighlightedChatLocation(Eval("LocationText")) %>
                                    <%-- 操作按钮 btnClaimMoney：点击后触发后台事件处理当前业务动作。 --%>
                                    <asp:LinkButton ID="btnClaimMoney" runat="server" CssClass="wx-money-claim-link" Visible='<%# CanClaimMoneyMessage(Eval("MessageType"), Eval("ReceiverUserId"), Eval("MoneyTransferStatus"), Eval("IsRevoked")) %>' CommandName="ClaimMoney" CommandArgument='<%# Eval("Id") %>'>点击收取</asp:LinkButton>
                                    <%-- 操作按钮 btnRevokeMessage：点击后触发后台事件处理当前业务动作。 --%>
                                    <asp:LinkButton ID="btnRevokeMessage" runat="server" CssClass="wx-muted-link" Visible='<%# CanRevokeMessage(Eval("SenderUserId"), Eval("IsRevoked"), Eval("MessageType"), Eval("MoneyTransferStatus")) %>' CommandName="Revoke" CommandArgument='<%# Eval("Id") %>'>撤回</asp:LinkButton>
                                </div>
                            </article>
                        </ItemTemplate>
                    </asp:Repeater>
                </div>
                <footer class="wechat-input-panel" id="chat-send-panel">
                    <div class="wechat-toolbar">
                        <button type="button" class="wx-tool-action wx-tool-emoji" data-chat-tool="emoji" title="表情" aria-label="打开表情">表</button>
                        <button type="button" class="wx-tool-action wx-tool-photo" data-chat-tool="photo" title="图片" aria-label="选择图片">图</button>
                        <button type="button" class="wx-tool-action wx-tool-screen" data-chat-tool="screen" title="截图" aria-label="截取屏幕">截</button>
                        <button type="button" class="wx-tool-action wx-tool-clip" data-chat-tool="clip" title="剪贴板" aria-label="读取剪贴板">剪</button>
                        <button type="button" class="wx-tool-action wx-tool-voice" data-chat-tool="voice" title="语音" aria-label="录制语音">音</button>
                        <a class="wx-tool-action wx-tool-gift" href="Friends.aspx?mode=wallet#gift-panel" title="送礼">礼</a>
                        <button type="button" class="wx-tool-action wx-tool-redpacket" data-money-open="RedPacket" title="发红包">红</button>
                        <button type="button" class="wx-tool-action wx-tool-transfer" data-money-open="Transfer" title="转账">转</button>
                        <span class="wx-tool-status" data-tool-status aria-live="polite"></span>
                        <%-- 下拉控件 ddlChatMessageType：提供状态、分类或角色等固定选项。 --%>
                        <asp:DropDownList ID="ddlChatMessageType" runat="server" CssClass="wx-mode-select" />
                    </div>
                    <div class="wx-emoji-panel" data-emoji-panel hidden>
                        <button type="button">😀</button>
                        <button type="button">😂</button>
                        <button type="button">😎</button>
                        <button type="button">😭</button>
                        <button type="button">👍</button>
                        <button type="button">🎲</button>
                        <button type="button">🔎</button>
                        <button type="button">🕯️</button>
                        <button type="button">🎭</button>
                        <button type="button">✅</button>
                    </div>
                    <asp:HiddenField ID="hdnChatMoneyType" runat="server" Value="RedPacket" ClientIDMode="Static" />
                    <asp:HiddenField ID="hdnChatInlineFileData" runat="server" ClientIDMode="Static" />
                    <asp:HiddenField ID="hdnChatInlineFileName" runat="server" ClientIDMode="Static" />
                    <div class="wx-chat-money-sheet" data-money-sheet hidden>
                        <div class="wx-chat-money-head">
                            <strong data-money-heading>发红包</strong>
                            <button type="button" class="wx-chat-money-close" data-money-close aria-label="关闭红包转账面板">×</button>
                        </div>
                        <div class="wx-chat-money-tabs">
                            <button type="button" class="active" data-money-open="RedPacket">红包</button>
                            <button type="button" data-money-open="Transfer">转账</button>
                        </div>
                        <label class="wx-chat-money-amount">
                            <span>￥</span>
                            <%-- 输入控件 txtChatMoneyAmount：接收用户输入或展示后台已有备注。 --%>
                            <asp:TextBox ID="txtChatMoneyAmount" runat="server" ClientIDMode="Static" CssClass="wx-chat-money-input" Text="6.60" />
                        </label>
                        <%-- 输入控件 txtChatMoneyNote：接收用户输入或展示后台已有备注。 --%>
                        <asp:TextBox ID="txtChatMoneyNote" runat="server" ClientIDMode="Static" CssClass="wx-chat-money-note-input" placeholder="红包备注 / 转账说明" />
                        <%-- 操作按钮 btnSendChatMoney：点击后触发后台事件处理当前业务动作。 --%>
                        <asp:Button ID="btnSendChatMoney" runat="server" ClientIDMode="Static" Text="发送红包" CssClass="wx-chat-money-send" OnClick="btnSendChatMoney_Click" />
                    </div>
                    <%-- 输入控件 txtChatContent：接收用户输入或展示后台已有备注。 --%>
                    <asp:TextBox ID="txtChatContent" runat="server" CssClass="wechat-compose" TextMode="MultiLine" Rows="4" placeholder="输入聊天内容..." />
                    <details class="wechat-compose-options" data-compose-options>
                        <summary>附件 / 位置 / 开本邀请</summary>
                        <div class="wechat-extra-inputs">
                            <%-- 输入控件 txtChatAttachmentUrl：接收用户输入或展示后台已有备注。 --%>
                            <asp:TextBox ID="txtChatAttachmentUrl" runat="server" CssClass="wx-input" placeholder="照片 / 附件地址" />
                            <asp:FileUpload ID="fuChatAttachment" runat="server" CssClass="wx-input" />
                            <%-- 输入控件 txtChatLocation：接收用户输入或展示后台已有备注。 --%>
                            <asp:TextBox ID="txtChatLocation" runat="server" CssClass="wx-input" placeholder="位置说明" />
                            <%-- 下拉控件 ddlInviteScript：提供状态、分类或角色等固定选项。 --%>
                            <asp:DropDownList ID="ddlInviteScript" runat="server" CssClass="wx-input" />
                            <%-- 操作按钮 btnSendGameInvite：点击后触发后台事件处理当前业务动作。 --%>
                            <asp:Button ID="btnSendGameInvite" runat="server" Text="邀请开本" CssClass="wx-secondary-btn" OnClick="btnSendGameInvite_Click" />
                        </div>
                    </details>
                    <%-- 操作按钮 btnSendChatMessage：点击后触发后台事件处理当前业务动作。 --%>
                    <asp:Button ID="btnSendChatMessage" runat="server" Text="发送" CssClass="wechat-send-btn" OnClick="btnSendChatMessage_Click" />
                </footer>
                <% } else { %>
                <%-- 页面分区：把当前页面内容按业务模块拆分展示。 --%>
                <section class="wechat-empty-center"><div class="wechat-watermark"></div><p>还没有可聊天的好友，请先添加朋友。</p></section>
                <% } %>
            </section>

                                                <button type="button" class="wechat-side-seam-toggle" data-side-panel-toggle aria-label="收起右侧功能区" aria-expanded="true" title="收起右侧功能区">
                <span class="wechat-side-seam-arrow" aria-hidden="true"></span>
            </button>
            <aside class="wechat-side-drawer wechat-chat-drawer wechat-side-panel" data-side-panel>
                <details class="wx-card wx-fold-card" id="group-create-panel" open>
                    <summary>发起群聊</summary>
                    <%-- 面板控件 pnlGroupMessage：后台可通过 Visible/CssClass 控制整块内容是否显示以及提示样式。 --%>
                    <asp:Panel ID="pnlGroupMessage" runat="server" Visible="false" CssClass="status-message"><asp:Literal ID="litGroupMessage" runat="server" /></asp:Panel>
                    <%-- 输入控件 txtGroupName：接收用户输入或展示后台已有备注。 --%>
                    <asp:TextBox ID="txtGroupName" runat="server" CssClass="wx-input" placeholder="群聊名称" />
                    <%-- 输入控件 txtGroupAnnouncement：接收用户输入或展示后台已有备注。 --%>
                    <asp:TextBox ID="txtGroupAnnouncement" runat="server" CssClass="wx-input" placeholder="群公告" />
                    <asp:CheckBoxList ID="cblGroupMembers" runat="server" CssClass="wx-check-list" />
                    <%-- 操作按钮 btnCreateGroup：点击后触发后台事件处理当前业务动作。 --%>
                    <asp:Button ID="btnCreateGroup" runat="server" Text="创建群聊" CssClass="wx-primary-btn" OnClick="btnCreateGroup_Click" />
                </details>
                <details class="wx-card wx-fold-card" id="quick-note-panel">
                    <summary>新建笔记</summary>
                    <%-- 面板控件 pnlQuickNoteMessage：后台可通过 Visible/CssClass 控制整块内容是否显示以及提示样式。 --%>
                    <asp:Panel ID="pnlQuickNoteMessage" runat="server" Visible="false" CssClass="status-message"><asp:Literal ID="litQuickNoteMessage" runat="server" /></asp:Panel>
                    <%-- 输入控件 txtQuickNoteTitle：接收用户输入或展示后台已有备注。 --%>
                    <asp:TextBox ID="txtQuickNoteTitle" runat="server" CssClass="wx-input" placeholder="标题" />
                    <%-- 输入控件 txtQuickNoteContent：接收用户输入或展示后台已有备注。 --%>
                    <asp:TextBox ID="txtQuickNoteContent" runat="server" CssClass="wx-input wx-textarea" TextMode="MultiLine" Rows="3" placeholder="记录要和好友同步的开本事项" />
                    <%-- 操作按钮 btnCreateQuickNote：点击后触发后台事件处理当前业务动作。 --%>
                    <asp:Button ID="btnCreateQuickNote" runat="server" Text="保存笔记" CssClass="wx-secondary-btn" OnClick="btnCreateQuickNote_Click" />
                    <%-- 数据列表控件 rptQuickNotes：后台绑定集合数据后，按 ItemTemplate 循环渲染每条记录。 --%>
                    <asp:Repeater ID="rptQuickNotes" runat="server">
                        <%-- 列表项模板：定义 Repeater 中每一条业务记录的 HTML 结构和绑定字段。 --%>
                        <ItemTemplate>
                            <%-- 内容卡片：用于组织当前模块中的一组相关信息。 --%>
                            <article class="wx-request-card"><strong><%# Eval("Title") %></strong><p><%# Eval("Content") %></p><small><%# Eval("UpdatedAt", "{0:MM-dd HH:mm}") %></small></article>
                        </ItemTemplate>
                    </asp:Repeater>
                </details>
                <details class="wx-card wx-fold-card" id="hidden-chat-panel">
                    <summary>隐藏会话</summary>
                    <%-- 数据列表控件 rptHiddenFriendSummaries：后台绑定集合数据后，按 ItemTemplate 循环渲染每条记录。 --%>
                    <asp:Repeater ID="rptHiddenFriendSummaries" runat="server" OnItemCommand="rptHiddenFriendSummaries_ItemCommand">
                        <%-- 列表项模板：定义 Repeater 中每一条业务记录的 HTML 结构和绑定字段。 --%>
                        <ItemTemplate>
                            <%-- 内容卡片：用于组织当前模块中的一组相关信息。 --%>
                            <article class="wx-request-card">
                                <strong><%# Eval("DisplayName") %></strong>
                                <p><%# Eval("LastMessagePreview") %></p>
                                <%-- 操作按钮 btnRestoreConversation：点击后触发后台事件处理当前业务动作。 --%>
                                <asp:LinkButton ID="btnRestoreConversation" runat="server" CssClass="wx-primary-link" CommandName="Restore" CommandArgument='<%# Eval("FriendUserId") %>'>恢复会话</asp:LinkButton>
                            </article>
                        </ItemTemplate>
                    </asp:Repeater>
                </details>
                <details class="wx-card wx-fold-card">
                    <summary>黑名单</summary>
                    <%-- 数据列表控件 rptBlockedUsers：后台绑定集合数据后，按 ItemTemplate 循环渲染每条记录。 --%>
                    <asp:Repeater ID="rptBlockedUsers" runat="server" OnItemCommand="rptBlockedUsers_ItemCommand">
                        <%-- 列表项模板：定义 Repeater 中每一条业务记录的 HTML 结构和绑定字段。 --%>
                        <ItemTemplate>
                            <%-- 内容卡片：用于组织当前模块中的一组相关信息。 --%>
                            <article class="wx-request-card"><strong><%# Eval("DisplayName") %></strong><small><%# Eval("CreatedAt", "{0:yyyy-MM-dd HH:mm}") %></small><asp:LinkButton ID="btnUnblockUser" runat="server" CssClass="wx-muted-link" CommandName="Unblock" CommandArgument='<%# Eval("BlockedUserId") %>'>解除拉黑</asp:LinkButton></article>
                        </ItemTemplate>
                    </asp:Repeater>
                </details>
            </aside>
            <% } %>
        </main>

        <div class="wechat-metrics" hidden>
            <asp:Literal ID="litFriendCountCard" runat="server" />
            <asp:Literal ID="litPendingRequestCountCard" runat="server" />
            <asp:Literal ID="litChatSummaryCount" runat="server" />
            <asp:Literal ID="litMomentCountCard" runat="server" />
        </div>
    </section>
    <script>
        (function () {
            var sheet = document.querySelector('[data-money-sheet]');
            var hiddenType = document.getElementById('hdnChatMoneyType');
            var sendButton = document.getElementById('btnSendChatMoney');
            var heading = document.querySelector('[data-money-heading]');
            var amountInput = document.getElementById('txtChatMoneyAmount');
            var compose = document.getElementById('<%= txtChatContent.ClientID %>');
            var messageType = document.getElementById('<%= ddlChatMessageType.ClientID %>');
            var attachmentUrl = document.getElementById('<%= txtChatAttachmentUrl.ClientID %>');
            var fileInput = document.getElementById('<%= fuChatAttachment.ClientID %>');
            var inlineFileData = document.getElementById('hdnChatInlineFileData');
            var inlineFileName = document.getElementById('hdnChatInlineFileName');
            var composeOptions = document.querySelector('[data-compose-options]');
            var emojiPanel = document.querySelector('[data-emoji-panel]');
            var toolStatus = document.querySelector('[data-tool-status]');
            var recorder = null;
            var recordChunks = [];
            var recordStream = null;
            var recordTimer = null;

            function setMoneyMode(type) {
                if (!sheet || !hiddenType) {
                    return;
                }

                var isTransfer = type === 'Transfer';
                hiddenType.value = isTransfer ? 'Transfer' : 'RedPacket';
                sheet.hidden = false;
                sheet.classList.toggle('transfer', isTransfer);
                if (heading) {
                    heading.textContent = isTransfer ? '转账' : '发红包';
                }
                if (sendButton) {
                    sendButton.value = isTransfer ? '确认转账' : '发送红包';
                }
                document.querySelectorAll('[data-money-open]').forEach(function (button) {
                    button.classList.toggle('active', button.getAttribute('data-money-open') === hiddenType.value);
                });
                if (amountInput) {
                    amountInput.focus();
                    amountInput.select();
                }
            }

            function setStatus(message, isError) {
                if (!toolStatus) {
                    return;
                }

                toolStatus.textContent = message || '';
                toolStatus.classList.toggle('error', !!isError);
            }

            function setMessageType(value) {
                if (!messageType) {
                    return;
                }

                for (var i = 0; i < messageType.options.length; i += 1) {
                    if (messageType.options[i].value === value) {
                        messageType.selectedIndex = i;
                        break;
                    }
                }
            }

            function openComposeOptions() {
                if (composeOptions) {
                    composeOptions.open = true;
                }
            }

            function setContentIfEmpty(text) {
                if (compose && !compose.value.trim()) {
                    compose.value = text;
                }
            }

            function insertText(text) {
                if (!compose) {
                    return;
                }

                var start = typeof compose.selectionStart === 'number' ? compose.selectionStart : compose.value.length;
                var end = typeof compose.selectionEnd === 'number' ? compose.selectionEnd : compose.value.length;
                compose.value = compose.value.slice(0, start) + text + compose.value.slice(end);
                var next = start + text.length;
                compose.focus();
                compose.setSelectionRange(next, next);
            }

            function setInlineAttachment(dataUrl, fileName, type, fallbackText) {
                if (!inlineFileData || !inlineFileName) {
                    setStatus('当前页面不支持内联附件。', true);
                    return;
                }

                inlineFileData.value = dataUrl || '';
                inlineFileName.value = fileName || '';
                if (attachmentUrl) {
                    attachmentUrl.value = '';
                }
                if (fileInput) {
                    fileInput.value = '';
                }
                setMessageType(type || 'Photo');
                setContentIfEmpty(fallbackText || '分享了一个附件。');
                openComposeOptions();
            }

            function clearInlineAttachment() {
                if (inlineFileData) {
                    inlineFileData.value = '';
                }
                if (inlineFileName) {
                    inlineFileName.value = '';
                }
            }

            function blobToDataUrl(blob) {
                return new Promise(function (resolve, reject) {
                    var reader = new FileReader();
                    reader.onload = function () { resolve(reader.result); };
                    reader.onerror = reject;
                    reader.readAsDataURL(blob);
                });
            }

            function normalizeImageDataUrl(dataUrl, maxSide, quality) {
                return new Promise(function (resolve, reject) {
                    var image = new Image();
                    image.onload = function () {
                        var width = image.naturalWidth || image.width;
                        var height = image.naturalHeight || image.height;
                        var ratio = Math.min(1, maxSide / Math.max(width, height));
                        var canvas = document.createElement('canvas');
                        canvas.width = Math.max(1, Math.round(width * ratio));
                        canvas.height = Math.max(1, Math.round(height * ratio));
                        var context = canvas.getContext('2d');
                        context.fillStyle = '#ffffff';
                        context.fillRect(0, 0, canvas.width, canvas.height);
                        context.drawImage(image, 0, 0, canvas.width, canvas.height);
                        resolve(canvas.toDataURL('image/jpeg', quality));
                    };
                    image.onerror = reject;
                    image.src = dataUrl;
                });
            }

            async function captureScreen() {
                if (!navigator.mediaDevices || !navigator.mediaDevices.getDisplayMedia) {
                    setStatus('当前浏览器不支持截图，请用“图”上传截图文件。', true);
                    return;
                }

                var stream = null;
                try {
                    stream = await navigator.mediaDevices.getDisplayMedia({ video: true, audio: false });
                    var video = document.createElement('video');
                    video.srcObject = stream;
                    video.muted = true;
                    await new Promise(function (resolve) {
                        video.onloadedmetadata = resolve;
                    });
                    await video.play();

                    var width = video.videoWidth || 1280;
                    var height = video.videoHeight || 720;
                    var ratio = Math.min(1, 1200 / Math.max(width, height));
                    var canvas = document.createElement('canvas');
                    canvas.width = Math.max(1, Math.round(width * ratio));
                    canvas.height = Math.max(1, Math.round(height * ratio));
                    canvas.getContext('2d').drawImage(video, 0, 0, canvas.width, canvas.height);
                    setInlineAttachment(canvas.toDataURL('image/jpeg', 0.68), 'screen.jpg', 'Photo', '分享了一张截图。');
                    setStatus('截图已放入发送区，点击发送即可。');
                } catch (error) {
                    setStatus('截图已取消或浏览器拒绝授权。', true);
                } finally {
                    if (stream) {
                        stream.getTracks().forEach(function (track) { track.stop(); });
                    }
                }
            }

            async function pasteFromClipboard() {
                try {
                    if (navigator.clipboard && navigator.clipboard.read) {
                        var items = await navigator.clipboard.read();
                        for (var i = 0; i < items.length; i += 1) {
                            for (var j = 0; j < items[i].types.length; j += 1) {
                                var type = items[i].types[j];
                                if (type.indexOf('image/') === 0) {
                                    var blob = await items[i].getType(type);
                                    var rawDataUrl = await blobToDataUrl(blob);
                                    var dataUrl = await normalizeImageDataUrl(rawDataUrl, 1200, 0.72);
                                    setInlineAttachment(dataUrl, 'clipboard.jpg', 'Photo', '从剪贴板粘贴了一张图片。');
                                    setStatus('剪贴板图片已放入发送区。');
                                    return;
                                }
                            }
                        }
                    }

                    if (navigator.clipboard && navigator.clipboard.readText) {
                        var text = await navigator.clipboard.readText();
                        if (text) {
                            insertText(text);
                            setStatus('剪贴板文字已插入。');
                            return;
                        }
                    }

                    setStatus('剪贴板里没有可发送的文字或图片。', true);
                } catch (error) {
                    setStatus('浏览器未允许读取剪贴板，请手动粘贴。', true);
                    if (compose) {
                        compose.focus();
                    }
                }
            }

            async function toggleVoiceRecording(button) {
                if (recorder && recorder.state === 'recording') {
                    recorder.stop();
                    return;
                }

                if (!navigator.mediaDevices || !navigator.mediaDevices.getUserMedia || !window.MediaRecorder) {
                    setMessageType('Voice');
                    setContentIfEmpty('发来一条语音留言。');
                    setStatus('当前浏览器不支持录音，可上传音频文件。', true);
                    openComposeOptions();
                    if (fileInput) {
                        fileInput.click();
                    }
                    return;
                }

                try {
                    recordStream = await navigator.mediaDevices.getUserMedia({ audio: true });
                    recordChunks = [];
                    recorder = new MediaRecorder(recordStream);
                    recorder.ondataavailable = function (event) {
                        if (event.data && event.data.size > 0) {
                            recordChunks.push(event.data);
                        }
                    };
                    recorder.onstop = async function () {
                        window.clearTimeout(recordTimer);
                        recordTimer = null;
                        if (recordStream) {
                            recordStream.getTracks().forEach(function (track) { track.stop(); });
                            recordStream = null;
                        }
                        if (button) {
                            button.classList.remove('recording');
                            button.textContent = '音';
                        }
                        var audioBlob = new Blob(recordChunks, { type: 'audio/webm' });
                        if (!audioBlob.size) {
                            setStatus('没有录到声音。', true);
                            return;
                        }
                        if (audioBlob.size > 2.8 * 1024 * 1024) {
                            setStatus('录音太长，请控制在 30 秒内。', true);
                            return;
                        }
                        var dataUrl = await blobToDataUrl(audioBlob);
                        setInlineAttachment(dataUrl, 'voice.webm', 'Voice', '发来一条语音留言。');
                        setStatus('语音已录好，点击发送即可。');
                    };
                    recorder.start();
                    if (button) {
                        button.classList.add('recording');
                        button.textContent = '停';
                    }
                    setStatus('正在录音，再点一次结束。');
                    recordTimer = window.setTimeout(function () {
                        if (recorder && recorder.state === 'recording') {
                            recorder.stop();
                        }
                    }, 30000);
                } catch (error) {
                    setStatus('未获得麦克风权限。', true);
                }
            }

            document.addEventListener('click', function (event) {
                var toolButton = event.target.closest('[data-chat-tool]');
                if (toolButton) {
                    event.preventDefault();
                    var tool = toolButton.getAttribute('data-chat-tool');
                    if (tool === 'emoji') {
                        if (emojiPanel) {
                            emojiPanel.hidden = !emojiPanel.hidden;
                        }
                        setStatus(emojiPanel && !emojiPanel.hidden ? '选择一个表情插入。' : '');
                    } else if (tool === 'photo') {
                        clearInlineAttachment();
                        setMessageType('Photo');
                        openComposeOptions();
                        setStatus('选择图片后点击发送。');
                        if (fileInput) {
                            fileInput.click();
                        }
                    } else if (tool === 'screen') {
                        captureScreen();
                    } else if (tool === 'clip') {
                        pasteFromClipboard();
                    } else if (tool === 'voice') {
                        toggleVoiceRecording(toolButton);
                    }
                    return;
                }

                var emojiButton = event.target.closest('[data-emoji-panel] button');
                if (emojiButton) {
                    event.preventDefault();
                    insertText(emojiButton.textContent);
                    setStatus('表情已插入。');
                    return;
                }

                var opener = event.target.closest('[data-money-open]');
                if (opener) {
                    event.preventDefault();
                    setMoneyMode(opener.getAttribute('data-money-open'));
                    return;
                }

                if (event.target.closest('[data-money-close]') && sheet) {
                    event.preventDefault();
                    sheet.hidden = true;
                }
            });

            if (fileInput) {
                fileInput.addEventListener('change', function () {
                    clearInlineAttachment();
                    if (!fileInput.files || !fileInput.files.length) {
                        return;
                    }

                    var file = fileInput.files[0];
                    if (file.type && file.type.indexOf('audio/') === 0) {
                        setMessageType('Voice');
                        setContentIfEmpty('发来一条语音留言。');
                        setStatus('音频已选择，点击发送即可。');
                    } else {
                        setMessageType('Photo');
                        setContentIfEmpty('分享了一张照片。');
                        setStatus('图片已选择，点击发送即可。');
                    }
                });
            }

            if (attachmentUrl) {
                attachmentUrl.addEventListener('input', clearInlineAttachment);
            }

            if (document.forms.length && inlineFileData) {
                document.forms[0].addEventListener('submit', function (event) {
                    if (inlineFileData.value && inlineFileData.value.length > 3600000) {
                        event.preventDefault();
                        setStatus('附件过大，请改用文件上传。', true);
                    }
                });
            }
        })();
    </script>
</asp:Content>




