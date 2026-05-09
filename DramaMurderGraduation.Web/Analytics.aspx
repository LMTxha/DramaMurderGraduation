<%@ Page Title="数据分析 | 剧本杀系统" Language="C#" MasterPageFile="~/Site.Master" AutoEventWireup="true" CodeBehind="Analytics.aspx.cs" Inherits="DramaMurderGraduation.Web.AnalyticsPage" %>
<%-- 页面用途：Analytics 页面负责承载对应功能的 Web Forms 标记、服务端控件和前端布局。 --%>
<asp:Content ID="Content1" ContentPlaceHolderID="TitleContent" runat="server">
    数据分析 | 剧本杀系统
</asp:Content>
<asp:Content ID="Content2" ContentPlaceHolderID="MainContent" runat="server">
    <%-- 页面分区：把当前页面内容按业务模块拆分展示。 --%>
    <section class="hero-section">
        <div class="container detail-grid">
            <%-- 说明卡片：展示页面主标题、摘要和关键标签。 --%>
            <article class="detail-copy">
                <div class="hero-badge-row">
                    <a class="site-badge" href="#analytics-filter">日期筛选</a>
                    <a class="site-badge soft" href="#analytics-overview">运营指标</a>
                    <a class="site-badge soft" href="#analytics-finance">资金概览</a>
                </div>
                <p class="eyebrow">ANALYTICS</p>
                <h1>门店运营看板</h1>
                <p class="hero-subtitle">按日期查看订单转化、复购、退款和 DM 场次，直接展示门店真实经营情况，适合答辩演示和后台日常复盘。</p>
                <%-- 摘要标签区：展示当前页面最重要的数量或状态提示。 --%>
                <div class="detail-tags">
                    <span>统计快照 <asp:Literal ID="litSnapshotDate" runat="server" /></span>
                    <span>统计区间 <asp:Literal ID="litDateRange" runat="server" /></span>
                </div>
            </article>

            <%-- 内容卡片：用于组织当前模块中的一组相关信息。 --%>
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

    <%-- 主要内容区：承载当前页面的核心业务列表、表单或详情内容。 --%>
    <section class="section-block" id="analytics-filter">
        <div class="container split-grid detail-split">
            <%-- 表单面板：承载筛选条件或业务提交输入项。 --%>
            <article class="form-panel">
                <%-- 模块标题区：说明当前业务模块的名称和处理说明。 --%>
                <div class="section-heading left">
                    <h2>日期筛选</h2>
                    <p>切换统计起止日期后，订单、营收、退款、复购和 DM 场次等指标会同步刷新。</p>
                </div>
                <%-- 面板控件 pnlFilterMessage：后台可通过 Visible/CssClass 控制整块内容是否显示以及提示样式。 --%>
                <asp:Panel ID="pnlFilterMessage" runat="server" Visible="false" CssClass="status-message">
                    <asp:Literal ID="litFilterMessage" runat="server" />
                </asp:Panel>
                <%-- 表单网格：按响应式布局排列输入框、下拉框和筛选条件。 --%>
                <div class="form-grid analytics-filter-grid">
                    <div class="field-group">
                        <label for="<%= txtStartDate.ClientID %>">开始日期</label>
                        <%-- 输入控件 txtStartDate：接收用户输入或展示后台已有备注。 --%>
                        <asp:TextBox ID="txtStartDate" runat="server" CssClass="input-control" TextMode="Date" />
                    </div>
                    <div class="field-group">
                        <label for="<%= txtEndDate.ClientID %>">结束日期</label>
                        <%-- 输入控件 txtEndDate：接收用户输入或展示后台已有备注。 --%>
                        <asp:TextBox ID="txtEndDate" runat="server" CssClass="input-control" TextMode="Date" />
                    </div>
                </div>
                <%-- 操作按钮 btnApplyFilter：点击后触发后台事件处理当前业务动作。 --%>
                <asp:Button ID="btnApplyFilter" runat="server" Text="应用筛选" CssClass="btn-primary" OnClick="btnApplyFilter_Click" />
            </article>

            <%-- 信息面板：承载一个独立的业务说明、列表或表单模块。 --%>
            <article class="about-panel">
                <%-- 模块标题区：说明当前业务模块的名称和处理说明。 --%>
                <div class="section-heading left">
                    <h2>核心指标</h2>
                    <p>把答辩时最有说服力的指标单独提炼出来，避免只展示静态图表而没有经营闭环。</p>
                </div>
                <%-- 统计网格：集中展示多个关键业务指标。 --%>
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

    <%-- 次级内容区：用于承载筛选、配置、辅助列表或补充信息。 --%>
    <section class="section-block alt" id="analytics-overview">
        <div class="container">
            <%-- 模块标题区：说明当前业务模块的名称和处理说明。 --%>
            <div class="section-heading">
                <h2>运营指标拆解</h2>
                <p>从转化、复购、退款和 DM 执行四个角度拆开看，更方便答辩时讲清楚整套门店运营链路。</p>
            </div>
            <div class="insight-grid">
                <%-- 数据列表控件 rptCompletionInsights：后台绑定集合数据后，按 ItemTemplate 循环渲染每条记录。 --%>
                <asp:Repeater ID="rptCompletionInsights" runat="server">
                    <%-- 列表项模板：定义 Repeater 中每一条业务记录的 HTML 结构和绑定字段。 --%>
                    <ItemTemplate>
                        <%-- 内容卡片：用于组织当前模块中的一组相关信息。 --%>
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

    <%-- 主要内容区：承载当前页面的核心业务列表、表单或详情内容。 --%>
    <section class="section-block" id="analytics-finance">
        <div class="container">
            <%-- 模块标题区：说明当前业务模块的名称和处理说明。 --%>
            <div class="section-heading">
                <h2>资金与履约</h2>
                <p>把营收、退款、回头客和有效订单放到同一个资金视角中，更适合做毕业设计答辩展示。</p>
            </div>
            <div class="achievement-grid">
                <%-- 数据列表控件 rptEconomyInsights：后台绑定集合数据后，按 ItemTemplate 循环渲染每条记录。 --%>
                <asp:Repeater ID="rptEconomyInsights" runat="server">
                    <%-- 列表项模板：定义 Repeater 中每一条业务记录的 HTML 结构和绑定字段。 --%>
                    <ItemTemplate>
                        <%-- 内容卡片：用于组织当前模块中的一组相关信息。 --%>
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
