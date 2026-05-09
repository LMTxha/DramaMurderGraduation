<%@ Page Title="首页 | 剧本杀系统" Language="C#" MasterPageFile="~/Site.Master" AutoEventWireup="true" CodeBehind="Default.aspx.cs" Inherits="DramaMurderGraduation.Web.DefaultPage" %>
<%-- 页面用途：Default 页面负责承载对应功能的 Web Forms 标记、服务端控件和前端布局。 --%>
<asp:Content ID="Content1" ContentPlaceHolderID="TitleContent" runat="server">
    首页 | 剧本杀系统
</asp:Content>
<asp:Content ID="Content2" ContentPlaceHolderID="MainContent" runat="server">
    <%-- 页面分区：把当前页面内容按业务模块拆分展示。 --%>
    <section class="hero-section">
        <div class="container hero-grid homepage-hero">
            <%-- 内容卡片：用于组织当前模块中的一组相关信息。 --%>
            <article class="hero-copy hero-copy-immersive">
                <div class="hero-badge-row">
                    <a class="site-badge" href="ScriptsList.aspx">热门剧本</a>
                    <a class="site-badge soft" href="Booking.aspx">快速预约</a>
                </div>
                <p class="eyebrow">MYSTERY THEATER</p>
                <h1><asp:Literal ID="litHeroTitle" runat="server" /></h1>
                <p class="hero-subtitle"><asp:Literal ID="litHeroSubtitle" runat="server" /></p>
                <p class="hero-text"><asp:Literal ID="litWelcomeText" runat="server" /></p>
                <%-- 操作按钮区：集中放置提交、重置、跳转或审核动作。 --%>
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

            <%-- 内容卡片：用于组织当前模块中的一组相关信息。 --%>
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

    <%-- 主要内容区：承载当前页面的核心业务列表、表单或详情内容。 --%>
    <section class="section-block">
        <div class="container">
            <%-- 模块标题区：说明当前业务模块的名称和处理说明。 --%>
            <div class="section-heading">
                <h2>店内公告</h2>
                <p>近期活动、场次提醒和门店通知都会汇总在这里，方便玩家快速掌握开场信息。</p>
            </div>
            <div class="notice-grid">
                <%-- 数据列表控件 rptAnnouncements：后台绑定集合数据后，按 ItemTemplate 循环渲染每条记录。 --%>
                <asp:Repeater ID="rptAnnouncements" runat="server">
                    <%-- 列表项模板：定义 Repeater 中每一条业务记录的 HTML 结构和绑定字段。 --%>
                    <ItemTemplate>
                        <%-- 内容卡片：用于组织当前模块中的一组相关信息。 --%>
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

    <%-- 次级内容区：用于承载筛选、配置、辅助列表或补充信息。 --%>
    <section class="section-block alt">
        <div class="container">
            <%-- 模块标题区：说明当前业务模块的名称和处理说明。 --%>
            <div class="section-heading">
                <h2>今日推荐</h2>
                <p>精选沉浸、推理、机制等不同类型的剧本，点开就能直达详情或预约入口。</p>
            </div>
            <div class="recommendation-carousel" data-recommendation-carousel data-visible-desktop="1" data-visible-mobile="1" data-interval="4500">
                <div class="recommendation-carousel-toolbar" aria-label="今日推荐轮播控制">
                    <button type="button" class="recommendation-nav-button" data-carousel-prev aria-label="上一组推荐" title="上一组推荐">&lsaquo;</button>
                    <div class="recommendation-dots" data-carousel-dots aria-label="推荐剧本位置"></div>
                    <button type="button" class="recommendation-nav-button" data-carousel-next aria-label="下一组推荐" title="下一组推荐">&rsaquo;</button>
                </div>
                <div class="card-grid featured-grid recommendation-track" data-carousel-track aria-live="polite">
                <%-- 数据列表控件 rptFeaturedScripts：后台绑定集合数据后，按 ItemTemplate 循环渲染每条记录。 --%>
                <asp:Repeater ID="rptFeaturedScripts" runat="server">
                    <%-- 列表项模板：定义 Repeater 中每一条业务记录的 HTML 结构和绑定字段。 --%>
                    <ItemTemplate>
                        <%-- 内容卡片：用于组织当前模块中的一组相关信息。 --%>
                        <article class="script-card featured-script-card recommendation-slide" data-carousel-item>
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
        </div>
    </section>

    <%-- 主要内容区：承载当前页面的核心业务列表、表单或详情内容。 --%>
    <section class="section-block">
        <div class="container split-grid">
            <%-- 信息面板：承载一个独立的业务说明、列表或表单模块。 --%>
            <article class="about-panel">
                <%-- 模块标题区：说明当前业务模块的名称和处理说明。 --%>
                <div class="section-heading left">
                    <h2>近期开放场次</h2>
                    <p>想拼车、想约熟人局，或者想看看哪位 DM 在带热门本，都可以从这里快速进入预约。</p>
                </div>
                <%-- 数据列表控件 rptUpcomingSessions：后台绑定集合数据后，按 ItemTemplate 循环渲染每条记录。 --%>
                <asp:Repeater ID="rptUpcomingSessions" runat="server">
                    <%-- 列表项模板：定义 Repeater 中每一条业务记录的 HTML 结构和绑定字段。 --%>
                    <ItemTemplate>
                        <%-- 内容卡片：用于组织当前模块中的一组相关信息。 --%>
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

            <%-- 信息面板：承载一个独立的业务说明、列表或表单模块。 --%>
            <article class="about-panel editorial-panel">
                <%-- 模块标题区：说明当前业务模块的名称和处理说明。 --%>
                <div class="section-heading left">
                    <h2><asp:Literal ID="litAboutTitle" runat="server" /></h2>
                    <p>这里是门店首页的导览区，帮助玩家快速决定今天玩什么、看什么、约哪一场。</p>
                </div>
                <p class="about-text"><asp:Literal ID="litAboutContent" runat="server" /></p>
                <%-- 操作按钮区：集中放置提交、重置、跳转或审核动作。 --%>
                <div class="hero-actions">
                    <a class="btn-secondary" href="Discover.aspx">去发现中心</a>
                    <a class="text-link strong" href="PlayerHub.aspx?tab=social">去玩家互动</a>
                </div>
            </article>
        </div>
    </section>

    <%-- 次级内容区：用于承载筛选、配置、辅助列表或补充信息。 --%>
    <section class="section-block alt">
        <div class="container">
            <%-- 模块标题区：说明当前业务模块的名称和处理说明。 --%>
            <div class="section-heading">
                <h2>玩家口碑反馈</h2>
                <p>真实评价能帮助你更快判断一本剧本适不适合自己的车队和当晚氛围。</p>
            </div>
            <div class="review-grid">
                <%-- 数据列表控件 rptLatestReviews：后台绑定集合数据后，按 ItemTemplate 循环渲染每条记录。 --%>
                <asp:Repeater ID="rptLatestReviews" runat="server">
                    <%-- 列表项模板：定义 Repeater 中每一条业务记录的 HTML 结构和绑定字段。 --%>
                    <ItemTemplate>
                        <%-- 内容卡片：用于组织当前模块中的一组相关信息。 --%>
                        <a class="review-card premium-review-card interactive-review-card" href='Reviews.aspx?scriptId=<%# Eval("ScriptId") %>#reviews'>
                            <span class="review-tag"><%# Eval("HighlightTag") %></span>
                            <h3><%# Eval("ScriptName") %></h3>
                            <p class="review-rating">评分 <%# Eval("Rating") %>.0 / 5</p>
                            <p><%# Eval("Content") %></p>
                            <small><%# Eval("ReviewerName") %> · <%# Eval("ReviewDate", "{0:yyyy-MM-dd}") %></small>
                            <span class="review-card-action">查看该剧本评价</span>
                        </a>
                    </ItemTemplate>
                </asp:Repeater>
            </div>
        </div>
    </section>
</asp:Content>
