<%@ Page Title="DM 主持台 | 剧本杀系统" Language="C#" MasterPageFile="~/Site.Master" AutoEventWireup="true" CodeBehind="DmDashboard.aspx.cs" Inherits="DramaMurderGraduation.Web.DmDashboardPage" %>
<%-- 页面用途：DmDashboard 页面负责承载对应功能的 Web Forms 标记、服务端控件和前端布局。 --%>
<asp:Content ID="Content1" ContentPlaceHolderID="TitleContent" runat="server">
    DM 主持台 | 剧本杀系统
</asp:Content>
<asp:Content ID="Content2" ContentPlaceHolderID="MainContent" runat="server">
    <%-- 面板控件 pnlForbidden：后台可通过 Visible/CssClass 控制整块内容是否显示以及提示样式。 --%>
    <asp:Panel ID="pnlForbidden" runat="server" Visible="false" CssClass="section-block">
        <div class="container empty-state">
            <h1>仅 DM 或管理员可访问</h1>
            <p>DM 主持台用于开本控场、旁白引导、阶段推进、发放线索和结案复盘。</p>
            <a class="btn-primary" href="Login.aspx">切换账号</a>
        </div>
    </asp:Panel>

    <%-- 面板控件 pnlDashboard：后台可通过 Visible/CssClass 控制整块内容是否显示以及提示样式。 --%>
    <asp:Panel ID="pnlDashboard" runat="server" Visible="false">
        <%-- 页面头图区：展示当前功能的标题、说明和关键入口。 --%>
        <section class="detail-hero">
            <div class="container detail-grid">
                <%-- 说明卡片：展示页面主标题、摘要和关键标签。 --%>
                <article class="detail-copy">
                    <p class="eyebrow">DM Console</p>
                    <h1>DM 主持台</h1>
                    <p class="hero-subtitle">这里集中展示可主持房间、玩家就位、角色分配、阶段状态和终局进度。DM 只负责开本控场，不进入后台审核权限。</p>
                    <%-- 摘要标签区：展示当前页面最重要的数量或状态提示。 --%>
                    <div class="detail-tags">
                        <span>身份：<asp:Literal ID="litRoleName" runat="server" /></span>
                        <span>主持人：<asp:Literal ID="litDmName" runat="server" /></span>
                        <span>房间数：<asp:Literal ID="litSessionCount" runat="server" /></span>
                    </div>
                </article>

                <%-- 信息面板：承载一个独立的业务说明、列表或表单模块。 --%>
                <article class="about-panel">
                    <%-- 模块标题区：说明当前业务模块的名称和处理说明。 --%>
                    <div class="section-heading left">
                        <h2>主持流程</h2>
                        <p>进入房间后按顺序完成旁白导入、玩家就位、正式开局、阶段推进、线索发放、终局投票和结案复盘。</p>
                    </div>
                    <div class="sheet-grid">
                        <span>1. 检查角色分配</span>
                        <span>2. 开场旁白引导</span>
                        <span>3. 阶段计时控场</span>
                        <span>4. 发放线索结案</span>
                    </div>
                </article>
            </div>
        </section>

        <%-- 主要内容区：承载当前页面的核心业务列表、表单或详情内容。 --%>
        <section class="section-block">
            <div class="container">
                <%-- 统计网格：集中展示多个关键业务指标。 --%>
                <div class="wallet-summary-grid dm-summary-grid">
                    <%-- 统计卡片：展示一个后台指标或运营数据。 --%>
                    <a class="wallet-summary-card accent dm-summary-card-link" href='<%= TodayScheduleUrl %>'>
                        <span>今日场次</span>
                        <strong><asp:Literal ID="litTodaySessionCount" runat="server" /></strong>
                        <small>今天需要关注的主持任务总数</small>
                    </a>
                    <%-- 统计卡片：展示一个后台指标或运营数据。 --%>
                    <a class="wallet-summary-card dm-summary-card-link" href="DmDashboard.aspx?view=pending#dm-session-list">
                        <span>待接收主持</span>
                        <strong><asp:Literal ID="litPendingAcceptCount" runat="server" /></strong>
                        <small>还未确认接单的场次，建议先完成接单</small>
                    </a>
                    <%-- 统计卡片：展示一个后台指标或运营数据。 --%>
                    <a class="wallet-summary-card dm-summary-card-link" href="DmDashboard.aspx?view=active#dm-session-list">
                        <span>进行中</span>
                        <strong><asp:Literal ID="litActiveSessionCount" runat="server" /></strong>
                        <small>已经开局但尚未结算的房间</small>
                    </a>
                </div>

                <%-- 信息面板：承载一个独立的业务说明、列表或表单模块。 --%>
                <article class="about-panel top-gap">
                    <%-- 模块标题区：说明当前业务模块的名称和处理说明。 --%>
                    <div class="section-heading left">
                        <h2>未来 7 天排班日历</h2>
                        <p>快速查看未来一周每天的主持负载，提前判断哪天需要接单、补备注或确认玩家信息。</p>
                    </div>
                    <div class="admin-list dm-calendar-grid">
                        <%-- 数据列表控件 rptScheduleDays：后台绑定集合数据后，按 ItemTemplate 循环渲染每条记录。 --%>
                        <asp:Repeater ID="rptScheduleDays" runat="server">
                            <%-- 列表项模板：定义 Repeater 中每一条业务记录的 HTML 结构和绑定字段。 --%>
                            <ItemTemplate>
                                <%-- 业务卡片：展示一条预约、审核、消息或统计记录。 --%>
                                <a class='reservation-card dm-day-card <%# Eval("CssClass") %>' href='<%# Eval("Url") %>'>
                                    <span class="badge-inline soft"><%# Eval("DayLabel") %></span>
                                    <h3><%# Eval("SessionCountText") %></h3>
                                    <p><%# Eval("Summary") %></p>
                                    <span class="dm-day-card-action">查看当天排班</span>
                                </a>
                            </ItemTemplate>
                        </asp:Repeater>
                    </div>
                </article>

                <%-- 信息面板：承载一个独立的业务说明、列表或表单模块。 --%>
                <article class="about-panel top-gap">
                    <%-- 模块标题区：说明当前业务模块的名称和处理说明。 --%>
                    <div class="section-heading left">
                        <h2>今日任务清单</h2>
                        <p>把今天的主持安排、备注同步和开本优先级提前整理出来，减少 DM 临场来回找信息。</p>
                    </div>
                    <%-- 列表容器：承载 Repeater 渲染出的多条业务卡片。 --%>
                    <div class="reservation-list">
                        <%-- 数据列表控件 rptTodaySessions：后台绑定集合数据后，按 ItemTemplate 循环渲染每条记录。 --%>
                        <asp:Repeater ID="rptTodaySessions" runat="server">
                            <%-- 列表项模板：定义 Repeater 中每一条业务记录的 HTML 结构和绑定字段。 --%>
                            <ItemTemplate>
                                <%-- 业务卡片：展示一条预约、审核、消息或统计记录。 --%>
                                <article class="reservation-card todo-card">
                                    <span class='badge-inline <%# GetAcceptBadgeClass(Eval("HostAcceptedAt")) %>'><%# GetAcceptStatusText(Eval("HostAcceptedAt")) %></span>
                                    <h3><%# Eval("ScriptName") %> / <%# Eval("RoomName") %></h3>
                                    <p>开场：<%# Eval("SessionDateTime", "{0:MM-dd HH:mm}") %> · 玩家 <%# Eval("ReservationCount") %>/<%# Eval("MaxPlayers") %></p>
                                    <p><%# string.IsNullOrWhiteSpace(Convert.ToString(Eval("HostBriefing"))) ? "暂无主持备注" : Eval("HostBriefing") %></p>
                                    <p class="meta-copy">玩家备注：<%# Eval("PlayerNoteSummary") %></p>
                                </article>
                            </ItemTemplate>
                        </asp:Repeater>
                    </div>
                </article>

                <%-- 信息面板：承载一个独立的业务说明、列表或表单模块。 --%>
                <article class="about-panel top-gap">
                    <%-- 模块标题区：说明当前业务模块的名称和处理说明。 --%>
                    <div class="section-heading left">
                        <h2>主持前检查清单与玩家备注同步</h2>
                        <p>进入房间前先确认接单、座位、角色分配、玩家备注和特殊需求，避免开场后再回头查信息。</p>
                    </div>
                    <%-- 列表容器：承载 Repeater 渲染出的多条业务卡片。 --%>
                    <div class="reservation-list">
                        <%-- 数据列表控件 rptChecklistSessions：后台绑定集合数据后，按 ItemTemplate 循环渲染每条记录。 --%>
                        <asp:Repeater ID="rptChecklistSessions" runat="server">
                            <%-- 列表项模板：定义 Repeater 中每一条业务记录的 HTML 结构和绑定字段。 --%>
                            <ItemTemplate>
                                <%-- 业务卡片：展示一条预约、审核、消息或统计记录。 --%>
                                <article class="reservation-card">
                                    <h3><%# Eval("ScriptName") %> / <%# Eval("RoomName") %></h3>
                                    <p>开场：<%# Eval("SessionDateTime", "{0:MM-dd HH:mm}") %> · 当前阶段：<%# Eval("CurrentStageName") %></p>
                                    <div class="dm-checklist"><%# BuildChecklistHtml(Container.DataItem) %></div>
                                    <p class="meta-copy">主持备注：<%# string.IsNullOrWhiteSpace(Convert.ToString(Eval("HostBriefing"))) ? "暂无主持备注" : Eval("HostBriefing") %></p>
                                    <p class="meta-copy">玩家备注同步：<%# Eval("PlayerNoteSummary") %></p>
                                </article>
                            </ItemTemplate>
                        </asp:Repeater>
                    </div>
                </article>
            </div>
        </section>

        <%-- 主要内容区：承载当前页面的核心业务列表、表单或详情内容。 --%>
        <section class="section-block">
            <div class="container">
                <asp:Panel ID="pnlMessage" runat="server" Visible="false" CssClass="status-message">
                    <asp:Literal ID="litMessage" runat="server" />
                </asp:Panel>

                <%-- 模块标题区：说明当前业务模块的名称和处理说明。 --%>
                <div class="section-heading left" id="dm-session-list">
                    <h2>可主持房间</h2>
                    <p>优先显示未结算的场次；没有有效玩家预约的房间需要先创建或确认玩家预约后才能进入主持控制台。</p>
                </div>
                <div class="script-asset-list">
                    <%-- 数据列表控件 rptSessions：后台绑定集合数据后，按 ItemTemplate 循环渲染每条记录。 --%>
                    <asp:Repeater ID="rptSessions" runat="server" OnItemCommand="rptSessions_ItemCommand">
                        <%-- 列表项模板：定义 Repeater 中每一条业务记录的 HTML 结构和绑定字段。 --%>
                        <ItemTemplate>
                            <%-- 内容卡片：用于组织当前模块中的一组相关信息。 --%>
                            <article class="script-asset-card">
                                <div class="script-asset-main">
                                    <strong><%# Eval("ScriptName") %></strong>
                                    <p><%# Eval("RoomName") %> / <%# Eval("SessionDateTime", "{0:yyyy-MM-dd HH:mm}") %> / <%# Eval("CurrentStageName") %></p>
                                    <p>玩家 <%# Eval("ReservationCount") %>/<%# Eval("MaxPlayers") %>，角色 <%# Eval("AssignedCount") %>，就位 <%# Eval("ReadyCount") %>，投票 <%# Eval("VoteCount") %></p>
                                    <p class="meta-copy">主持备注：<%# string.IsNullOrWhiteSpace(Convert.ToString(Eval("HostBriefing"))) ? "暂无" : Eval("HostBriefing") %></p>
                                    <p class="meta-copy">玩家备注：<%# Eval("PlayerNoteSummary") %></p>
                                </div>
                                <div class="script-asset-side">
                                    <span><%# GetSessionStatusText(Eval("IsGameStarted"), Eval("IsGameEnded"), Eval("IsSettled")) %></span>
                                    <%# Eval("HostAcceptedAt") == null ? "" : "<span class=\"badge-inline success\">已接单</span>" %>
                                    <%-- 操作按钮 btnAcceptDmAssignment：点击后触发后台事件处理当前业务动作。 --%>
                                    <asp:LinkButton ID="btnAcceptDmAssignment" runat="server" CssClass="btn-secondary small" CommandName="AcceptAssignment" CommandArgument='<%# Eval("SessionId") %>' Visible='<%# IsPendingAccept(Eval("HostAcceptedAt")) %>'>接收主持任务</asp:LinkButton>
                                    <asp:LinkButton ID="btnCancelDmAssignment" runat="server" CssClass="btn-secondary small danger-button" CommandName="CancelAssignment" CommandArgument='<%# Eval("SessionId") %>' CausesValidation="false" OnClientClick="return confirm('确认取消该场次并释放所有玩家名额吗？这会结束游戏、取消有效预约并从主持台移除。');">取消任务</asp:LinkButton>
                                    <%# GetHostLink(Eval("SessionId"), Eval("HostReservationId"), Eval("HostAcceptedAt")) %>
                                </div>
                            </article>
                        </ItemTemplate>
                    </asp:Repeater>
                </div>
            </div>
        </section>
    </asp:Panel>
</asp:Content>
