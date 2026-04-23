<%@ Page Title="发现中心 | 剧本杀系统" Language="C#" MasterPageFile="~/Site.Master" AutoEventWireup="true" CodeBehind="Discover.aspx.cs" Inherits="DramaMurderGraduation.Web.DiscoverPage" %>
<asp:Content ID="Content1" ContentPlaceHolderID="TitleContent" runat="server">
    发现中心 | 剧本杀系统
</asp:Content>
<asp:Content ID="Content2" ContentPlaceHolderID="MainContent" runat="server">
    <section class="hero-section">
        <div class="container detail-grid">
            <article class="detail-copy">
                <div class="hero-badge-row">
                    <a class="site-badge" href="ScriptsList.aspx">今日推荐</a>
                    <a class="site-badge soft" href="Rooms.aspx">热门场次</a>
                </div>
                <p class="eyebrow">DISCOVER</p>
                <h1><asp:Literal ID="litHeroTitle" runat="server" /></h1>
                <p class="hero-subtitle"><asp:Literal ID="litHeroSummary" runat="server" /></p>
                <div class="detail-tags">
                    <a href="#discover-recommendations">推荐剧本 <asp:Literal ID="litRecommendationCount" runat="server" /></a>
                    <a href="#discover-challenges">限时挑战 <asp:Literal ID="litChallengeCount" runat="server" /></a>
                    <a href="#discover-live">直播房间 <asp:Literal ID="litLiveCount" runat="server" /></a>
                    <a href="#discover-douyin">抖音入口</a>
                </div>
                <div class="hero-actions">
                    <a class="btn-primary" href="ScriptsList.aspx">进入剧本库</a>
                    <a class="btn-secondary" href="Spectator.aspx">查看观战中心</a>
                </div>
            </article>

            <article class="about-panel">
                <div class="section-heading left">
                    <h2>一站式发现入口</h2>
                    <p>这里把热门剧本、限时活动、观战房间、订阅权益和身份玩法整合在一起，方便玩家从同一页快速切到想去的模块。</p>
                </div>
                <p class="about-text">如果你是来找新本，可以先看今日推荐；想要围观热局，就去直播房间；准备约下一场，直接跳到房间场次和在线预约即可。</p>
                <div class="hero-actions">
                    <a class="btn-secondary" href="Booking.aspx">去预约</a>
                    <a class="text-link strong" href="Friends.aspx">去好友互动</a>
                </div>
            </article>
        </div>
    </section>

    <section class="section-block" id="discover-douyin">
        <div class="container">
            <article class="about-panel">
                <div class="section-heading left">
                    <h2>抖音官方入口</h2>
                    <p>点击下方模块可直接跳转到抖音官网，方便从系统内进入外部内容平台。</p>
                </div>
                <div class="mini-card-grid">
                    <a class="compact-card compact-card-text click-card interactive-card" href="https://www.douyin.com">
                        <div class="compact-card-body">
                            <span class="badge-inline">外部链接</span>
                            <h3>抖音</h3>
                            <p>进入抖音官网，查看短视频、直播和内容推荐。</p>
                            <span class="text-link strong">立即跳转</span>
                        </div>
                    </a>
                </div>
            </article>
        </div>
    </section>

    <section class="section-block alt" id="discover-recommendations">
        <div class="container">
            <div class="section-heading">
                <h2>今日推荐</h2>
                <p>从沉浸、机制、推理到多人情感本，点开卡片就能直达对应页面。</p>
            </div>
            <div class="card-grid featured-grid">
                <asp:Repeater ID="rptRecommendations" runat="server">
                    <ItemTemplate>
                        <article class="script-card featured-script-card">
                            <img src='<%# Eval("CoverImage") %>' alt='<%# Eval("Title") %>' />
                            <div class="card-body">
                                <div class="card-meta">
                                    <span><%# Eval("HighlightTag") %></span>
                                    <span><%# Eval("Difficulty") %></span>
                                    <span>评分 <%# Eval("Rating", "{0:F1}") %></span>
                                </div>
                                <h3><%# Eval("Title") %></h3>
                                <p><%# Eval("Summary") %></p>
                                <div class="card-stats">
                                    <span><%# Eval("PlayerCount") %> 人局</span>
                                    <span>今晚热推</span>
                                </div>
                                <div class="card-actions">
                                    <a class="btn-primary" href='<%# Eval("DestinationUrl") %>'>查看详情</a>
                                </div>
                            </div>
                        </article>
                    </ItemTemplate>
                </asp:Repeater>
            </div>
        </div>
    </section>

    <section class="section-block" id="discover-challenges">
        <div class="container split-grid">
            <article class="about-panel">
                <div class="section-heading left">
                    <h2>限时挑战大厅</h2>
                    <p>这里适合喜欢快节奏活动和限时玩法的玩家，点开就能进入当前活动。</p>
                </div>
                <div class="mini-card-grid">
                    <asp:Repeater ID="rptChallenges" runat="server">
                        <ItemTemplate>
                            <a class="compact-card click-card interactive-card" href='<%# Eval("RouteUrl") %>'>
                                <img src='<%# Eval("CoverImage") %>' alt='<%# Eval("Title") %>' />
                                <div class="compact-card-body">
                                    <span class="badge-inline"><%# Eval("StatusTag") %></span>
                                    <h3><%# Eval("Title") %></h3>
                                    <p><%# Eval("Description") %></p>
                                    <p class="meta-copy">截止时间 <%# Eval("EndTime", "{0:yyyy-MM-dd HH:mm}") %></p>
                                    <p class="meta-copy">奖励 <%# Eval("RewardSummary") %></p>
                                    <span class="text-link strong">进入活动</span>
                                </div>
                            </a>
                        </ItemTemplate>
                    </asp:Repeater>
                </div>
            </article>

            <article class="about-panel" id="discover-live">
                <div class="section-heading left">
                    <h2>直播房间列表</h2>
                    <p>想围观热门车队、看 DM 带本节奏，或者先感受气氛再决定是否预约，都可以从这里进入。</p>
                </div>
                <div class="list-grid">
                    <asp:Repeater ID="rptLiveSessions" runat="server">
                        <ItemTemplate>
                            <article class="session-card modern-session-card">
                                <div>
                                    <span class="badge-inline"><%# Eval("StatusText") %></span>
                                    <h3><%# Eval("Title") %></h3>
                                    <p><%# Eval("Summary") %></p>
                                    <small>主持人 <%# Eval("HostName") %> · 热度 <%# Eval("HeatScore") %></small>
                                </div>
                                <div class="session-side">
                                    <strong><%# Eval("ViewerCount") %> 人观看</strong>
                                    <a class="btn-secondary small" href='<%# Eval("RouteUrl") %>'>进入观战</a>
                                </div>
                            </article>
                        </ItemTemplate>
                    </asp:Repeater>
                </div>
            </article>
        </div>
    </section>

    <section class="section-block alt">
        <div class="container split-grid">
            <article class="about-panel">
                <div class="section-heading left">
                    <h2>订阅权益</h2>
                    <p>常来玩的玩家可以在这里看看不同订阅档位，了解适合自己的预约、观战和互动权益。</p>
                </div>
                <div class="mini-card-grid">
                    <asp:Repeater ID="rptMembershipPlans" runat="server">
                        <ItemTemplate>
                            <a class="compact-card compact-card-text click-card" href="Wallet.aspx">
                                <div class="compact-card-body">
                                    <span class="badge-inline"><%# Eval("HighlightText") %></span>
                                    <h3><%# Eval("Name") %></h3>
                                    <p class="price-copy">¥<%# Eval("Price", "{0:F0}") %> / <%# Eval("BillingCycle") %></p>
                                    <p><%# Eval("Description") %></p>
                                    <p class="meta-copy"><%# Eval("BenefitSummary") %></p>
                                </div>
                            </a>
                        </ItemTemplate>
                    </asp:Repeater>
                </div>
            </article>

            <article class="about-panel">
                <div class="section-heading left">
                    <h2>身份选择</h2>
                    <p>适合新玩家快速理解自己的玩法倾向，也适合老玩家找更符合自己风格的位置。</p>
                </div>
                <div class="identity-grid">
                    <asp:Repeater ID="rptIdentityOptions" runat="server">
                        <ItemTemplate>
                            <a class="identity-card click-card" href="PlayerHub.aspx?tab=profile">
                                <span class="badge-inline"><%# Eval("RecommendedFor") %></span>
                                <h3><%# Eval("Name") %></h3>
                                <p><%# Eval("Description") %></p>
                                <p class="meta-copy">能力倾向 <%# Eval("AbilityFocus") %></p>
                            </a>
                        </ItemTemplate>
                    </asp:Repeater>
                </div>
            </article>
        </div>
    </section>
</asp:Content>
