<%@ Page Title="好友系统 | 雾城剧本研究所" Language="C#" MasterPageFile="~/Site.Master" AutoEventWireup="true" CodeBehind="Friends.aspx.cs" Inherits="DramaMurderGraduation.Web.FriendsPage" %>
<asp:Content ID="Content1" ContentPlaceHolderID="TitleContent" runat="server">
    好友系统 | 雾城剧本研究所
</asp:Content>
<asp:Content ID="Content2" ContentPlaceHolderID="MainContent" runat="server">
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
                <asp:Button ID="btnSearchFriends" runat="server" Text="搜索" CssClass="wx-text-btn" OnClick="btnSearchFriends_Click" />
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
            <asp:Repeater ID="rptContactFriends" runat="server">
                <ItemTemplate>
                    <a class="wechat-contact-row" href='<%# GetFriendLink(Eval("UserId")) %>'>
                        <img src='<%# GetAvatarUrl(Eval("AvatarUrl")) %>' alt='<%# Eval("DisplayName") %>' />
                        <span><%# Eval("DisplayName") %></span>
                    </a>
                </ItemTemplate>
            </asp:Repeater>
            <% } else { %>
            <asp:Repeater ID="rptFriendSummaries" runat="server">
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
            <section class="wechat-contact-home" id="contact-directory">
                <header class="wechat-pane-title contact-title">
                    <h1>通讯录</h1>
                    <span>好友、申请和群聊集中处理</span>
                </header>
                <div class="wx-contact-summary-grid">
                    <article>
                        <strong><asp:Literal ID="litContactFriendTotal" runat="server" /></strong>
                        <span>联系人</span>
                    </article>
                    <article>
                        <strong><asp:Literal ID="litContactRequestTotal" runat="server" /></strong>
                        <span>新的朋友</span>
                    </article>
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
                <section class="wx-card" id="friend-add-panel">
                    <h2>添加朋友</h2>
                    <p>通过推荐玩家或账号 ID 发起申请，申请记录会写入数据库。</p>
                    <asp:Panel ID="pnlFriendMessage" runat="server" Visible="false" CssClass="status-message">
                        <asp:Literal ID="litFriendMessage" runat="server" />
                    </asp:Panel>
                    <label>选择玩家</label>
                    <asp:DropDownList ID="ddlFriendCandidate" runat="server" CssClass="wx-input" />
                    <label>账号 ID</label>
                    <asp:TextBox ID="txtFriendAccountId" runat="server" CssClass="wx-input" placeholder="例如 DM000123 或 PLAYER_1001" />
                    <label>申请留言</label>
                    <asp:TextBox ID="txtFriendRequestMessage" runat="server" CssClass="wx-input" />
                    <div class="wx-action-row">
                        <asp:Button ID="btnSendFriendRequest" runat="server" Text="从推荐列表发送" CssClass="wx-primary-btn" OnClick="btnSendFriendRequest_Click" />
                        <asp:Button ID="btnSendFriendRequestByCode" runat="server" Text="按 ID 添加" CssClass="wx-secondary-btn" OnClick="btnSendFriendRequestByCode_Click" />
                    </div>
                </section>

                <section class="wx-card" id="request-panel">
                    <h2>新的朋友</h2>
                    <p class="wx-section-hint">收到好友申请后，可以直接点击接受。接受成功后会自动建立好友关系并打开私聊。</p>
                    <% if (!HasPendingFriendRequests) { %>
                    <article class="wx-request-empty">
                        <strong>暂无新的好友申请</strong>
                        <p>别人通过账号 ID 添加你时，会出现在这里。</p>
                    </article>
                    <% } %>
                    <asp:Repeater ID="rptIncomingFriendRequests" runat="server" OnItemCommand="rptIncomingFriendRequests_ItemCommand">
                        <ItemTemplate>
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
                                    <asp:LinkButton ID="btnAcceptFriend" runat="server" CssClass="wx-accept-link" CommandName="Accept" CommandArgument='<%# GetFriendRequestCommandArgument(Eval("Id"), Eval("SenderUserId")) %>'>接受</asp:LinkButton>
                                    <asp:LinkButton ID="btnRejectFriend" runat="server" CssClass="wx-reject-link" CommandName="Reject" CommandArgument='<%# GetFriendRequestCommandArgument(Eval("Id"), Eval("SenderUserId")) %>'>拒绝</asp:LinkButton>
                                </div>
                            </article>
                        </ItemTemplate>
                    </asp:Repeater>
                </section>

                <section class="wx-card" id="group-list">
                    <h2>群聊</h2>
                    <asp:Repeater ID="rptChatGroups" runat="server">
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
                    <section class="wx-settings-card">
                        <div class="wx-account-head">
                            <img src="<%= GetCurrentAvatarUrl() %>" alt="<%= Server.HtmlEncode(GetCurrentDisplayName()) %>" />
                            <div>
                                <strong><%= Server.HtmlEncode(GetCurrentDisplayName()) %></strong>
                                <span><%= Server.HtmlEncode(GetCurrentPublicCode()) %></span>
                            </div>
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
            <section class="wechat-moments-view" id="moments-panel">
                <header class="wechat-pane-title"><h1>朋友圈</h1><span><asp:Literal ID="litMomentCount" runat="server" /> 条动态</span></header>
                <section class="wx-card">
                    <asp:Panel ID="pnlMomentMessage" runat="server" Visible="false" CssClass="status-message">
                        <asp:Literal ID="litMomentMessage" runat="server" />
                    </asp:Panel>
                    <label>分享内容</label>
                    <asp:TextBox ID="txtMomentContent" runat="server" CssClass="wx-input wx-textarea" TextMode="MultiLine" Rows="4" />
                    <label>图片地址</label>
                    <asp:TextBox ID="txtMomentImageUrl" runat="server" CssClass="wx-input" />
                    <label>上传图片</label>
                    <asp:FileUpload ID="fuMomentImage" runat="server" CssClass="wx-input" />
                    <label>可见范围</label>
                    <asp:DropDownList ID="ddlMomentVisibility" runat="server" CssClass="wx-input" />
                    <label>位置</label>
                    <asp:TextBox ID="txtMomentLocation" runat="server" CssClass="wx-input" />
                    <asp:Button ID="btnCreateMoment" runat="server" Text="发布朋友圈" CssClass="wx-primary-btn" OnClick="btnCreateMoment_Click" />
                </section>
                <% if (HasReplyTarget) { %>
                <div class="status-message success reply-status">
                    <span>正在回复 <strong><%= Server.HtmlEncode(ReplyTargetDisplayName) %></strong> 的评论。</span>
                    <asp:LinkButton ID="btnCancelReply" runat="server" CssClass="text-link strong" OnClick="btnCancelReply_Click">取消回复</asp:LinkButton>
                </div>
                <% } %>
                <div class="moment-list wx-moment-list">
                    <asp:Repeater ID="rptMoments" runat="server" OnItemCommand="rptMoments_ItemCommand" OnItemDataBound="rptMoments_ItemDataBound">
                        <ItemTemplate>
                            <article class="moment-card">
                                <div class="moment-head">
                                    <img src='<%# GetAvatarUrl(Eval("AvatarUrl")) %>' alt='<%# Eval("DisplayName") %>' />
                                    <div><strong><%# Eval("DisplayName") %></strong><small><%# Eval("CreatedAt", "{0:yyyy-MM-dd HH:mm}") %></small></div>
                                </div>
                                <p><%# HtmlEncode(Eval("Content")) %></p>
                                <%# RenderMomentImage(Eval("ImageUrl")) %>
                                <%# RenderMomentLocation(Eval("LocationText")) %>
                                <div class="moment-actions">
                                    <asp:LinkButton ID="btnToggleLike" runat="server" CssClass="wx-muted-link" CommandName="ToggleLike" CommandArgument='<%# Eval("Id") %>'><%# GetMomentLikeButtonText(Eval("IsLikedByCurrentUser"), Eval("LikeCount")) %></asp:LinkButton>
                                    <asp:LinkButton ID="btnDeleteMoment" runat="server" CssClass="wx-muted-link" Visible='<%# CanDeleteOwnContent(Eval("UserId")) %>' CommandName="DeleteMoment" CommandArgument='<%# Eval("Id") %>' OnClientClick="return confirm('确认删除这条朋友圈吗？');">删除</asp:LinkButton>
                                    <span class="badge-inline"><%# GetMomentVisibilityLabel(Eval("Visibility")) %></span>
                                    <span class="badge-inline">评论 <%# Eval("CommentCount") %></span>
                                </div>
                                <div class="moment-comments">
                                    <asp:Repeater ID="rptMomentComments" runat="server" OnItemCommand="rptMomentComments_ItemCommand">
                                        <ItemTemplate>
                                            <article class='<%# GetMomentCommentCss(Eval("ReplyDepth")) %>'>
                                                <strong><%# Eval("DisplayName") %></strong><span><%# Eval("CreatedAt", "{0:MM-dd HH:mm}") %></span>
                                                <%# RenderReplyTarget(Eval("ReplyToDisplayName")) %>
                                                <p><%# HtmlEncode(Eval("Content")) %></p>
                                                <asp:LinkButton ID="btnReplyComment" runat="server" CssClass="wx-muted-link" CommandName="ReplyComment" CommandArgument='<%# Eval("Id") + "|" + Eval("MomentId") + "|" + Eval("DisplayName") %>'>回复</asp:LinkButton>
                                                <asp:LinkButton ID="btnDeleteComment" runat="server" CssClass="wx-muted-link" Visible='<%# CanDeleteOwnContent(Eval("UserId")) %>' CommandName="DeleteComment" CommandArgument='<%# Eval("Id") %>' OnClientClick="return confirm('确认删除这条评论吗？');">删除</asp:LinkButton>
                                            </article>
                                        </ItemTemplate>
                                    </asp:Repeater>
                                </div>
                                <div class="moment-comment-form">
                                    <asp:TextBox ID="txtMomentComment" runat="server" CssClass="wx-input" placeholder="写一条评论..." />
                                    <asp:LinkButton ID="btnCommentMoment" runat="server" CssClass="wx-primary-link" CommandName="Comment" CommandArgument='<%# Eval("Id") %>'>发送</asp:LinkButton>
                                </div>
                            </article>
                        </ItemTemplate>
                    </asp:Repeater>
                </div>
            </section>
            <% } else if (IsWalletView) { %>
            <section class="wechat-wallet-view" id="money-panel">
                <header class="wechat-pane-title"><h1>红包与转账</h1><span>余额与礼物记录写入钱包流水</span></header>
                <div class="wx-two-column">
                    <section class="wx-card" id="gift-panel">
                        <h2>礼物互动</h2>
                        <asp:Panel ID="pnlGiftMessage" runat="server" Visible="false" CssClass="status-message"><asp:Literal ID="litGiftMessage" runat="server" /></asp:Panel>
                        <asp:DropDownList ID="ddlGiftReceiver" runat="server" CssClass="wx-input" />
                        <asp:DropDownList ID="ddlGiftCatalog" runat="server" CssClass="wx-input" />
                        <asp:TextBox ID="txtGiftQuantity" runat="server" CssClass="wx-input" Text="1" />
                        <asp:Button ID="btnSendGift" runat="server" Text="立即送礼" CssClass="wx-primary-btn" OnClick="btnSendGift_Click" />
                    </section>
                    <section class="wx-card" id="transfer-panel">
                        <h2>红包 / 转账</h2>
                        <asp:Panel ID="pnlTransferMessage" runat="server" Visible="false" CssClass="status-message"><asp:Literal ID="litTransferMessage" runat="server" /></asp:Panel>
                        <asp:DropDownList ID="ddlTransferReceiver" runat="server" CssClass="wx-input" />
                        <asp:DropDownList ID="ddlTransferType" runat="server" CssClass="wx-input" />
                        <asp:TextBox ID="txtTransferAmount" runat="server" CssClass="wx-input" Text="6.60" />
                        <asp:TextBox ID="txtTransferNote" runat="server" CssClass="wx-input" placeholder="备注" />
                        <asp:Button ID="btnSendTransfer" runat="server" Text="发送红包 / 转账" CssClass="wx-primary-btn" OnClick="btnSendTransfer_Click" />
                    </section>
                </div>
                <section class="wx-card">
                    <h2>最近资金互动</h2>
                    <asp:Repeater ID="rptTransferRecords" runat="server">
                        <ItemTemplate>
                            <article class="wx-request-card">
                                <strong><%# GetTransferLabel(Eval("TransferType")) %> · ￥<%# Eval("Amount", "{0:F2}") %></strong>
                                <p><%# Eval("SenderDisplayName") %> → <%# Eval("ReceiverDisplayName") %></p>
                                <small><%# string.IsNullOrWhiteSpace(Convert.ToString(Eval("Note"))) ? "未填写备注" : Eval("Note") %> · <%# Eval("CreatedAt", "{0:MM-dd HH:mm}") %></small>
                            </article>
                        </ItemTemplate>
                    </asp:Repeater>
                </section>
            </section>
            <% } else { %>
            <section class="wechat-chat-view">
                <% if (HasSelectedFriend) { %>
                <header class="wechat-chat-header">
                    <h1><%= Server.HtmlEncode(SelectedFriendSummary.DisplayName) %></h1>
                    <div class="wechat-chat-tools">
                        <asp:Button ID="btnTogglePinConversation" runat="server" Text="置顶会话" CssClass="wx-icon-button" OnClick="btnTogglePinConversation_Click" />
                        <details class="wechat-more-actions">
                            <summary class="wx-icon-button">更多</summary>
                            <div>
                                <a class="wx-plain-link" href="<%= GetFriendProfileLink(SelectedFriendSummary.FriendUserId) %>">好友主页</a>
                                <asp:Button ID="btnHideConversation" runat="server" Text="隐藏会话" CssClass="wx-plain-action" OnClick="btnHideConversation_Click" />
                                <asp:Button ID="btnRemoveFriend" runat="server" Text="删除好友" CssClass="wx-plain-action danger" OnClick="btnRemoveFriend_Click" OnClientClick="return confirm('确认解除当前好友关系吗？');" />
                                <asp:Button ID="btnBlockFriend" runat="server" Text="拉黑好友" CssClass="wx-plain-action danger" OnClick="btnBlockFriend_Click" OnClientClick="return confirm('确认将当前好友加入黑名单吗？');" />
                            </div>
                        </details>
                    </div>
                </header>
                <asp:Panel ID="pnlChatMessage" runat="server" Visible="false" CssClass="status-message wx-chat-status"><asp:Literal ID="litChatMessage" runat="server" /></asp:Panel>
                <div class="wechat-conversation-search">
                    <asp:TextBox ID="txtConversationSearch" runat="server" CssClass="wx-input" placeholder="搜索当前会话中的关键词..." />
                    <asp:Button ID="btnSearchConversation" runat="server" Text="搜索" CssClass="wx-text-btn" OnClick="btnSearchConversation_Click" />
                    <asp:Button ID="btnClearConversationSearch" runat="server" Text="清空" CssClass="wx-text-btn" OnClick="btnClearConversationSearch_Click" />
                </div>
                <div class="wechat-message-thread">
                    <asp:Repeater ID="rptConversation" runat="server" OnItemCommand="rptConversation_ItemCommand">
                        <ItemTemplate>
                            <article class='<%# GetChatBubbleClass(Eval("SenderUserId")) %>'>
                                                    <img class="wx-message-avatar" src='<%# GetAvatarUrl(Eval("SenderAvatarUrl")) %>' alt='<%# Eval("SenderDisplayName") %>' />
                                <div class="wx-bubble-body">
                                    <div class="chat-bubble-head">
                                        <strong><%# Eval("SenderDisplayName") %></strong>
                                        <span><%# GetMessageTypeLabel(Eval("MessageType")) %> · <%# Eval("CreatedAt", "{0:MM-dd HH:mm}") %></span>
                                    </div>
                                    <p><%# RenderHighlightedChatBody(Eval("Content"), Eval("IsRevoked")) %></p>
                                    <%# RenderChatAttachment(Eval("AttachmentUrl")) %>
                                    <%# RenderHighlightedChatLocation(Eval("LocationText")) %>
                                    <asp:LinkButton ID="btnRevokeMessage" runat="server" CssClass="wx-muted-link" Visible='<%# CanRevokeMessage(Eval("SenderUserId"), Eval("IsRevoked")) %>' CommandName="Revoke" CommandArgument='<%# Eval("Id") %>'>撤回</asp:LinkButton>
                                </div>
                            </article>
                        </ItemTemplate>
                    </asp:Repeater>
                </div>
                <footer class="wechat-input-panel" id="chat-send-panel">
                    <div class="wechat-toolbar">
                        <span>表</span><span>图</span><span>截</span><span>剪</span><span>音</span>
                        <a class="wx-tool-action wx-tool-gift" href="Friends.aspx?mode=wallet#gift-panel" title="送礼">礼</a>
                        <a class="wx-tool-action wx-tool-redpacket" href="Friends.aspx?mode=wallet#transfer-panel" title="发红包">红</a>
                        <a class="wx-tool-action wx-tool-transfer" href="Friends.aspx?mode=wallet#transfer-panel" title="转账">转</a>
                        <asp:DropDownList ID="ddlChatMessageType" runat="server" CssClass="wx-mode-select" />
                    </div>
                    <asp:TextBox ID="txtChatContent" runat="server" CssClass="wechat-compose" TextMode="MultiLine" Rows="4" placeholder="输入聊天内容..." />
                    <details class="wechat-compose-options">
                        <summary>附件 / 位置 / 开本邀请</summary>
                        <div class="wechat-extra-inputs">
                            <asp:TextBox ID="txtChatAttachmentUrl" runat="server" CssClass="wx-input" placeholder="照片 / 附件地址" />
                            <asp:FileUpload ID="fuChatAttachment" runat="server" CssClass="wx-input" />
                            <asp:TextBox ID="txtChatLocation" runat="server" CssClass="wx-input" placeholder="位置说明" />
                            <asp:DropDownList ID="ddlInviteScript" runat="server" CssClass="wx-input" />
                            <asp:Button ID="btnSendGameInvite" runat="server" Text="邀请开本" CssClass="wx-secondary-btn" OnClick="btnSendGameInvite_Click" />
                        </div>
                    </details>
                    <asp:Button ID="btnSendChatMessage" runat="server" Text="发送" CssClass="wechat-send-btn" OnClick="btnSendChatMessage_Click" />
                </footer>
                <% } else { %>
                <section class="wechat-empty-center"><div class="wechat-watermark"></div><p>还没有可聊天的好友，请先添加朋友。</p></section>
                <% } %>
            </section>

                                                <button type="button" class="wechat-side-seam-toggle" data-side-panel-toggle aria-label="收起右侧功能区" aria-expanded="true" title="收起右侧功能区">
                <span class="wechat-side-seam-arrow" aria-hidden="true"></span>
            </button>
            <aside class="wechat-side-drawer wechat-chat-drawer wechat-side-panel" data-side-panel>
                <details class="wx-card wx-fold-card" id="group-create-panel" open>
                    <summary>发起群聊</summary>
                    <asp:Panel ID="pnlGroupMessage" runat="server" Visible="false" CssClass="status-message"><asp:Literal ID="litGroupMessage" runat="server" /></asp:Panel>
                    <asp:TextBox ID="txtGroupName" runat="server" CssClass="wx-input" placeholder="群聊名称" />
                    <asp:TextBox ID="txtGroupAnnouncement" runat="server" CssClass="wx-input" placeholder="群公告" />
                    <asp:CheckBoxList ID="cblGroupMembers" runat="server" CssClass="wx-check-list" />
                    <asp:Button ID="btnCreateGroup" runat="server" Text="创建群聊" CssClass="wx-primary-btn" OnClick="btnCreateGroup_Click" />
                </details>
                <details class="wx-card wx-fold-card" id="quick-note-panel">
                    <summary>新建笔记</summary>
                    <asp:Panel ID="pnlQuickNoteMessage" runat="server" Visible="false" CssClass="status-message"><asp:Literal ID="litQuickNoteMessage" runat="server" /></asp:Panel>
                    <asp:TextBox ID="txtQuickNoteTitle" runat="server" CssClass="wx-input" placeholder="标题" />
                    <asp:TextBox ID="txtQuickNoteContent" runat="server" CssClass="wx-input wx-textarea" TextMode="MultiLine" Rows="3" placeholder="记录要和好友同步的开本事项" />
                    <asp:Button ID="btnCreateQuickNote" runat="server" Text="保存笔记" CssClass="wx-secondary-btn" OnClick="btnCreateQuickNote_Click" />
                    <asp:Repeater ID="rptQuickNotes" runat="server">
                        <ItemTemplate>
                            <article class="wx-request-card"><strong><%# Eval("Title") %></strong><p><%# Eval("Content") %></p><small><%# Eval("UpdatedAt", "{0:MM-dd HH:mm}") %></small></article>
                        </ItemTemplate>
                    </asp:Repeater>
                </details>
                <details class="wx-card wx-fold-card" id="hidden-chat-panel">
                    <summary>隐藏会话</summary>
                    <asp:Repeater ID="rptHiddenFriendSummaries" runat="server" OnItemCommand="rptHiddenFriendSummaries_ItemCommand">
                        <ItemTemplate>
                            <article class="wx-request-card">
                                <strong><%# Eval("DisplayName") %></strong>
                                <p><%# Eval("LastMessagePreview") %></p>
                                <asp:LinkButton ID="btnRestoreConversation" runat="server" CssClass="wx-primary-link" CommandName="Restore" CommandArgument='<%# Eval("FriendUserId") %>'>恢复会话</asp:LinkButton>
                            </article>
                        </ItemTemplate>
                    </asp:Repeater>
                </details>
                <details class="wx-card wx-fold-card">
                    <summary>黑名单</summary>
                    <asp:Repeater ID="rptBlockedUsers" runat="server" OnItemCommand="rptBlockedUsers_ItemCommand">
                        <ItemTemplate>
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
</asp:Content>




