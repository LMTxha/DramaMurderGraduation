<%@ Page Title="订单详情 | 剧本杀系统" Language="C#" MasterPageFile="~/Site.Master" AutoEventWireup="true" CodeBehind="OrderDetails.aspx.cs" Inherits="DramaMurderGraduation.Web.OrderDetailsPage" %>
<asp:Content ID="Content1" ContentPlaceHolderID="TitleContent" runat="server">
    订单详情 | 剧本杀系统
</asp:Content>
<asp:Content ID="Content2" ContentPlaceHolderID="MainContent" runat="server">
    <asp:Panel ID="pnlNotFound" runat="server" Visible="false" CssClass="section-block">
        <div class="container empty-state">
            <h1>未找到订单</h1>
            <p>订单可能不存在，或者当前账号没有查看这笔订单的权限。</p>
            <a class="btn-primary" href="PlayerHub.aspx?tab=orders">返回我的订单</a>
        </div>
    </asp:Panel>

    <asp:Panel ID="pnlDetail" runat="server" Visible="false">
        <section class="detail-hero">
            <div class="container detail-grid">
                <article class="detail-copy">
                    <p class="eyebrow">ORDER DETAIL</p>
                    <h1><asp:Literal ID="litScriptName" runat="server" /></h1>
                    <p class="hero-subtitle">订单号 #<asp:Literal ID="litReservationId" runat="server" /> · <asp:Literal ID="litOrderStatus" runat="server" /></p>
                    <p class="hero-text">从下单、支付、接单、排房、核销到完成和评价，所有关键节点都集中在这一页查看。</p>
                    <div class="detail-tags">
                        <span>开场时间：<asp:Literal ID="litSessionTime" runat="server" /></span>
                        <span>房间：<asp:Literal ID="litRoomName" runat="server" /></span>
                        <span>DM：<asp:Literal ID="litHostName" runat="server" /></span>
                    </div>
                    <div class="hero-actions">
                        <asp:HyperLink ID="lnkLobby" runat="server" CssClass="btn-primary" Text="进入候场大厅" />
                        <asp:HyperLink ID="lnkConversation" runat="server" CssClass="btn-secondary" Text="订单沟通页" />
                        <a class="btn-secondary" href="PlayerHub.aspx?tab=orders">返回订单列表</a>
                        <a class="btn-secondary" href="Reviews.aspx">查看点评</a>
                    </div>
                </article>

                <article class="about-panel">
                    <div class="section-heading left">
                        <h2>订单总览</h2>
                        <p>这里保留联系人、支付情况、核销码、优惠使用和当前处理结论。</p>
                    </div>
                    <div class="lobby-summary-list">
                        <div class="lobby-summary-item"><span>联系人</span><strong><asp:Literal ID="litContactName" runat="server" /></strong></div>
                        <div class="lobby-summary-item"><span>手机号</span><strong><asp:Literal ID="litPhoneMasked" runat="server" /></strong></div>
                        <div class="lobby-summary-item"><span>预约人数</span><strong><asp:Literal ID="litPlayerCount" runat="server" /></strong></div>
                        <div class="lobby-summary-item"><span>支付状态</span><strong><asp:Literal ID="litPaymentStatus" runat="server" /></strong></div>
                        <div class="lobby-summary-item"><span>订单金额</span><strong>￥<asp:Literal ID="litTotalAmount" runat="server" /></strong></div>
                        <div class="lobby-summary-item"><span>优惠抵扣</span><strong><asp:Literal ID="litDiscountSummary" runat="server" /></strong></div>
                        <div class="lobby-summary-item"><span>核销码</span><strong><asp:Literal ID="litCheckInCode" runat="server" /></strong></div>
                        <div class="lobby-summary-item"><span>门店回复</span><strong><asp:Literal ID="litAdminReply" runat="server" /></strong></div>
                    </div>
                </article>
            </div>
        </section>

        <section class="section-block">
            <div class="container split-grid detail-split">
                <article class="about-panel">
                    <div class="section-heading left">
                        <h2>完整状态时间线</h2>
                        <p>按真实履约流程展示下单、支付、接单、排房、核销、完成和评价节点。</p>
                    </div>
                    <div class="service-timeline order-detail-timeline">
                        <asp:Repeater ID="rptTimeline" runat="server">
                            <ItemTemplate>
                                <div class='service-timeline-step <%# Eval("CssClass") %>'>
                                    <span class="service-timeline-dot"></span>
                                    <div class="service-timeline-copy">
                                        <strong><%# Eval("Title") %></strong>
                                        <small><%# Eval("Summary") %></small>
                                    </div>
                                </div>
                            </ItemTemplate>
                        </asp:Repeater>
                    </div>
                </article>

                <article class="about-panel">
                    <div class="section-heading left">
                        <h2>处理说明</h2>
                        <p>不仅有状态值，还保留了玩家备注、门店备注和玩家确认结果。</p>
                    </div>
                    <div class="reservation-list">
                        <article class="reservation-card">
                            <h3>玩家备注</h3>
                            <p><asp:Literal ID="litUserRemark" runat="server" /></p>
                        </article>
                        <article class="reservation-card">
                            <h3>门店内部备注</h3>
                            <p><asp:Literal ID="litAdminRemark" runat="server" /></p>
                        </article>
                        <article class="reservation-card">
                            <h3>玩家确认结果</h3>
                            <p><asp:Literal ID="litConfirmRemark" runat="server" /></p>
                        </article>
                    </div>
                </article>
            </div>
        </section>

        <section class="section-block alt">
            <div class="container split-grid detail-split">
                <article class="about-panel">
                    <div class="section-heading left">
                        <h2>订单沟通记录</h2>
                        <p>这里展示当前订单的连续沟通记录，并可直接跳转到独立订单会话页继续聊天。</p>
                    </div>
                    <div class="hero-actions compact-actions">
                        <asp:HyperLink ID="lnkConversationInline" runat="server" CssClass="btn-primary" Text="进入独立会话" />
                    </div>
                    <div class="reservation-list">
                        <asp:Repeater ID="rptServiceMessages" runat="server">
                            <ItemTemplate>
                                <article class="reservation-card service-reply-card">
                                    <h3><%# Eval("SenderName") %> · <%# GetServiceMessageRoleText(Eval("SenderRole")) %></h3>
                                    <p><%# Eval("Content") %></p>
                                    <small><%# Eval("CreatedAt", "{0:yyyy-MM-dd HH:mm}") %></small>
                                </article>
                            </ItemTemplate>
                        </asp:Repeater>
                    </div>
                </article>

                <article class="about-panel">
                    <div class="section-heading left">
                        <h2>管理员回复日志</h2>
                        <p>保留管理员处理订单时给玩家的回复记录，便于展示服务闭环。</p>
                    </div>
                    <div class="reservation-list">
                        <asp:Repeater ID="rptReplyLogs" runat="server">
                            <ItemTemplate>
                                <article class="reservation-card">
                                    <h3><%# Eval("AdminName") %></h3>
                                    <p><%# Eval("ReplyContent") %></p>
                                    <small><%# Eval("CreatedAt", "{0:yyyy-MM-dd HH:mm}") %></small>
                                </article>
                            </ItemTemplate>
                        </asp:Repeater>
                    </div>
                </article>
            </div>
        </section>

        <section class="section-block">
            <div class="container">
                <article class="about-panel">
                    <div class="section-heading left">
                        <h2>售后与评价状态</h2>
                        <p>订单完成后，售后申请和评价情况也会和订单绑定展示，不再分散在多个页面里查找。</p>
                    </div>
                    <div class="reservation-list">
                        <asp:Repeater ID="rptAfterSaleRequests" runat="server">
                            <ItemTemplate>
                                <article class="reservation-card">
                                    <h3><%# Eval("RequestType") %> · <%# Eval("Status") %></h3>
                                    <p><%# Eval("Reason") %></p>
                                    <p><%# RenderTextLine("驳回原因：", Eval("RejectReason")) %></p>
                                    <p><%# RenderTextLine("申诉说明：", Eval("AppealReason")) %></p>
                                    <div class="service-timeline top-gap"><%# RenderAfterSaleTimeline(Container.DataItem) %></div>
                                    <%# RenderAfterSaleEvidence(Eval("EvidenceUrl")) %>
                                    <p><%# string.IsNullOrWhiteSpace(Convert.ToString(Eval("AdminReply"))) ? "门店暂未回复售后。" : Eval("AdminReply") %></p>
                                    <small><%# Eval("CreatedAt", "{0:yyyy-MM-dd HH:mm}") %></small>
                                </article>
                            </ItemTemplate>
                        </asp:Repeater>
                    </div>
                    <div class="hero-actions top-gap">
                        <asp:Literal ID="litReviewBadge" runat="server" />
                        <a class="btn-secondary" href="Reviews.aspx">查看 / 提交评价</a>
                    </div>
                    <asp:Panel ID="pnlOrderReview" runat="server" Visible="false" CssClass="reservation-list top-gap">
                        <article class="reservation-card">
                            <h3>订单绑定评价 · <asp:Literal ID="litOrderReviewRating" runat="server" /></h3>
                            <p><asp:Literal ID="litOrderReviewTags" runat="server" /></p>
                            <p><asp:Literal ID="litOrderReviewContent" runat="server" /></p>
                            <p><asp:Literal ID="litOrderReviewAdminReply" runat="server" /></p>
                            <small><asp:Literal ID="litOrderReviewTime" runat="server" /></small>
                        </article>
                    </asp:Panel>
                </article>
            </div>
        </section>
    </asp:Panel>
</asp:Content>
