<%@ Page Title="投票明细 | 剧本杀系统" Language="C#" MasterPageFile="~/Site.Master" AutoEventWireup="true" CodeBehind="VoteStatus.aspx.cs" Inherits="DramaMurderGraduation.Web.VoteStatusPage" %>
<asp:Content ID="Content1" ContentPlaceHolderID="TitleContent" runat="server">
    投票明细 | 剧本杀系统
</asp:Content>
<asp:Content ID="Content2" ContentPlaceHolderID="MainContent" runat="server">
    <asp:Panel ID="pnlNotFound" runat="server" Visible="false" CssClass="section-block">
        <div class="container empty-state">
            <h1>未找到投票房间</h1>
            <p>请从游戏房间或自己的订单进入投票明细。</p>
            <a class="btn-primary" href="PlayerHub.aspx?tab=orders">返回我的订单</a>
        </div>
    </asp:Panel>

    <asp:Panel ID="pnlVote" runat="server" Visible="false" CssClass="game-room-module-page game-room-module-vote-status">
        <nav class="game-room-side-rail" data-room-side-rail>
            <a href='<%= VoteFeatureUrl("stage") %>' data-room-nav-link>剧情阶段</a>
            <a href='<%= VoteFeatureUrl("character") %>' data-room-nav-link>角色卡</a>
            <a href='<%= VoteFeatureUrl("clue") %>' data-room-nav-link>线索板</a>
            <a href='<%= VoteFeatureUrl("action") %>' data-room-nav-link>行动记录</a>
            <a href='<%= VoteFeatureUrl("vote") %>' data-room-nav-link>终局投票</a>
            <a href='<%= VoteFeatureUrl("ending") %>' data-room-nav-link>结案复盘</a>
            <a href='<%= VoteFeatureUrl("participants") %>' data-room-nav-link>同房玩家</a>
            <a href='<%= VoteFeatureUrl("media") %>' data-room-nav-link>视频语音</a>
            <a href='<%= VoteFeatureUrl("chat") %>' data-room-nav-link>房间公聊</a>
            <asp:PlaceHolder ID="phVoteDmLink" runat="server" Visible="false">
                <a href='<%= VoteFeatureUrl("host") %>' data-room-nav-link>DM 控制台</a>
            </asp:PlaceHolder>
            <div class="room-side-stats">
                <a href='<%= VoteFeatureUrl("stage") %>' data-room-nav-link><asp:Literal ID="litVoteSideStage" runat="server" /></a>
                <a href='<%= VoteFeatureUrl("participants") %>' data-room-nav-link><asp:Literal ID="litVoteSideReady" runat="server" /></a>
                <a class="is-active" href='<%= VoteFeatureUrl("vote-status") %>' data-room-nav-link><asp:Literal ID="litVoteSideVote" runat="server" /></a>
            </div>
        </nav>

        <section class="detail-hero">
            <div class="container detail-grid">
                <article class="detail-copy">
                    <p class="eyebrow">Vote Status</p>
                    <h1>投票明细</h1>
                    <p class="hero-subtitle">这里可以查看当前房间谁已经投票、谁还没有投票。玩家和管理员都能进入，投票对象会按权限展示。</p>
                    <div class="detail-tags">
                        <span>剧本：<asp:Literal ID="litScriptName" runat="server" /></span>
                        <span>房间：<asp:Literal ID="litRoomName" runat="server" /></span>
                        <span>场次：<asp:Literal ID="litSessionTime" runat="server" /></span>
                    </div>
                    <div class="detail-prices">
                        <strong><asp:Literal ID="litVoteProgress" runat="server" /></strong>
                        <span>已投：<asp:Literal ID="litVotedCount" runat="server" /></span>
                        <span>未投：<asp:Literal ID="litUnvotedCount" runat="server" /></span>
                    </div>
                    <div class="hero-actions">
                        <asp:HyperLink ID="lnkBackVote" runat="server" CssClass="btn-primary">返回终局投票</asp:HyperLink>
                        <asp:HyperLink ID="lnkBackRoom" runat="server" CssClass="btn-secondary">返回游戏房间</asp:HyperLink>
                    </div>
                </article>

                <article class="about-panel">
                    <div class="section-heading left">
                        <h2>查看规则</h2>
                        <p><asp:Literal ID="litVisibilityNote" runat="server" /></p>
                    </div>
                    <div class="vote-status-metrics">
                        <article class="status-chip-card">
                            <span>投票进度</span>
                            <strong><asp:Literal ID="litVoteProgressCard" runat="server" /></strong>
                        </article>
                        <article class="status-chip-card">
                            <span>当前阶段</span>
                            <strong><asp:Literal ID="litCurrentStage" runat="server" /></strong>
                        </article>
                    </div>
                </article>
            </div>
        </section>

        <section class="section-block">
            <div class="container gameplay-grid">
                <article class="about-panel gameplay-panel">
                    <div class="section-heading left">
                        <h2>玩家投票状态</h2>
                        <p>未投票的玩家会排在前面，方便 DM 或同房玩家快速确认进度。</p>
                    </div>
                    <div class="vote-detail-list">
                        <asp:Repeater ID="rptVoteDetails" runat="server">
                            <ItemTemplate>
                                <article class='vote-detail-card <%# Eval("StatusCssClass") %>'>
                                    <span class="stage-badge"><%# Eval("StatusText") %></span>
                                    <h3><%# Eval("CharacterName") %></h3>
                                    <p><%# Eval("PlayerName") %> / <%# Eval("PlayerCount") %> 人</p>
                                    <p class="about-text"><%# Eval("VoteTargetText") %></p>
                                    <p class="inline-note"><%# Eval("VotedAtText") %></p>
                                </article>
                            </ItemTemplate>
                        </asp:Repeater>
                    </div>
                </article>

                <article class="about-panel gameplay-panel">
                    <div class="section-heading left">
                        <h2>当前票型</h2>
                        <p>按候选角色汇总得票数，方便确认终局投票是否已经收齐。</p>
                    </div>
                    <div class="vote-summary-grid">
                        <asp:Repeater ID="rptVoteSummary" runat="server">
                            <ItemTemplate>
                                <article class='vote-card <%# Convert.ToBoolean(Eval("IsCorrectVisible")) ? "correct" : string.Empty %>'>
                                    <span class="vote-count"><%# Eval("VoteCount") %> 票</span>
                                    <h3><%# Eval("SuspectCharacterName") %></h3>
                                    <p><%# Eval("SummaryText") %></p>
                                </article>
                            </ItemTemplate>
                            <FooterTemplate>
                                <asp:PlaceHolder ID="phEmptyVoteSummary" runat="server" Visible='<%# rptVoteSummary.Items.Count == 0 %>'>
                                    <p class="inline-note">当前还没有投票。</p>
                                </asp:PlaceHolder>
                            </FooterTemplate>
                        </asp:Repeater>
                    </div>
                </article>
            </div>
        </section>
    </asp:Panel>
</asp:Content>
