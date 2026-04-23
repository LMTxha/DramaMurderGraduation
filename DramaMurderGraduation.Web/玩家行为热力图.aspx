<%@ Page Title="功能展示 | 剧本杀系统" Language="C#" MasterPageFile="~/Site.Master" AutoEventWireup="true" Inherits="DramaMurderGraduation.Web.FeatureShowcasePage" %>
<asp:Content ID="Content1" ContentPlaceHolderID="TitleContent" runat="server">
    <asp:Literal ID="litDynamicTitle" runat="server" />
</asp:Content>
<asp:Content ID="Content2" ContentPlaceHolderID="MainContent" runat="server">
    <section class="hero-section">
        <div class="container detail-grid">
            <article class="detail-copy">
                <div class="hero-badge-row">
                    <span class="site-badge"><asp:Literal ID="litPageName" runat="server" /></span>
                    <span class="site-badge soft"><asp:Literal ID="litBadgeText" runat="server" /></span>
                </div>
                <p class="eyebrow"><asp:Literal ID="litEyebrow" runat="server" /></p>
                <h1><asp:Literal ID="litHeroTitle" runat="server" /></h1>
                <p class="hero-subtitle"><asp:Literal ID="litHeroSummary" runat="server" /></p>
                <p class="hero-text"><asp:Literal ID="litHeroDescription" runat="server" /></p>
                <div class="hero-actions">
                    <asp:HyperLink ID="lnkPrimaryAction" runat="server" CssClass="btn-primary" Visible="false" />
                    <asp:HyperLink ID="lnkSecondaryAction" runat="server" CssClass="btn-secondary" Visible="false" />
                </div>
            </article>
            <article class="hero-panel metric-grid-four">
                <asp:Repeater ID="rptHeroStats" runat="server">
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
    <asp:Repeater ID="rptSections" runat="server" OnItemDataBound="rptSections_ItemDataBound">
        <ItemTemplate>
            <section id="sectionContainer" runat="server" class="section-block">
                <div class="container">
                    <div class="section-heading">
                        <h2><%# Eval("SectionTitle") %></h2>
                        <p><%# Eval("SectionSummary") %></p>
                    </div>
                    <div class="mini-card-grid">
                        <asp:Repeater ID="rptEntries" runat="server">
                            <ItemTemplate>
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