<%@ Page Title="DM 主持台 | 剧本杀系统" Language="C#" MasterPageFile="~/Site.Master" AutoEventWireup="true" CodeBehind="DmDashboard.aspx.cs" Inherits="DramaMurderGraduation.Web.DmDashboardPage" %>
<asp:Content ID="Content1" ContentPlaceHolderID="TitleContent" runat="server">
    DM 主持台 | 剧本杀系统
</asp:Content>
<asp:Content ID="Content2" ContentPlaceHolderID="MainContent" runat="server">
    <asp:Panel ID="pnlForbidden" runat="server" Visible="false" CssClass="section-block">
        <div class="container empty-state">
            <h1>仅 DM 或管理员可访问</h1>
            <p>DM 主持台用于开本控场、旁白引导、阶段推进、发放线索和结案复盘。</p>
            <a class="btn-primary" href="Login.aspx">切换账号</a>
        </div>
    </asp:Panel>

    <asp:Panel ID="pnlDashboard" runat="server" Visible="false">
        <section class="detail-hero">
            <div class="container detail-grid">
                <article class="detail-copy">
                    <p class="eyebrow">DM Console</p>
                    <h1>DM 主持台</h1>
                    <p class="hero-subtitle">这里集中展示可主持房间、玩家就位、角色分配、阶段状态和终局进度。DM 只负责开本控场，不进入后台审核权限。</p>
                    <div class="detail-tags">
                        <span>身份：<asp:Literal ID="litRoleName" runat="server" /></span>
                        <span>主持人：<asp:Literal ID="litDmName" runat="server" /></span>
                        <span>房间数：<asp:Literal ID="litSessionCount" runat="server" /></span>
                    </div>
                </article>

                <article class="about-panel">
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

        <section class="section-block">
            <div class="container">
                <div class="section-heading left">
                    <h2>可主持房间</h2>
                    <p>优先显示未结算的场次；没有有效玩家预约的房间需要先创建或确认玩家预约后才能进入主持控制台。</p>
                </div>
                <div class="script-asset-list">
                    <asp:Repeater ID="rptSessions" runat="server">
                        <ItemTemplate>
                            <article class="script-asset-card">
                                <div class="script-asset-main">
                                    <strong><%# Eval("ScriptName") %></strong>
                                    <p><%# Eval("RoomName") %> / <%# Eval("SessionDateTime", "{0:yyyy-MM-dd HH:mm}") %> / <%# Eval("CurrentStageName") %></p>
                                    <p>玩家 <%# Eval("ReservationCount") %>/<%# Eval("MaxPlayers") %>，角色 <%# Eval("AssignedCount") %>，就位 <%# Eval("ReadyCount") %>，投票 <%# Eval("VoteCount") %></p>
                                </div>
                                <div class="script-asset-side">
                                    <span><%# GetSessionStatusText(Eval("IsGameStarted"), Eval("IsGameEnded"), Eval("IsSettled")) %></span>
                                    <%# GetHostLink(Eval("HostReservationId")) %>
                                </div>
                            </article>
                        </ItemTemplate>
                    </asp:Repeater>
                </div>
            </div>
        </section>
    </asp:Panel>
</asp:Content>
