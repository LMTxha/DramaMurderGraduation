<%@ Page Title="功能展示 | 剧本杀系统" Language="C#" MasterPageFile="~/Site.Master" AutoEventWireup="true" Inherits="DramaMurderGraduation.Web.FeatureShowcasePage" %>
<%-- 页面用途：场景搭建工具 页面负责承载对应功能的 Web Forms 标记、服务端控件和前端布局。 --%>
<asp:Content ID="Content1" ContentPlaceHolderID="TitleContent" runat="server">
    <asp:Literal ID="litDynamicTitle" runat="server" />
</asp:Content>
<asp:Content ID="Content2" ContentPlaceHolderID="MainContent" runat="server">
    <%-- 页面分区：把当前页面内容按业务模块拆分展示。 --%>
    <section class="hero-section">
        <div class="container detail-grid">
            <%-- 说明卡片：展示页面主标题、摘要和关键标签。 --%>
            <article class="detail-copy">
                <div class="hero-badge-row">
                    <span class="site-badge"><asp:Literal ID="litPageName" runat="server" /></span>
                    <span class="site-badge soft"><asp:Literal ID="litBadgeText" runat="server" /></span>
                </div>
                <p class="eyebrow"><asp:Literal ID="litEyebrow" runat="server" /></p>
                <h1><asp:Literal ID="litHeroTitle" runat="server" /></h1>
                <p class="hero-subtitle"><asp:Literal ID="litHeroSummary" runat="server" /></p>
                <p class="hero-text"><asp:Literal ID="litHeroDescription" runat="server" /></p>
                <%-- 操作按钮区：集中放置提交、重置、跳转或审核动作。 --%>
                <div class="hero-actions">
                    <%-- 跳转链接控件：根据绑定数据生成详情页、沟通页或外部页面入口。 --%>
                    <asp:HyperLink ID="lnkPrimaryAction" runat="server" CssClass="btn-primary" Visible="false" />
                    <%-- 跳转链接控件：根据绑定数据生成详情页、沟通页或外部页面入口。 --%>
                    <asp:HyperLink ID="lnkSecondaryAction" runat="server" CssClass="btn-secondary" Visible="false" />
                </div>
            </article>
            <%-- 内容卡片：用于组织当前模块中的一组相关信息。 --%>
            <article class="hero-panel metric-grid-four">
                <%-- 数据列表控件 rptHeroStats：后台绑定集合数据后，按 ItemTemplate 循环渲染每条记录。 --%>
                <asp:Repeater ID="rptHeroStats" runat="server">
                    <%-- 列表项模板：定义 Repeater 中每一条业务记录的 HTML 结构和绑定字段。 --%>
                    <ItemTemplate>
                        <div class="metric-card">
                            <p><%# Eval("StatLabel") %></p>
                            <strong><%# Eval("StatValue") %></strong>
                        </div>
                    </ItemTemplate>
                </asp:Repeater>
            </article>
        </div>
    </section>
    <%-- 数据列表控件 rptSections：后台绑定集合数据后，按 ItemTemplate 循环渲染每条记录。 --%>
    <asp:Repeater ID="rptSections" runat="server" OnItemDataBound="rptSections_ItemDataBound">
        <%-- 列表项模板：定义 Repeater 中每一条业务记录的 HTML 结构和绑定字段。 --%>
        <ItemTemplate>
            <%-- 主要内容区：承载当前页面的核心业务列表、表单或详情内容。 --%>
            <section id="sectionContainer" runat="server" class="section-block">
                <div class="container">
                    <%-- 模块标题区：说明当前业务模块的名称和处理说明。 --%>
                    <div class="section-heading">
                        <h2><%# Eval("SectionTitle") %></h2>
                        <p><%# Eval("SectionSummary") %></p>
                    </div>
                    <div class="mini-card-grid">
                        <%-- 数据列表控件 rptEntries：后台绑定集合数据后，按 ItemTemplate 循环渲染每条记录。 --%>
                        <asp:Repeater ID="rptEntries" runat="server">
                            <%-- 列表项模板：定义 Repeater 中每一条业务记录的 HTML 结构和绑定字段。 --%>
                            <ItemTemplate>
                                <%-- 内容卡片：用于组织当前模块中的一组相关信息。 --%>
                                <article class="compact-card">
                                    <img src='<%# Eval("ImageUrl") %>' alt='<%# Eval("Title") %>' />
                                    <div class="compact-card-body">
                                        <span class="badge-inline"><%# Eval("TagText") %></span>
                                        <h3><%# Eval("Title") %></h3>
                                        <p><%# Eval("Summary") %></p>
                                        <p class="meta-copy"><%# Eval("MetaPrimary") %></p>
                                        <p class="meta-copy"><%# Eval("MetaSecondary") %></p>
                                        <p class="meta-copy"><%# Eval("MetaTertiary") %></p>
                                        <p class="price-copy"><%# Eval("AccentValue") %></p>
                                        <a class="text-link strong" href='<%# Eval("ActionUrl") %>'><%# Eval("ActionText") %></a>
                                    </div>
                                </article>
                            </ItemTemplate>
                        </asp:Repeater>
                    </div>
                </div>
            </section>
        </ItemTemplate>
    </asp:Repeater>
</asp:Content>