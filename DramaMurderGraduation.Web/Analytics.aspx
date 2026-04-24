<%@ Page Title="数据分析 | 剧本杀系统" Language="C#" MasterPageFile="~/Site.Master" AutoEventWireup="true" CodeBehind="Analytics.aspx.cs" Inherits="DramaMurderGraduation.Web.AnalyticsPage" %>
<asp:Content ID="Content1" ContentPlaceHolderID="TitleContent" runat="server">
    数据分析 | 剧本杀系统
</asp:Content>
<asp:Content ID="Content2" ContentPlaceHolderID="MainContent" runat="server">
    <section class="hero-section">
        <div class="container detail-grid">
            <article class="detail-copy">
                <div class="hero-badge-row">
                    <a class="site-badge" href="#analytics-filter">日期筛选</a>
                    <a class="site-badge soft" href="#analytics-overview">运营指标</a>
                    <a class="site-badge soft" href="#analytics-finance">资金概览</a>
                </div>
                <p class="eyebrow">ANALYTICS</p>
                <h1>门店运营看板</h1>
                <p class="hero-subtitle">按日期查看订单转化、复购、退款和 DM 场次，直接展示门店真实经营情况，适合答辩演示和后台日常复盘。</p>
                <div class="detail-tags">
                    <span>统计快照 <asp:Literal ID="litSnapshotDate" runat="server" /></span>
                    <span>统计区间 <asp:Literal ID="litDateRange" runat="server" /></span>
                </div>
            </article>

            <article class="hero-panel metric-grid-four">
                <div class="metric-card accent">
                    <p>订单转化率</p>
                    <strong><asp:Literal ID="litConversionRate" runat="server" /></strong>
                </div>
                <div class="metric-card">
                    <p>活跃下单用户</p>
                    <strong><asp:Literal ID="litActiveUsers" runat="server" /></strong>
                </div>
                <div class="metric-card">
                    <p>总预约数</p>
                    <strong><asp:Literal ID="litTotalBookings" runat="server" /></strong>
                </div>
                <div class="metric-card">
                    <p>营收</p>
                    <strong><asp:Literal ID="litRevenueAmount" runat="server" /></strong>
                </div>
            </article>
        </div>
    </section>

    <section class="section-block" id="analytics-filter">
        <div class="container split-grid detail-split">
            <article class="form-panel">
                <div class="section-heading left">
                    <h2>日期筛选</h2>
                    <p>切换统计起止日期后，订单、营收、退款、复购和 DM 场次等指标会同步刷新。</p>
                </div>
                <asp:Panel ID="pnlFilterMessage" runat="server" Visible="false" CssClass="status-message">
                    <asp:Literal ID="litFilterMessage" runat="server" />
                </asp:Panel>
                <div class="form-grid analytics-filter-grid">
                    <div class="field-group">
                        <label for="<%= txtStartDate.ClientID %>">开始日期</label>
                        <asp:TextBox ID="txtStartDate" runat="server" CssClass="input-control" TextMode="Date" />
                    </div>
                    <div class="field-group">
                        <label for="<%= txtEndDate.ClientID %>">结束日期</label>
                        <asp:TextBox ID="txtEndDate" runat="server" CssClass="input-control" TextMode="Date" />
                    </div>
                </div>
                <asp:Button ID="btnApplyFilter" runat="server" Text="应用筛选" CssClass="btn-primary" OnClick="btnApplyFilter_Click" />
            </article>

            <article class="about-panel">
                <div class="section-heading left">
                    <h2>核心指标</h2>
                    <p>把答辩时最有说服力的指标单独提炼出来，避免只展示静态图表而没有经营闭环。</p>
                </div>
                <div class="analytics-kpi-grid">
                    <div class="analytics-stat-card">
                        <p>客单价</p>
                        <strong><asp:Literal ID="litAverageOrderValue" runat="server" /></strong>
                        <small>按已确认订单计算的人均订单价值</small>
                    </div>
                    <div class="analytics-stat-card">
                        <p>复购率</p>
                        <strong><asp:Literal ID="litRepurchaseRate" runat="server" /></strong>
                        <small>历史有消费记录用户的再次下单占比</small>
                    </div>
                    <div class="analytics-stat-card">
                        <p>退款率</p>
                        <strong><asp:Literal ID="litRefundRate" runat="server" /></strong>
                        <small>完成退款申请占总预约的比率</small>
                    </div>
                    <div class="analytics-stat-card">
                        <p>DM 场次</p>
                        <strong><asp:Literal ID="litDmSessionCount" runat="server" /></strong>
                        <small>统计区间内已排班的主持场次</small>
                    </div>
                    <div class="analytics-stat-card">
                        <p>平均局时</p>
                        <strong><asp:Literal ID="litAverageSessionMinutes" runat="server" /></strong>
                        <small>按剧本排期时长估算的平均开局时长</small>
                    </div>
                    <div class="analytics-stat-card">
                        <p>已完成订单</p>
                        <strong><asp:Literal ID="litCompletedBookings" runat="server" /></strong>
                        <small>用于展示预约到到店完成的履约闭环</small>
                    </div>
                </div>
            </article>
        </div>
    </section>

    <section class="section-block alt" id="analytics-overview">
        <div class="container">
            <div class="section-heading">
                <h2>运营指标拆解</h2>
                <p>从转化、复购、退款和 DM 执行四个角度拆开看，更方便答辩时讲清楚整套门店运营链路。</p>
            </div>
            <div class="insight-grid">
                <asp:Repeater ID="rptCompletionInsights" runat="server">
                    <ItemTemplate>
                        <article class="achievement-card analytics-insight-card">
                            <span class="badge-inline"><%# Eval("MetricType") %></span>
                            <h3><%# Eval("Name") %></h3>
                            <p class="price-copy"><%# Eval("ValueDecimal", "{0:F1}") %><%# GetInsightUnit(Container.DataItem) %></p>
                            <p class="meta-copy"><%# Eval("Summary") %></p>
                        </article>
                    </ItemTemplate>
                </asp:Repeater>
            </div>
        </div>
    </section>

    <section class="section-block" id="analytics-finance">
        <div class="container">
            <div class="section-heading">
                <h2>资金与履约</h2>
                <p>把营收、退款、回头客和有效订单放到同一个资金视角中，更适合做毕业设计答辩展示。</p>
            </div>
            <div class="achievement-grid">
                <asp:Repeater ID="rptEconomyInsights" runat="server">
                    <ItemTemplate>
                        <article class="achievement-card analytics-insight-card">
                            <span class="badge-inline"><%# Eval("CategoryName") %></span>
                            <h3><%# Eval("MetricName") %></h3>
                            <p class="price-copy"><%# Eval("MetricValue", "{0:F2}") %><%# GetEconomyUnit(Container.DataItem) %></p>
                            <p class="meta-copy"><%# Eval("TrendText") %></p>
                        </article>
                    </ItemTemplate>
                </asp:Repeater>
            </div>
        </div>
    </section>
</asp:Content>
