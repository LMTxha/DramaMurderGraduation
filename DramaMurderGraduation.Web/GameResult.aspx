<%@ Page Title="结案归档 | 剧本杀系统" Language="C#" MasterPageFile="~/Site.Master" AutoEventWireup="true" CodeBehind="GameResult.aspx.cs" Inherits="DramaMurderGraduation.Web.GameResultPage" %>
<asp:Content ID="Content1" ContentPlaceHolderID="TitleContent" runat="server">
    结案归档 | 剧本杀系统
</asp:Content>
<asp:Content ID="Content2" ContentPlaceHolderID="MainContent" runat="server">
    <asp:Panel ID="pnlNotFound" runat="server" Visible="false" CssClass="section-block">
        <div class="container empty-state">
            <h1>未找到对应的结案归档</h1>
            <p>请先完成预约并进入有效房间后，再查看本场剧本的结案记录。</p>
            <a class="btn-primary" href="Booking.aspx">返回预约页面</a>
        </div>
    </asp:Panel>

    <asp:Panel ID="pnlResult" runat="server" Visible="false">
        <section class="detail-hero">
            <div class="container detail-grid">
                <article class="detail-copy">
                    <p class="eyebrow">Case Archive</p>
                    <h1>本场结案归档</h1>
                    <p class="hero-subtitle">这里集中展示当前房间的剧本信息、终局票型、真相摘要和关键推进记录。</p>
                    <div class="detail-tags">
                        <span>剧本：<asp:Literal ID="litScriptName" runat="server" /></span>
                        <span>房间：<asp:Literal ID="litRoomName" runat="server" /></span>
                        <span>DM：<asp:Literal ID="litHostName" runat="server" /></span>
                    </div>
                    <div class="detail-prices">
                        <strong data-result-stage><asp:Literal ID="litCurrentStage" runat="server" /></strong>
                        <span>预约编号：<asp:Literal ID="litReservationId" runat="server" /></span>
                        <span>房间号：<asp:Literal ID="litRoomCode" runat="server" /></span>
                    </div>
                    <div class="hero-actions">
                        <asp:HyperLink ID="lnkBackToRoom" runat="server" CssClass="btn-primary">返回游戏房间</asp:HyperLink>
                        <asp:HyperLink ID="lnkBackToLobby" runat="server" CssClass="btn-secondary">返回房间大厅</asp:HyperLink>
                    </div>
                </article>

                <article class="about-panel">
                    <div class="section-heading left">
                        <h2>真相摘要</h2>
                        <p>DM 可在游戏房间的结案设置中为每一场独立保存真凶和真相摘要。</p>
                    </div>
                    <div class="ending-summary">
                        <span class="stage-badge"><asp:Literal ID="litResultBadge" runat="server" /></span>
                        <h3>真凶角色：<asp:Literal ID="litCorrectCharacterName" runat="server" /></h3>
                        <p class="about-text"><asp:Literal ID="litTruthSummary" runat="server" /></p>
                    </div>
                </article>
            </div>
        </section>

        <section class="section-block">
            <div class="container gameplay-grid">
                <article class="about-panel gameplay-panel">
                    <div class="section-heading left">
                        <h2>终局票型</h2>
                        <p>展示当前房间所有角色的得票结果。</p>
                    </div>
                    <div class="vote-summary-grid">
                        <asp:Repeater ID="rptVotes" runat="server">
                            <ItemTemplate>
                                <article class='vote-card<%# Convert.ToBoolean(Eval("IsCorrect")) ? " correct" : string.Empty %>'>
                                    <span class="vote-count"><%# Eval("VoteCount") %> 票</span>
                                    <h3><%# Eval("SuspectCharacterName") %></h3>
                                    <p><%# Convert.ToBoolean(Eval("IsCorrect")) ? "系统设定真凶" : "可被指认角色" %></p>
                                </article>
                            </ItemTemplate>
                        </asp:Repeater>
                    </div>
                </article>

                <article class="about-panel gameplay-panel">
                    <div class="section-heading left">
                        <h2>剧情阶段时间线</h2>
                        <p>记录本场对局当前所处阶段以及所有流程节点。</p>
                    </div>
                    <div class="timeline-list">
                        <asp:Repeater ID="rptStages" runat="server">
                            <ItemTemplate>
                                <article class='timeline-card<%# Convert.ToBoolean(Eval("IsCurrent")) ? " current" : string.Empty %>'>
                                    <span class="timeline-tag"><%# Eval("StatusText") %></span>
                                    <h3><%# Eval("StageName") %></h3>
                                    <p><%# Eval("StageDescription") %></p>
                                    <p class="about-text">建议时长：<%# Eval("DurationMinutes") %> 分钟</p>
                                </article>
                            </ItemTemplate>
                        </asp:Repeater>
                    </div>
                </article>
            </div>
        </section>

        <section class="section-block alt">
            <div class="container gameplay-grid">
                <article class="about-panel gameplay-panel">
                    <div class="section-heading left">
                        <h2>关键行动日志</h2>
                        <p>从调查到投票的关键动作会在这里留下记录。</p>
                    </div>
                    <div class="chat-feed action-feed">
                        <asp:Repeater ID="rptActionLogs" runat="server">
                            <ItemTemplate>
                                <article class="chat-bubble">
                                    <strong><%# Eval("PlayerName") %> / <%# Eval("ActionTitle") %></strong>
                                    <span><%# Eval("CreatedAt", "{0:HH:mm:ss}") %> / <%# Eval("ActionType") %></span>
                                    <p><%# Eval("ActionContent") %></p>
                                </article>
                            </ItemTemplate>
                        </asp:Repeater>
                    </div>
                </article>

                <article class="about-panel gameplay-panel">
                    <div class="section-heading left">
                        <h2>玩家角色分配</h2>
                        <p>用于回顾本场房间中每位玩家绑定到哪个角色。</p>
                    </div>
                    <div class="roster-grid">
                        <asp:Repeater ID="rptAssignments" runat="server">
                            <ItemTemplate>
                                <article class='roster-card<%# Convert.ToBoolean(Eval("IsReady")) ? " ready" : string.Empty %>'>
                                    <span class="stage-badge"><%# Convert.ToBoolean(Eval("IsReady")) ? "已就位" : "未就位" %></span>
                                    <h3><%# Eval("CharacterName") %></h3>
                                    <p><%# Eval("PlayerName") %></p>
                                    <p class="about-text"><%# Eval("Profession") %> / <%# Eval("Personality") %></p>
                                </article>
                            </ItemTemplate>
                        </asp:Repeater>
                    </div>
                </article>
            </div>
        </section>
    </asp:Panel>
</asp:Content>
