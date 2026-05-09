<%@ Page Title="通知中心 | 剧本杀系统" Language="C#" MasterPageFile="~/Site.Master" AutoEventWireup="true" CodeBehind="NotificationCenter.aspx.cs" Inherits="DramaMurderGraduation.Web.NotificationCenterPage" %>
<%-- 页面用途：NotificationCenter 页面负责承载对应功能的 Web Forms 标记、服务端控件和前端布局。 --%>
<asp:Content ID="Content1" ContentPlaceHolderID="TitleContent" runat="server">
    通知中心 | 剧本杀系统
</asp:Content>
<asp:Content ID="Content2" ContentPlaceHolderID="MainContent" runat="server">
    <%-- 页面头图区：展示当前功能的标题、说明和关键入口。 --%>
    <section class="detail-hero">
        <div class="container detail-grid">
            <%-- 说明卡片：展示页面主标题、摘要和关键标签。 --%>
            <article class="detail-copy">
                <p class="eyebrow">NOTIFICATION CENTER</p>
                <h1>站内通知中心</h1>
                <p class="hero-subtitle">统一接收订单回复、客服会话、优惠到账、到店提醒和售后进度，避免消息分散在多个页面里。</p>
                <%-- 摘要标签区：展示当前页面最重要的数量或状态提示。 --%>
                <div class="detail-tags">
                    <span>订单回复</span>
                    <span>客服会话</span>
                    <span>优惠券到账</span>
                    <span>到店提醒</span>
                    <span>售后进度</span>
                </div>
            </article>
            <%-- 信息面板：承载一个独立的业务说明、列表或表单模块。 --%>
            <article class="about-panel">
                <%-- 模块标题区：说明当前业务模块的名称和处理说明。 --%>
                <div class="section-heading left">
                    <h2>通知概览</h2>
                    <p>先处理未读消息，再回到玩家中心或订单会话继续跟进。</p>
                </div>
                <%-- 统计网格：集中展示多个关键业务指标。 --%>
                <div class="wallet-summary-grid dm-summary-grid">
                    <%-- 统计卡片：展示一个后台指标或运营数据。 --%>
                    <a class="wallet-summary-card accent notification-summary-link" href="NotificationCenter.aspx?filter=All#notification-list">
                        <span>通知总数</span>
                        <strong><asp:Literal ID="litTotalCount" runat="server" /></strong>
                        <small>当前账号可见的全部站内通知</small>
                    </a>
                    <%-- 统计卡片：展示一个后台指标或运营数据。 --%>
                    <a class="wallet-summary-card notification-summary-link" href="NotificationCenter.aspx?filter=Unread#notification-list">
                        <span>未读</span>
                        <strong><asp:Literal ID="litUnreadCount" runat="server" /></strong>
                        <small>尚未处理或未标记已读的消息</small>
                    </a>
                    <%-- 统计卡片：展示一个后台指标或运营数据。 --%>
                    <a class="wallet-summary-card notification-summary-link" href="NotificationCenter.aspx?filter=Recent#notification-list">
                        <span>近 24 小时</span>
                        <strong><asp:Literal ID="litRecentCount" runat="server" /></strong>
                        <small>最近一天新增的通知数量</small>
                    </a>
                </div>
            </article>
        </div>
    </section>

    <%-- 次级内容区：用于承载筛选、配置、辅助列表或补充信息。 --%>
    <section class="section-block alt">
        <div class="container split-grid detail-split">
            <%-- 表单面板：承载筛选条件或业务提交输入项。 --%>
            <article class="form-panel">
                <%-- 模块标题区：说明当前业务模块的名称和处理说明。 --%>
                <div class="section-heading left">
                    <h2>筛选与处理</h2>
                    <p>按未读状态和通知类别快速定位高优先级消息。</p>
                </div>
                <%-- 表单网格：按响应式布局排列输入框、下拉框和筛选条件。 --%>
                <div class="form-grid single-form">
                    <div class="field-group full">
                        <label for="<%= ddlNotificationFilter.ClientID %>">通知筛选</label>
                        <%-- 下拉控件 ddlNotificationFilter：提供状态、分类或角色等固定选项。 --%>
                        <asp:DropDownList ID="ddlNotificationFilter" runat="server" CssClass="input-control" />
                    </div>
                </div>
                <%-- 操作按钮区：集中放置提交、重置、跳转或审核动作。 --%>
                <div class="hero-actions">
                    <%-- 操作按钮 btnApplyNotificationFilter：点击后触发后台事件处理当前业务动作。 --%>
                    <asp:Button ID="btnApplyNotificationFilter" runat="server" Text="应用筛选" CssClass="btn-primary" OnClick="btnApplyNotificationFilter_Click" />
                    <%-- 操作按钮 btnMarkAllRead：点击后触发后台事件处理当前业务动作。 --%>
                    <asp:Button ID="btnMarkAllRead" runat="server" Text="全部标记已读" CssClass="btn-secondary" OnClick="btnMarkAllRead_Click" />
                    <a class="btn-secondary" href="PlayerHub.aspx?tab=orders">返回玩家中心</a>
                </div>
            </article>

            <%-- 信息面板：承载一个独立的业务说明、列表或表单模块。 --%>
            <article class="about-panel">
                <%-- 模块标题区：说明当前业务模块的名称和处理说明。 --%>
                <div class="section-heading left">
                    <h2>处理建议</h2>
                    <p>优先处理客服回复和即将到店提醒，这两类通知会直接影响履约和玩家体验。</p>
                </div>
                <%-- 列表容器：承载 Repeater 渲染出的多条业务卡片。 --%>
                <div class="reservation-list compact-reservation-list">
                    <%-- 业务卡片：展示一条预约、审核、消息或统计记录。 --%>
                    <article class="reservation-card">
                        <h3>先看未读会话</h3>
                        <p>如果门店有新回复，先进入订单沟通页继续追问或确认安排。</p>
                    </article>
                    <%-- 业务卡片：展示一条预约、审核、消息或统计记录。 --%>
                    <article class="reservation-card">
                        <h3>再看履约提醒</h3>
                        <p>到店提醒里会带开场时间、房间和核销码，适合答辩演示完整履约链路。</p>
                    </article>
                </div>
            </article>
        </div>
    </section>

    <%-- 主要内容区：承载当前页面的核心业务列表、表单或详情内容。 --%>
    <section class="section-block" id="notification-list">
        <div class="container">
            <%-- 面板控件 pnlMessage：后台可通过 Visible/CssClass 控制整块内容是否显示以及提示样式。 --%>
            <asp:Panel ID="pnlMessage" runat="server" Visible="false" CssClass="status-message">
                <asp:Literal ID="litMessage" runat="server" />
            </asp:Panel>

            <%-- 模块标题区：说明当前业务模块的名称和处理说明。 --%>
            <div class="section-heading left">
                <h2>通知列表</h2>
                <p>点击详情可跳转到对应订单、预约或玩家中心功能页。未读通知支持单条处理。</p>
            </div>
            <div class="notification-stack">
                <%-- 数据列表控件 rptNotifications：后台绑定集合数据后，按 ItemTemplate 循环渲染每条记录。 --%>
                <asp:Repeater ID="rptNotifications" runat="server" OnItemCommand="rptNotifications_ItemCommand">
                    <%-- 列表项模板：定义 Repeater 中每一条业务记录的 HTML 结构和绑定字段。 --%>
                    <ItemTemplate>
                        <%-- 业务卡片：展示一条预约、审核、消息或统计记录。 --%>
                        <article class='reservation-card service-reply-card notification-card <%# Convert.ToBoolean(Eval("IsRead")) ? "read" : "unread" %>'>
                            <div class="card-actions space-between">
                                <span class='badge-inline <%# Convert.ToBoolean(Eval("IsRead")) ? "soft" : "warning" %>'><%# Convert.ToBoolean(Eval("IsRead")) ? "已读" : "未读" %></span>
                                <span class="badge-inline soft"><%# Eval("Category") %></span>
                            </div>
                            <h3><%# Eval("Title") %></h3>
                            <p><%# Eval("Content") %></p>
                            <small><%# Eval("CreatedAt", "{0:yyyy-MM-dd HH:mm}") %></small>
                            <%-- 操作按钮区：集中放置提交、重置、跳转或审核动作。 --%>
                            <div class="hero-actions top-gap">
                                <%-- 操作按钮 btnMarkRead：点击后触发后台事件处理当前业务动作。 --%>
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
