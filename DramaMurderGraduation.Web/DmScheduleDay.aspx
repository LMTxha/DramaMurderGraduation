<%@ Page Title="DM 日排班 | 剧本杀系统" Language="C#" MasterPageFile="~/Site.Master" AutoEventWireup="true" CodeBehind="DmScheduleDay.aspx.cs" Inherits="DramaMurderGraduation.Web.DmScheduleDayPage" %>
<%-- DM 日程页：按日期展示主持场次，方便安排当日控场任务。 --%>

<asp:Content ID="Content1" ContentPlaceHolderID="TitleContent" runat="server">
    DM 日排班 | 剧本杀系统
</asp:Content>

<asp:Content ID="Content2" ContentPlaceHolderID="MainContent" runat="server">
    <asp:Panel ID="pnlForbidden" runat="server" Visible="false" CssClass="section-block">
        <div class="container empty-state">
            <h1>仅 DM 或管理员可访问</h1>
            <p>这一天的主持排班需要登录具备游戏房间管理权限的账号查看。</p>
            <a class="btn-primary" href="Login.aspx">切换账号</a>
        </div>
    </asp:Panel>

    <asp:Panel ID="pnlSchedule" runat="server" Visible="false">
        <section class="detail-hero">
            <div class="container detail-grid">
                <article class="detail-copy">
                    <p class="eyebrow">DM DAY SCHEDULE</p>
                    <h1><asp:Literal ID="litDayTitle" runat="server" /></h1>
                    <p class="hero-subtitle">这里集中查看当天所有主持场次，可确认接单、检查玩家人数与角色分配，并直接进入对应游戏房间。</p>
                    <div class="detail-tags">
                        <span>日期：<asp:Literal ID="litSelectedDate" runat="server" /></span>
                        <span>主持场次：<asp:Literal ID="litSessionCount" runat="server" /></span>
                        <span>待接单：<asp:Literal ID="litPendingCount" runat="server" /></span>
                    </div>
                    <div class="hero-actions">
                        <a class="btn-secondary" href="DmDashboard.aspx">返回主持台</a>
                        <a class="btn-secondary" href='<%= PreviousDayUrl %>'>前一天</a>
                        <a class="btn-secondary" href='<%= NextDayUrl %>'>后一天</a>
                    </div>
                </article>

                <article class="about-panel">
                    <div class="section-heading left">
                        <h2>当天概览</h2>
                        <p>优先处理未接单、即将开场和已经进行中的场次。</p>
                    </div>
                    <div class="lobby-summary-list">
                        <div class="lobby-summary-item"><span>已接单</span><strong><asp:Literal ID="litAcceptedCount" runat="server" /></strong></div>
                        <div class="lobby-summary-item"><span>进行中</span><strong><asp:Literal ID="litActiveCount" runat="server" /></strong></div>
                        <div class="lobby-summary-item"><span>已归档</span><strong><asp:Literal ID="litSettledCount" runat="server" /></strong></div>
                    </div>
                </article>
            </div>
        </section>

        <section class="section-block">
            <div class="container">
                <asp:Panel ID="pnlMessage" runat="server" Visible="false" CssClass="status-message">
                    <asp:Literal ID="litMessage" runat="server" />
                </asp:Panel>

                <asp:Panel ID="pnlEmpty" runat="server" Visible="false" CssClass="empty-state">
                    <h2>当天暂无排班</h2>
                    <p>这一天没有分配给你的主持场次，可以返回主持台查看未来 7 天概览。</p>
                    <a class="btn-primary" href="DmDashboard.aspx">返回主持台</a>
                </asp:Panel>

                <div class="script-asset-list" id="dm-day-session-list">
                    <asp:Repeater ID="rptDaySessions" runat="server" OnItemCommand="rptDaySessions_ItemCommand">
                        <ItemTemplate>
                            <article class="script-asset-card">
                                <div class="script-asset-main">
                                    <strong><%# Eval("ScriptName") %></strong>
                                    <p><%# Eval("RoomName") %> / <%# Eval("SessionDateTime", "{0:yyyy-MM-dd HH:mm}") %> / <%# Eval("CurrentStageName") %></p>
                                    <p>玩家 <%# Eval("ReservationCount") %>/<%# Eval("MaxPlayers") %>，角色 <%# Eval("AssignedCount") %>，就位 <%# Eval("ReadyCount") %>，投票 <%# Eval("VoteCount") %></p>
                                    <p class="meta-copy">主持备注：<%# string.IsNullOrWhiteSpace(Convert.ToString(Eval("HostBriefing"))) ? "暂无" : Eval("HostBriefing") %></p>
                                    <p class="meta-copy">玩家备注：<%# Eval("PlayerNoteSummary") %></p>
                                    <div class="dm-checklist"><%# BuildChecklistHtml(Container.DataItem) %></div>
                                </div>
                                <div class="script-asset-side">
                                    <span><%# GetSessionStatusText(Eval("IsGameStarted"), Eval("IsGameEnded"), Eval("IsSettled")) %></span>
                                    <span class='badge-inline <%# GetAcceptBadgeClass(Eval("HostAcceptedAt")) %>'><%# GetAcceptStatusText(Eval("HostAcceptedAt")) %></span>
                                    <asp:LinkButton ID="btnAcceptDmAssignment" runat="server" CssClass="btn-secondary small" CommandName="AcceptAssignment" CommandArgument='<%# Eval("SessionId") %>'>接收主持任务</asp:LinkButton>
                                    <asp:LinkButton ID="btnCancelDmAssignment" runat="server" CssClass="btn-secondary small danger-button" CommandName="CancelAssignment" CommandArgument='<%# Eval("SessionId") %>' CausesValidation="false" OnClientClick="return confirm('确认取消该场次并释放所有玩家名额吗？这会结束游戏、取消有效预约并从主持台移除。');">取消任务</asp:LinkButton>
                                    <asp:LinkButton ID="btnFinishSession" runat="server" CssClass="btn-secondary small" CommandName="ReleaseSession" CommandArgument='<%# Eval("SessionId") %>' CausesValidation="false" OnClientClick="return confirm('确认结束该场游戏并释放名额吗？所有仍占位的预约会被取消。');">结束游戏释放名额</asp:LinkButton>
                                    <%# GetHostLink(Eval("HostReservationId")) %>
                                    <a class="btn-secondary small" href='DmScheduleDay.aspx?date=<%# Eval("SessionDateTime", "{0:yyyy-MM-dd}") %>'>刷新当天</a>
                                </div>
                            </article>
                        </ItemTemplate>
                    </asp:Repeater>
                </div>
            </div>
        </section>
    </asp:Panel>
</asp:Content>
