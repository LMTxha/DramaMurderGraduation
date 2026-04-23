<%@ Page Title="数据分析 | 剧本杀系统" Language="C#" MasterPageFile="~/Site.Master" AutoEventWireup="true" CodeBehind="Analytics.aspx.cs" Inherits="DramaMurderGraduation.Web.AnalyticsPage" %>
<asp:Content ID="Content1" ContentPlaceHolderID="TitleContent" runat="server">
    数据分析 | 剧本杀系统
</asp:Content>
<asp:Content ID="Content2" ContentPlaceHolderID="MainContent" runat="server">
    <section class="hero-section">
        <div class="container detail-grid">
            <article class="detail-copy">
                <div class="hero-badge-row">
                    <a class="site-badge" href="#analytics-overview">经营看板</a>
                    <a class="site-badge soft" href="#analytics-economy">本周趋势</a>
                </div>
                <p class="eyebrow">ANALYTICS</p>
                <h1>门店经营看板</h1>
                <p class="hero-subtitle">把预约热度、玩家活跃、开本完成率和礼物收入汇总在一起，方便快速判断今晚哪一类玩法最受欢迎。</p>
                <div class="detail-tags">
                    <span>统计时间 <asp:Literal ID="litSnapshotDate" runat="server" /></span>
                    <span>转化率 <asp:Literal ID="litConversionRate" runat="server" /></span>
                </div>
            </article>

            <article class="hero-panel metric-grid-four">
                <a class="metric-card accent click-card interactive-card" href="PlayerHub.aspx">
                    <p>活跃用户</p>
                    <strong><asp:Literal ID="litActiveUsers" runat="server" /></strong>
                </a>
                <a class="metric-card click-card interactive-card" href="Rooms.aspx#room-sessions">
                    <p>平均局时</p>
                    <strong><asp:Literal ID="litAverageSessionMinutes" runat="server" /></strong>
                </a>
                <a class="metric-card click-card interactive-card" href="Booking.aspx">
                    <p>总预约数</p>
                    <strong><asp:Literal ID="litTotalBookings" runat="server" /></strong>
                </a>
                <a class="metric-card click-card interactive-card" href="Wallet.aspx">
                    <p>营收</p>
                    <strong><asp:Literal ID="litRevenueAmount" runat="server" /></strong>
                </a>
            </article>
        </div>
    </section>

    <section class="section-block" id="analytics-overview">
        <div class="container split-grid">
            <article class="about-panel">
                <div class="section-heading left">
                    <h2>玩家行为热力图</h2>
                    <p>通过不同区域和时段的热度变化，快速判断玩家更偏爱哪种房间和开局节奏。</p>
                </div>
                <div class="insight-grid">
                    <asp:Repeater ID="rptHeatmapZones" runat="server">
                        <ItemTemplate>
                            <a class="heatmap-card click-card interactive-card" href="Rooms.aspx#room-sessions">
                                <p class="metric-kicker"><%# Eval("PeakPeriod") %></p>
                                <h3><%# Eval("ZoneName") %></h3>
                                <strong>热度 <%# Eval("HeatLevel") %></strong>
                                <p><%# Eval("Summary") %></p>
                            </a>
                        </ItemTemplate>
                    </asp:Repeater>
                </div>
            </article>

            <article class="about-panel">
                <div class="section-heading left">
                    <h2>完成率与通过率</h2>
                    <p>这里会汇总每类玩法的完成率和推进表现，方便复盘哪一类剧本最受欢迎。</p>
                </div>
                <div class="list-grid">
                    <asp:Repeater ID="rptCompletionInsights" runat="server">
                        <ItemTemplate>
                            <a class="session-card modern-session-card click-card interactive-card" href="ScriptsList.aspx">
                                <div>
                                    <span class="badge-inline"><%# Eval("MetricType") %></span>
                                    <h3><%# Eval("Name") %></h3>
                                    <p><%# Eval("Summary") %></p>
                                </div>
                                <div class="session-side">
                                    <strong><%# Eval("ValueDecimal", "{0:F1}") %>%</strong>
                                </div>
                            </a>
                        </ItemTemplate>
                    </asp:Repeater>
                </div>
            </article>
        </div>
    </section>

    <section class="section-block alt" id="analytics-economy">
        <div class="container">
            <div class="section-heading">
                <h2>虚拟经济与收益设置</h2>
                <p>这里会把预约消费、礼物互动和充值变化汇总成一眼能看懂的经营趋势。</p>
            </div>
            <div class="achievement-grid">
                <asp:Repeater ID="rptEconomyInsights" runat="server">
                    <ItemTemplate>
                        <a class="achievement-card click-card interactive-card" href="Wallet.aspx">
                            <span class="badge-inline"><%# Eval("CategoryName") %></span>
                            <h3><%# Eval("MetricName") %></h3>
                            <p class="price-copy">¥<%# Eval("MetricValue", "{0:F2}") %></p>
                            <p class="meta-copy"><%# Eval("TrendText") %></p>
                        </a>
                    </ItemTemplate>
                </asp:Repeater>
            </div>
        </div>
    </section>
</asp:Content>
