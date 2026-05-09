<%@ Page Title="后台模块详情 | 剧本杀系统" Language="C#" MasterPageFile="~/Site.Master" AutoEventWireup="true" CodeBehind="AdminModule.aspx.cs" Inherits="DramaMurderGraduation.Web.AdminModulePage" MaintainScrollPositionOnPostback="true" %>

<asp:Content ID="Content1" ContentPlaceHolderID="TitleContent" runat="server">
    <asp:Literal ID="litPageTitle" runat="server" />
</asp:Content>

<asp:Content ID="Content2" ContentPlaceHolderID="MainContent" runat="server">
    <%-- 本页把后台总览中的统计入口拆成独立列表，演示时可以逐项说明各类运营数据如何进入后台。 --%>
    <section class="detail-hero admin-module-hero">
        <div class="container detail-grid">
            <%-- 左侧展示当前模块名称、模块说明和记录数量，帮助管理员确认正在查看哪类数据。 --%>
            <article class="detail-copy">
                <p class="eyebrow">ADMIN MODULE</p>
                <h1><asp:Literal ID="litModuleTitle" runat="server" /></h1>
                <p class="hero-subtitle"><asp:Literal ID="litModuleSummary" runat="server" /></p>
                <div class="detail-tags">
                    <span>当前记录 <asp:Literal ID="litModuleCount" runat="server" /></span>
                    <asp:HyperLink ID="lnkBackToAdmin" runat="server" CssClass="btn-secondary small" NavigateUrl="AdminReview.aspx" Text="返回后台总览" />
                </div>
            </article>

            <%-- 右侧导航复用同一个详情页，通过 module 参数切换待审用户、充值、剧本、预约等模块。 --%>
            <article class="about-panel">
                <div class="section-heading left">
                    <h2>模块导航</h2>
                    <p>点击任意入口可切换到对应后台模块，单独查看该模块的数据。</p>
                </div>
                <div class="admin-module-nav">
                    <a href="AdminModule.aspx?module=pending-users">待审用户</a>
                    <a href="AdminModule.aspx?module=pending-recharge">待审充值</a>
                    <a href="AdminModule.aspx?module=pending-scripts">待审剧本</a>
                    <a href="AdminModule.aspx?module=store-visits">到店联系单</a>
                    <a href="AdminModule.aspx?module=reservations">预约订单</a>
                    <a href="AdminModule.aspx?module=scripts">剧本总数</a>
                    <a href="AdminModule.aspx?module=today-store">今日到店</a>
                    <a href="AdminModule.aspx?module=today-reservations">今日预约</a>
                    <a href="AdminModule.aspx?module=upcoming-sessions">未来场次</a>
                    <a href="AdminModule.aspx?module=announcements">公告数量</a>
                    <a href="AdminModule.aspx?module=arranged-store">已安排到店</a>
                    <a href="AdminModule.aspx?module=confirmed-reservations">已确认预约</a>
                </div>
            </article>
        </div>
    </section>

    <section class="section-block">
        <div class="container">
            <%-- 权限不足时只显示提示，不绑定列表数据，避免越权查看后台记录。 --%>
            <asp:Panel ID="pnlAccessDenied" runat="server" Visible="false" CssClass="status-message error">
                <asp:Literal ID="litAccessDenied" runat="server" />
            </asp:Panel>

            <%-- 操作成功或失败的结果统一显示在这里，例如删除已结束预约后的提示。 --%>
            <asp:Panel ID="pnlMessage" runat="server" Visible="false" CssClass="status-message">
                <asp:Literal ID="litMessage" runat="server" />
            </asp:Panel>

            <%-- 当前模块没有记录时展示空状态，说明页面已加载但暂无待处理数据。 --%>
            <asp:Panel ID="pnlEmpty" runat="server" Visible="false" CssClass="status-message">
                当前模块暂无记录。
            </asp:Panel>

            <div class="reservation-list admin-module-list">
                <%-- 列表项由后台统一转成 AdminModuleItem，可承载用户、充值、剧本、预约和联系单等不同数据。 --%>
                <asp:Repeater ID="rptModuleItems" runat="server" OnItemCommand="rptModuleItems_ItemCommand">
                    <ItemTemplate>
                        <article class="reservation-card admin-module-card">
                            <span class="badge-inline soft"><%# Eval("Badge") %></span>
                            <h3><%# Eval("Title") %></h3>
                            <p><%# Eval("PrimaryMeta") %></p>
                            <p><%# Eval("SecondaryMeta") %></p>
                            <p class="meta-copy"><%# Eval("Description") %></p>
                            <div class="hero-actions">
                                <asp:HyperLink runat="server" CssClass="btn-secondary small" NavigateUrl='<%# Eval("ActionUrl") %>' Text='<%# Eval("ActionText") %>' Visible='<%# HasActionUrl(Eval("ActionUrl")) %>' />
                                <%-- 只有已完成或已取消的预约允许清理，删除前二次确认，避免误删仍在履约中的订单。 --%>
                                <asp:Button ID="btnDeleteReservation" runat="server" Text="删除信息" CssClass="btn-secondary small danger-button" CommandName="DeleteReservation" CommandArgument='<%# Eval("ReservationId") %>' CausesValidation="false" Visible='<%# Eval("CanDeleteReservation") %>' OnClientClick="return confirm('确认永久删除这条已取消或已完成的订单信息吗？相关房间消息、投票、角色分配和订单会话记录也会一并删除。');" />
                            </div>
                        </article>
                    </ItemTemplate>
                </asp:Repeater>
            </div>
        </div>
    </section>
</asp:Content>