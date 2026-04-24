<%@ Page Title="核销通行证 | 剧本杀系统" Language="C#" MasterPageFile="~/Site.Master" AutoEventWireup="true" CodeBehind="CheckInPass.aspx.cs" Inherits="DramaMurderGraduation.Web.CheckInPassPage" %>
<asp:Content ID="Content1" ContentPlaceHolderID="TitleContent" runat="server">
    核销通行证 | 剧本杀系统
</asp:Content>
<asp:Content ID="Content2" ContentPlaceHolderID="MainContent" runat="server">
    <asp:Panel ID="pnlNotFound" runat="server" Visible="false" CssClass="section-block">
        <div class="container empty-state">
            <h1>未找到核销通行证</h1>
            <p>订单不存在，或当前账号没有查看该核销通行证的权限。</p>
            <a class="btn-primary" href="PlayerHub.aspx?tab=orders">返回我的订单</a>
        </div>
    </asp:Panel>

    <asp:Panel ID="pnlPass" runat="server" Visible="false">
        <section class="detail-hero">
            <div class="container detail-grid">
                <article class="detail-copy">
                    <p class="eyebrow">CHECK-IN PASS</p>
                    <h1><asp:Literal ID="litScriptName" runat="server" /></h1>
                    <p class="hero-subtitle">订单 #<asp:Literal ID="litReservationId" runat="server" /> 的到店核销通行证</p>
                    <p class="hero-text">到店后向前台或主持人出示核销码。系统支持文本核销和二维码核销两种入口，核销后订单会自动变为“已到店”。</p>
                    <div class="detail-tags">
                        <span>开场时间：<asp:Literal ID="litSessionTime" runat="server" /></span>
                        <span>房间：<asp:Literal ID="litRoomName" runat="server" /></span>
                        <span>DM：<asp:Literal ID="litHostName" runat="server" /></span>
                    </div>
                    <div class="hero-actions">
                        <asp:HyperLink ID="lnkOrderDetails" runat="server" CssClass="btn-primary" Text="返回订单详情" />
                        <a class="btn-secondary" href="PlayerHub.aspx?tab=orders">返回订单列表</a>
                    </div>
                </article>

                <article class="about-panel checkin-pass-card">
                    <div class="section-heading left">
                        <h2>核销二维码</h2>
                        <p>前台可以直接扫描二维码，也可以手动输入下方 6 位核销码。</p>
                    </div>
                    <div class="checkin-pass-grid">
                        <asp:Image ID="imgQrCode" runat="server" CssClass="checkin-pass-qr" AlternateText="核销二维码" />
                        <div class="reservation-list compact-reservation-list">
                            <article class="reservation-card">
                                <h3>核销码</h3>
                                <p class="checkin-code-strong"><asp:Literal ID="litCheckInCode" runat="server" /></p>
                            </article>
                            <article class="reservation-card">
                                <h3>当前状态</h3>
                                <p><asp:Literal ID="litStatus" runat="server" /></p>
                            </article>
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
