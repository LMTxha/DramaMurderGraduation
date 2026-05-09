<%@ Page Title="核销通行证 | 剧本杀系统" Language="C#" MasterPageFile="~/Site.Master" AutoEventWireup="true" CodeBehind="CheckInPass.aspx.cs" Inherits="DramaMurderGraduation.Web.CheckInPassPage" %>
<%-- 页面用途：CheckInPass 页面负责承载对应功能的 Web Forms 标记、服务端控件和前端布局。 --%>
<asp:Content ID="Content1" ContentPlaceHolderID="TitleContent" runat="server">
    核销通行证 | 剧本杀系统
</asp:Content>
<asp:Content ID="Content2" ContentPlaceHolderID="MainContent" runat="server">
    <%-- 面板控件 pnlNotFound：后台可通过 Visible/CssClass 控制整块内容是否显示以及提示样式。 --%>
    <asp:Panel ID="pnlNotFound" runat="server" Visible="false" CssClass="section-block">
        <div class="container empty-state">
            <h1>未找到核销通行证</h1>
            <p>订单不存在，或当前账号没有查看该核销通行证的权限。</p>
            <a class="btn-primary" href="PlayerHub.aspx?tab=orders">返回我的订单</a>
        </div>
    </asp:Panel>

    <%-- 面板控件 pnlPass：后台可通过 Visible/CssClass 控制整块内容是否显示以及提示样式。 --%>
    <asp:Panel ID="pnlPass" runat="server" Visible="false">
        <%-- 页面头图区：展示当前功能的标题、说明和关键入口。 --%>
        <section class="detail-hero">
            <div class="container detail-grid">
                <%-- 说明卡片：展示页面主标题、摘要和关键标签。 --%>
                <article class="detail-copy">
                    <p class="eyebrow">CHECK-IN PASS</p>
                    <h1><asp:Literal ID="litScriptName" runat="server" /></h1>
                    <p class="hero-subtitle">订单 #<asp:Literal ID="litReservationId" runat="server" /> 的到店核销通行证</p>
                    <p class="hero-text">到店后向前台或主持人出示核销码。系统支持文本核销和二维码核销两种入口，核销后订单会自动变为“已到店”。</p>
                    <%-- 摘要标签区：展示当前页面最重要的数量或状态提示。 --%>
                    <div class="detail-tags">
                        <span>开场时间：<asp:Literal ID="litSessionTime" runat="server" /></span>
                        <span>房间：<asp:Literal ID="litRoomName" runat="server" /></span>
                        <span>DM：<asp:Literal ID="litHostName" runat="server" /></span>
                    </div>
                    <%-- 操作按钮区：集中放置提交、重置、跳转或审核动作。 --%>
                    <div class="hero-actions">
                        <%-- 跳转链接控件：根据绑定数据生成详情页、沟通页或外部页面入口。 --%>
                        <asp:HyperLink ID="lnkOrderDetails" runat="server" CssClass="btn-primary" Text="返回订单详情" />
                        <a class="btn-secondary" href="PlayerHub.aspx?tab=orders">返回订单列表</a>
                    </div>
                </article>

                <%-- 信息面板：承载一个独立的业务说明、列表或表单模块。 --%>
                <article class="about-panel checkin-pass-card">
                    <%-- 模块标题区：说明当前业务模块的名称和处理说明。 --%>
                    <div class="section-heading left">
                        <h2>核销二维码</h2>
                        <p>前台可以直接扫描二维码，也可以手动输入下方 6 位核销码。</p>
                    </div>
                    <div class="checkin-pass-grid">
                        <asp:Image ID="imgQrCode" runat="server" CssClass="checkin-pass-qr" AlternateText="核销二维码" />
                        <%-- 列表容器：承载 Repeater 渲染出的多条业务卡片。 --%>
                        <div class="reservation-list compact-reservation-list">
                            <%-- 业务卡片：展示一条预约、审核、消息或统计记录。 --%>
                            <article class="reservation-card">
                                <h3>核销码</h3>
                                <p class="checkin-code-strong"><asp:Literal ID="litCheckInCode" runat="server" /></p>
                            </article>
                            <%-- 业务卡片：展示一条预约、审核、消息或统计记录。 --%>
                            <article class="reservation-card">
                                <h3>当前状态</h3>
                                <p><asp:Literal ID="litStatus" runat="server" /></p>
                            </article>
                            <%-- 业务卡片：展示一条预约、审核、消息或统计记录。 --%>
                            <article class="reservation-card">
                                <h3>到店建议</h3>
                                <p><asp:Literal ID="litArrivalAdvice" runat="server" /></p>
                            </article>
                        </div>
                    </div>
                </article>
            </div>
        </section>
    </asp:Panel>
</asp:Content>
