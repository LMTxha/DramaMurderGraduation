<%@ Page Title="首页 | 剧本杀系统" Language="C#" MasterPageFile="~/Site.Master" AutoEventWireup="true" CodeBehind="Default.aspx.cs" Inherits="DramaMurderGraduation.Web.DefaultPage" %>
<asp:Content ID="Content1" ContentPlaceHolderID="TitleContent" runat="server">
    首页 | 剧本杀系统
</asp:Content>
<asp:Content ID="Content2" ContentPlaceHolderID="MainContent" runat="server">
    <section class="hero-section">
        <div class="container hero-grid homepage-hero">
            <article class="hero-copy hero-copy-immersive">
                <div class="hero-badge-row">
                    <a class="site-badge" href="ScriptsList.aspx">热门剧本</a>
                    <a class="site-badge soft" href="Booking.aspx">快速预约</a>
                </div>
                <p class="eyebrow">MYSTERY THEATER</p>
                <h1><asp:Literal ID="litHeroTitle" runat="server" /></h1>
                <p class="hero-subtitle"><asp:Literal ID="litHeroSubtitle" runat="server" /></p>
                <p class="hero-text"><asp:Literal ID="litWelcomeText" runat="server" /></p>
                <div class="hero-actions">
                    <a class="btn-primary" href="ScriptsList.aspx">进入剧本库</a>
                    <a class="btn-secondary" href="Booking.aspx">立即预约场次</a>
                </div>

                <div class="hero-feature-list">
                    <a class="feature-chip" href="ScriptsList.aspx">
                        <strong><asp:Literal ID="litScriptCount" runat="server" /></strong>
                        <span>正在热推的剧本内容</span>
                    </a>
                    <a class="feature-chip" href="Rooms.aspx">
                        <strong><asp:Literal ID="litReservationCount" runat="server" /></strong>
                        <span>近期排期与预约热度</span>
                    </a>
                </div>
            </article>

            <article class="hero-panel immersive-panel">
                <a class="metric-card accent" href="Reviews.aspx">
                    <p>综合评分</p>
                    <strong><asp:Literal ID="litAverageRating" runat="server" /></strong>
                </a>
                <a class="metric-card" href="ScriptsList.aspx">
                    <p>角色数量</p>
                    <strong><asp:Literal ID="litCharacterCount" runat="server" /></strong>
                </a>
                <a class="metric-card" href="Rooms.aspx">
                    <p>主题房间</p>
                    <strong><asp:Literal ID="litRoomCount" runat="server" /></strong>
                </a>
                <div class="showcase-card">
                    <h3>今晚去哪一局</h3>
                    <p>从热门剧本、近期场次、房间客厅和玩家口碑里，快速找到最适合你们这一车的玩法。</p>
                    <a class="text-link strong" href="Discover.aspx">查看发现中心</a>
                </div>
            </article>
        </div>
    </section>

    <section class="section-block">
        <div class="container">
            <div class="section-heading">
                <h2>店内公告</h2>
                <p>近期活动、场次提醒和门店通知都会汇总在这里，方便玩家快速掌握开场信息。</p>
            </div>
            <div class="notice-grid">
                <asp:Repeater ID="rptAnnouncements" runat="server">
                    <ItemTemplate>
                        <article class="notice-card highlight-card">
                            <span class='notice-tag <%# (bool)Eval("IsImportant") ? "hot" : "normal" %>'><%# (bool)Eval("IsImportant") ? "重点" : "通知" %></span>
                            <h3><%# Eval("Title") %></h3>
                            <p><%# Eval("Summary") %></p>
                            <small><%# Eval("PublishDate", "{0:yyyy-MM-dd}") %></small>
                        </article>
                    </ItemTemplate>
                </asp:Repeater>
            </div>
        </div>
    </section>

    <section class="section-block alt">
        <div class="container">
            <div class="section-heading">
                <h2>今日推荐</h2>
                <p>精选沉浸、推理、机制等不同类型的剧本，点开就能直达详情或预约入口。</p>
            </div>
            <div class="card-grid featured-grid">
                <asp:Repeater ID="rptFeaturedScripts" runat="server">
                    <ItemTemplate>
                        <article class="script-card featured-script-card">
                            <img src='<%# Eval("CoverImage") %>' alt='<%# Eval("Name") %>' />
                            <div class="card-body">
                                <div class="card-meta">
                                    <span><%# Eval("GenreName") %></span>
                                    <span><%# Eval("Difficulty") %></span>
                                    <span>评分 <%# Eval("AverageRating", "{0:F1}") %></span>
                                </div>
                                <h3><%# Eval("Name") %></h3>
                                <p><%# Eval("Slogan") %></p>
                                <div class="card-stats">
                                    <span><%# Eval("PlayerMin") %>-<%# Eval("PlayerMax") %> 人</span>
                                    <span><%# Eval("DurationMinutes") %> 分钟</span>
                                    <span>¥<%# Eval("Price", "{0:F0}") %></span>
                                </div>
                                <div class="card-actions">
                                    <a class="btn-primary" href='ScriptDetails.aspx?id=<%# Eval("Id") %>'>查看详情</a>
                                    <a class="text-link strong" href='Booking.aspx?scriptId=<%# Eval("Id") %>'>直接预约</a>
                                </div>
                            </div>
                        </article>
                    </ItemTemplate>
                </asp:Repeater>
            </div>
        </div>
    </section>

    <section class="section-block">
        <div class="container split-grid">
            <article class="about-panel">
                <div class="section-heading left">
                    <h2>近期开放场次</h2>
                    <p>想拼车、想约熟人局，或者想看看哪位 DM 在带热门本，都可以从这里快速进入预约。</p>
                </div>
                <asp:Repeater ID="rptUpcomingSessions" runat="server">
                    <ItemTemplate>
                        <article class="session-card wide modern-session-card">
                            <div>
                                <h3><%# Eval("ScriptName") %></h3>
                                <p><%# Eval("RoomName") %> · <%# Eval("HostName") %></p>
                                <small><%# Eval("SessionDateTime", "{0:yyyy-MM-dd HH:mm}") %></small>
                            </div>
                            <div class="session-side">
                                <strong>剩余 <%# Eval("RemainingSeats") %> 位</strong>
                                <a class="btn-secondary small" href='Booking.aspx?sessionId=<%# Eval("Id") %>'>预约</a>
                            </div>
                        </article>
                    </ItemTemplate>
                </asp:Repeater>
            </article>

            <article class="about-panel editorial-panel">
                <div class="section-heading left">
                    <h2><asp:Literal ID="litAboutTitle" runat="server" /></h2>
                    <p>这里是门店首页的导览区，帮助玩家快速决定今天玩什么、看什么、约哪一场。</p>
                </div>
                <p class="about-text"><asp:Literal ID="litAboutContent" runat="server" /></p>
                <div class="hero-actions">
                    <a class="btn-secondary" href="Discover.aspx">去发现中心</a>
                    <a class="text-link strong" href="PlayerHub.aspx?tab=social">去玩家互动</a>
                </div>
            </article>
        </div>
    </section>

    <section class="section-block alt">
        <div class="container">
            <div class="section-heading">
                <h2>玩家口碑反馈</h2>
                <p>真实评价能帮助你更快判断一本剧本适不适合自己的车队和当晚氛围。</p>
            </div>
            <div class="review-grid">
                <asp:Repeater ID="rptLatestReviews" runat="server">
                    <ItemTemplate>
                        <article class="review-card premium-review-card">
                            <span class="review-tag"><%# Eval("HighlightTag") %></span>
                            <h3><%# Eval("ScriptName") %></h3>
                            <p class="review-rating">评分 <%# Eval("Rating") %>.0 / 5</p>
                            <p><%# Eval("Content") %></p>
                            <small><%# Eval("ReviewerName") %> · <%# Eval("ReviewDate", "{0:yyyy-MM-dd}") %></small>
                        </article>
                    </ItemTemplate>
                </asp:Repeater>
            </div>
        </div>
    </section>
</asp:Content>
