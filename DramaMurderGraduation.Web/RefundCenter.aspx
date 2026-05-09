<%@ Page Title="退款售后 | 剧本杀系统" Language="C#" MasterPageFile="~/Site.Master" AutoEventWireup="true" CodeBehind="RefundCenter.aspx.cs" Inherits="DramaMurderGraduation.Web.RefundCenterPage" MaintainScrollPositionOnPostback="true" %>

<asp:Content ID="RefundTitle" ContentPlaceHolderID="TitleContent" runat="server">
    退款售后 | 剧本杀系统
</asp:Content>

<asp:Content ID="RefundMain" ContentPlaceHolderID="MainContent" runat="server">
    <section class="inner-hero">
        <div class="container">
            <p class="eyebrow">Refund Center</p>
            <h1>退款售后中心</h1>
            <p>玩家可在这里针对已预约订单提交退款、改期或体验投诉，管理员会在后台“售后与退款”统一审核处理。</p>
        </div>
    </section>

    <div class="container">
        <asp:Panel ID="pnlMessage" runat="server" Visible="false" CssClass="status-message">
            <asp:Literal ID="litMessage" runat="server" />
        </asp:Panel>
    </div>

    <section class="section-block">
        <div class="container split-grid detail-split">
            <article class="about-panel">
                <div class="section-heading left">
                    <h2>提交退款 / 售后申请</h2>
                    <p>请选择要处理的订单，填写申请类型、退款金额和原因。凭证可选传，便于管理员审核。</p>
                </div>

                <div class="field-group">
                    <label for="<%= ddlReservations.ClientID %>">选择订单</label>
                    <asp:DropDownList ID="ddlReservations" runat="server" CssClass="input-control" />
                </div>
                <div class="filter-bar compact-filter">
                    <div class="field-group">
                        <label for="<%= ddlAfterSaleType.ClientID %>">申请类型</label>
                        <asp:DropDownList ID="ddlAfterSaleType" runat="server" CssClass="input-control">
                            <asp:ListItem Value="退款申请">退款申请</asp:ListItem>
                            <asp:ListItem Value="改期申请">改期申请</asp:ListItem>
                            <asp:ListItem Value="体验投诉">体验投诉</asp:ListItem>
                            <asp:ListItem Value="其他售后">其他售后</asp:ListItem>
                        </asp:DropDownList>
                    </div>
                    <div class="field-group">
                        <label for="<%= txtRequestedAmount.ClientID %>">退款金额</label>
                        <asp:TextBox ID="txtRequestedAmount" runat="server" CssClass="input-control" placeholder="可留空，由管理员按订单金额审核" />
                    </div>
                </div>
                <div class="field-group">
                    <label for="<%= txtReason.ClientID %>">申请说明</label>
                    <asp:TextBox ID="txtReason" runat="server" CssClass="input-control textarea" TextMode="MultiLine" Rows="5" placeholder="请说明不满意原因、退款诉求、希望改期时间或其他售后说明" />
                </div>
                <div class="field-group">
                    <label for="<%= fuEvidence.ClientID %>">凭证附件</label>
                    <asp:FileUpload ID="fuEvidence" runat="server" CssClass="input-control" />
                </div>
                <div class="hero-actions top-gap">
                    <asp:Button ID="btnSubmitAfterSale" runat="server" Text="提交申请" CssClass="btn-primary" OnClick="btnSubmitAfterSale_Click" />
                    <a class="btn-secondary" href="PlayerHub.aspx?tab=orders">返回我的订单</a>
                </div>
            </article>

            <article class="about-panel">
                <div class="section-heading left">
                    <h2>可申请订单</h2>
                    <p>这里展示最近订单的售后状态。已取消订单和正在处理中的售后单不会重复提交。</p>
                </div>
                <div class="reservation-list">
                    <asp:Repeater ID="rptReservations" runat="server">
                        <ItemTemplate>
                            <article class="reservation-card">
                                <h3><%# Eval("ScriptName") %> · 订单 #<%# Eval("Id") %></h3>
                                <p><%# Eval("RoomName") %> · <%# Eval("SessionDateTime", "{0:yyyy-MM-dd HH:mm}") %> · ￥<%# Eval("TotalAmount", "{0:F2}") %></p>
                                <p>状态：<%# Eval("Status") %> · 支付：<%# Eval("PaymentStatus") %></p>
                                <%# RenderAfterSaleSummary(Eval("LatestAfterSaleType"), Eval("LatestAfterSaleStatus"), Eval("LatestAfterSaleCreatedAt")) %>
                            </article>
                        </ItemTemplate>
                    </asp:Repeater>
                </div>
            </article>
        </div>
    </section>

    <section class="section-block alt">
        <div class="container">
            <article class="about-panel">
                <div class="section-heading left">
                    <h2>售后处理进度</h2>
                    <p>查看退款是否受理、是否驳回、是否完成到账。如被驳回，可补充说明后再次申诉。</p>
                </div>
                <div class="reservation-list">
                    <asp:Repeater ID="rptAfterSaleRequests" runat="server" OnItemCommand="rptAfterSaleRequests_ItemCommand">
                        <ItemTemplate>
                            <article class="reservation-card aftersale-card">
                                <h3><%# Eval("RequestType") %> · <%# Eval("Status") %></h3>
                                <p><%# Eval("ScriptName") %> / 订单 #<%# Eval("ReservationId") %> / <%# Eval("SessionDateTime", "{0:yyyy-MM-dd HH:mm}") %></p>
                                <p>申请金额：￥<%# Eval("RequestedAmount", "{0:F2}") %> · 已退：￥<%# Eval("RefundedAmount", "{0:F2}") %></p>
                                <p>申请原因：<%# Eval("Reason") %></p>
                                <p><%# string.IsNullOrWhiteSpace(Convert.ToString(Eval("AdminReply"))) ? "门店暂未回复处理说明。" : "门店回复：" + Eval("AdminReply") %></p>
                                <p><%# string.IsNullOrWhiteSpace(Convert.ToString(Eval("RejectReason"))) ? string.Empty : "驳回原因：" + Eval("RejectReason") %></p>
                                <p><%# string.IsNullOrWhiteSpace(Convert.ToString(Eval("AppealReason"))) ? string.Empty : "申诉说明：" + Eval("AppealReason") %></p>
                                <div class="service-timeline"><%# RenderAfterSaleTimeline(Container.DataItem) %></div>
                                <%# RenderAfterSaleEvidence(Eval("EvidenceUrl")) %>
                                <asp:Panel ID="pnlAppeal" runat="server" Visible='<%# CanAppealAfterSale(Container.DataItem) %>' CssClass="booking-service-form top-gap">
                                    <asp:TextBox ID="txtAppealReason" runat="server" CssClass="input-control textarea" TextMode="MultiLine" Rows="2" placeholder="如对驳回结果有异议，请写明补充说明后再次申诉" />
                                    <asp:FileUpload ID="fuAppealEvidence" runat="server" CssClass="input-control compact-input" />
                                    <asp:Button ID="btnSubmitAfterSaleAppeal" runat="server" Text="提交二次申诉" CssClass="btn-secondary" CommandName="SubmitAfterSaleAppeal" CommandArgument='<%# Eval("Id") %>' />
                                </asp:Panel>
                            </article>
                        </ItemTemplate>
                    </asp:Repeater>
                </div>
            </article>
        </div>
    </section>
</asp:Content>
