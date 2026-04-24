<%@ Page Title="通知中心 | 剧本杀系统" Language="C#" MasterPageFile="~/Site.Master" AutoEventWireup="true" CodeBehind="NotificationCenter.aspx.cs" Inherits="DramaMurderGraduation.Web.NotificationCenterPage" %>
<asp:Content ID="Content1" ContentPlaceHolderID="TitleContent" runat="server">
    通知中心 | 剧本杀系统
</asp:Content>
<asp:Content ID="Content2" ContentPlaceHolderID="MainContent" runat="server">
    <section class="detail-hero">
        <div class="container detail-grid">
            <article class="detail-copy">
                <p class="eyebrow">NOTIFICATION CENTER</p>
                <h1>站内通知中心</h1>
                <p class="hero-subtitle">统一接收订单回复、客服会话、优惠到账、到店提醒和售后进度，避免消息分散在多个页面里。</p>
                <div class="detail-tags">
                    <span>订单回复</span>
                    <span>客服会话</span>
                    <span>优惠券到账</span>
                    <span>到店提醒</span>
                    <span>售后进度</span>
                </div>
            </article>
            <article class="about-panel">
                <div class="section-heading left">
                    <h2>通知概览</h2>
                    <p>先处理未读消息，再回到玩家中心或订单会话继续跟进。</p>
                </div>
                <div class="wallet-summary-grid dm-summary-grid">
                    <article class="wallet-summary-card accent">
                        <span>通知总数</span>
                        <strong><asp:Literal ID="litTotalCount" runat="server" /></strong>
                        <small>当前账号可见的全部站内通知</small>
                    </article>
                    <article class="wallet-summary-card">
                        <span>未读</span>
                        <strong><asp:Literal ID="litUnreadCount" runat="server" /></strong>
                        <small>尚未处理或未标记已读的消息</small>
                    </article>
                    <article class="wallet-summary-card">
                        <span>近 24 小时</span>
                        <strong><asp:Literal ID="litRecentCount" runat="server" /></strong>
                        <small>最近一天新增的通知数量</small>
                    </article>
                </div>
            </article>
        </div>
    </section>

    <section class="section-block alt">
        <div class="container split-grid detail-split">
            <article class="form-panel">
                <div class="section-heading left">
                    <h2>筛选与处理</h2>
                    <p>按未读状态和通知类别快速定位高优先级消息。</p>
                </div>
                <div class="form-grid single-form">
                    <div class="field-group full">
                        <label for="<%= ddlNotificationFilter.ClientID %>">通知筛选</label>
                        <asp:DropDownList ID="ddlNotificationFilter" runat="server" CssClass="input-control" />
                    </div>
                </div>
                <div class="hero-actions">
                    <asp:Button ID="btnApplyNotificationFilter" runat="server" Text="应用筛选" CssClass="btn-primary" OnClick="btnApplyNotificationFilter_Click" />
                    <asp:Button ID="btnMarkAllRead" runat="server" Text="全部标记已读" CssClass="btn-secondary" OnClick="btnMarkAllRead_Click" />
                    <a class="btn-secondary" href="PlayerHub.aspx?tab=orders">返回玩家中心</a>
                </div>
            </article>

            <article class="about-panel">
                <div class="section-heading left">
                    <h2>处理建议</h2>
                    <p>优先处理客服回复和即将到店提醒，这两类通知会直接影响履约和玩家体验。</p>
                </div>
                <div class="reservation-list compact-reservation-list">
                    <article class="reservation-card">
                        <h3>先看未读会话</h3>
                        <p>如果门店有新回复，先进入订单沟通页继续追问或确认安排。</p>
                    </article>
                    <article class="reservation-card">
                        <h3>再看履约提醒</h3>
                        <p>到店提醒里会带开场时间、房间和核销码，适合答辩演示完整履约链路。</p>
                    </article>
                </div>
            </article>
        </div>
    </section>

    <section class="section-block">
        <div class="container">
            <asp:Panel ID="pnlMessage" runat="server" Visible="false" CssClass="status-message">
                <asp:Literal ID="litMessage" runat="server" />
            </asp:Panel>

            <div class="section-heading left">
                <h2>通知列表</h2>
                <p>点击详情可跳转到对应订单、预约或玩家中心功能页。未读通知支持单条处理。</p>
            </div>
            <div class="notification-stack">
                <asp:Repeater ID="rptNotifications" runat="server" OnItemCommand="rptNotifications_ItemCommand">
                    <ItemTemplate>
                        <article class='reservation-card service-reply-card notification-card <%# Convert.ToBoolean(Eval("IsRead")) ? "read" : "unread" %>'>
                            <div class="card-actions space-between">
                                <span class='badge-inline <%# Convert.ToBoolean(Eval("IsRead")) ? "soft" : "warning" %>'><%# Convert.ToBoolean(Eval("IsRead")) ? "已读" : "未读" %></span>
                                <span class="badge-inline soft"><%# Eval("Category") %></span>
                            </div>
                            <h3><%# Eval("Title") %></h3>
                            <p><%# Eval("Content") %></p>
                            <small><%# Eval("CreatedAt", "{0:yyyy-MM-dd HH:mm}") %></small>
                            <div class="hero-actions top-gap">
                                <asp:LinkButton ID="btnMarkRead" runat="server" Visible='<%# !Convert.ToBoolean(Eval("IsRead")) %>' CssClass="btn-secondary small" CommandName="MarkRead" CommandArgument='<%# Eval("NotificationKey") %>'>标记已读</asp:LinkButton>
                                <a class="btn-primary small" href='<%# Eval("TargetUrl") %>'>查看详情</a>
                            </div>
                        </article>
                    </ItemTemplate>
                </asp:Repeater>
                <asp:Literal ID="litEmptyNotifications" runat="server" />
            </div>
        </div>
    </section>
</asp:Content>
