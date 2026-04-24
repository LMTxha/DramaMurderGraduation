<%@ Page Title="管理员后台 | 剧本杀系统" Language="C#" MasterPageFile="~/Site.Master" AutoEventWireup="true" CodeBehind="AdminReview.aspx.cs" Inherits="DramaMurderGraduation.Web.AdminReviewPage" %>
<asp:Content ID="Content1" ContentPlaceHolderID="TitleContent" runat="server">
    管理员后台 | 剧本杀系统
</asp:Content>
<asp:Content ID="Content2" ContentPlaceHolderID="MainContent" runat="server">
    <section class="detail-hero">
        <div class="container detail-grid">
            <article class="detail-copy">
                <p class="eyebrow">ADMIN CONSOLE</p>
                <h1>门店运营后台</h1>
                <p class="hero-subtitle">集中处理账号审核、充值审核、预约履约、售后退款、服务会话、评价处理、场次排期、公告发布和剧本管理。</p>
                <div class="detail-tags">
                    <span>待审账号 <asp:Literal ID="litPendingUserCountSummary" runat="server" /></span>
                    <span>待审充值 <asp:Literal ID="litPendingRechargeCountSummary" runat="server" /></span>
                    <span>到店联系单 <asp:Literal ID="litStoreVisitCountSummary" runat="server" /></span>
                    <span>预约订单 <asp:Literal ID="litReservationCountSummary" runat="server" /></span>
                </div>
            </article>
            <article class="about-panel">
                <div class="section-heading left">
                    <h2>今日重点</h2>
                    <p>优先处理会直接影响履约和评价的事项，保证答辩时演示链路稳定完整。</p>
                </div>
                <div class="reservation-list">
                    <asp:Repeater ID="rptAdminTodoItems" runat="server">
                        <ItemTemplate>
                            <a class='reservation-card todo-card <%# Eval("Priority") %>' href='<%# Eval("TargetAnchor") %>'>
                                <span class='badge-inline <%# Eval("Priority") %>'><%# Eval("CountText") %></span>
                                <h3><%# Eval("Title") %></h3>
                                <p><%# Eval("Summary") %></p>
                            </a>
                        </ItemTemplate>
                    </asp:Repeater>
                </div>
            </article>
        </div>
    </section>

    <section class="section-block">
        <div class="container">
            <asp:Panel ID="pnlMessage" runat="server" Visible="false" CssClass="status-message">
                <asp:Literal ID="litMessage" runat="server" />
            </asp:Panel>

            <div class="wallet-summary-grid dm-summary-grid">
                <article class="wallet-summary-card accent"><span>待审用户</span><strong><asp:Literal ID="litPendingUserCount" runat="server" /></strong><small>还未完成管理员审核的新注册用户</small></article>
                <article class="wallet-summary-card"><span>待审充值</span><strong><asp:Literal ID="litPendingRechargeCount" runat="server" /></strong><small>需要财务确认入账的充值申请</small></article>
                <article class="wallet-summary-card"><span>待审剧本</span><strong><asp:Literal ID="litPendingScriptCount" runat="server" /></strong><small>创作者提交后等待审核的剧本</small></article>
                <article class="wallet-summary-card"><span>剧本总数</span><strong><asp:Literal ID="litTotalScriptCount" runat="server" /></strong><small>当前剧本库条目总数</small></article>
                <article class="wallet-summary-card"><span>今日到店</span><strong><asp:Literal ID="litTodayStoreCount" runat="server" /></strong><small>今天计划到店的联系单</small></article>
                <article class="wallet-summary-card"><span>今日预约</span><strong><asp:Literal ID="litTodayReservationCount" runat="server" /></strong><small>今天需要履约处理的预约订单</small></article>
                <article class="wallet-summary-card"><span>未来场次</span><strong><asp:Literal ID="litUpcomingSessionCount" runat="server" /></strong><small>已创建但尚未开场的排期场次</small></article>
                <article class="wallet-summary-card"><span>公告数量</span><strong><asp:Literal ID="litAnnouncementCount" runat="server" /></strong><small>当前站内公告总数</small></article>
                <article class="wallet-summary-card"><span>已安排到店</span><strong><asp:Literal ID="litArrangedStoreCount" runat="server" /></strong><small>已经安排房间或已到店完成</small></article>
                <article class="wallet-summary-card"><span>已确认预约</span><strong><asp:Literal ID="litConfirmedReservationCount" runat="server" /></strong><small>已确认或已到店的预约订单</small></article>
            </div>
        </div>
    </section>

    <section class="section-block alt" id="admin-filter">
        <div class="container split-grid detail-split">
            <article class="form-panel">
                <div class="section-heading left">
                    <h2>后台筛选</h2>
                    <p>按关键词、联系单状态、订单状态和日期范围快速聚焦待处理事项。</p>
                </div>
                <div class="form-grid">
                    <div class="field-group"><label for="<%= txtAdminKeyword.ClientID %>">关键词</label><asp:TextBox ID="txtAdminKeyword" runat="server" CssClass="input-control" placeholder="联系人 / 剧本 / 房间 / 手机号" /></div>
                    <div class="field-group"><label for="<%= ddlStoreStatusFilter.ClientID %>">到店联系状态</label><asp:DropDownList ID="ddlStoreStatusFilter" runat="server" CssClass="input-control" /></div>
                    <div class="field-group"><label for="<%= ddlReservationStatusFilter.ClientID %>">预约订单状态</label><asp:DropDownList ID="ddlReservationStatusFilter" runat="server" CssClass="input-control" /></div>
                    <div class="field-group"><label for="<%= ddlAdminDateFilter.ClientID %>">日期范围</label><asp:DropDownList ID="ddlAdminDateFilter" runat="server" CssClass="input-control" /></div>
                </div>
                <div class="hero-actions">
                    <asp:Button ID="btnApplyAdminFilter" runat="server" Text="应用筛选" CssClass="btn-primary" OnClick="btnApplyAdminFilter_Click" />
                    <asp:Button ID="btnResetAdminFilter" runat="server" Text="重置条件" CssClass="btn-secondary" OnClick="btnResetAdminFilter_Click" />
                </div>
            </article>
            <article class="about-panel" id="finance-audit-admin">
                <div class="section-heading left">
                    <h2>财务审计概览</h2>
                    <p>快速确认充值、预约收入、退款和优惠抵扣是否平衡，异常交易会单独标出。</p>
                </div>
                <div class="hero-actions">
                    <a class="btn-secondary small" href="AdminReview.aspx?export=finance">导出财务报表 CSV</a>
                </div>
                <div class="analytics-kpi-grid">
                    <div class="analytics-stat-card"><p>充值总额</p><strong>￥<asp:Literal ID="litAuditRechargeTotal" runat="server" /></strong></div>
                    <div class="analytics-stat-card"><p>预约收入</p><strong>￥<asp:Literal ID="litAuditBookingTotal" runat="server" /></strong></div>
                    <div class="analytics-stat-card"><p>退款总额</p><strong>￥<asp:Literal ID="litAuditRefundTotal" runat="server" /></strong></div>
                    <div class="analytics-stat-card"><p>优惠抵扣</p><strong>￥<asp:Literal ID="litAuditCouponTotal" runat="server" /></strong></div>
                    <div class="analytics-stat-card"><p>待退款金额</p><strong>￥<asp:Literal ID="litAuditPendingRefundTotal" runat="server" /></strong></div>
                    <div class="analytics-stat-card"><p>异常流水</p><strong><asp:Literal ID="litAuditAnomalyCount" runat="server" /></strong></div>
                    <div class="analytics-stat-card"><p>驳回充值</p><strong><asp:Literal ID="litAuditRejectedRechargeCount" runat="server" /></strong></div>
                </div>
            </article>
        </div>
    </section>

    <section class="section-block">
        <div class="container split-grid detail-split">
            <article class="about-panel">
                <div class="section-heading left">
                    <h2>账号审核</h2>
                    <p>新注册用户需要通过管理员审核后才能进入完整业务流程。</p>
                </div>
                <div class="reservation-list">
                    <asp:Repeater ID="rptPendingUsers" runat="server" OnItemCommand="rptPendingUsers_ItemCommand">
                        <ItemTemplate>
                            <article class="reservation-card">
                                <h3><%# Eval("DisplayName") %> / <%# Eval("Username") %></h3>
                                <p>手机号：<%# Eval("Phone") %> · 角色：<%# Eval("RoleCode") %></p>
                                <p>注册时间：<%# Eval("CreatedAt", "{0:yyyy-MM-dd HH:mm}") %></p>
                                <asp:TextBox ID="txtUserRemark" runat="server" CssClass="input-control" placeholder="审核备注" Text='<%# Eval("ReviewRemark") %>' />
                                <div class="hero-actions">
                                    <asp:LinkButton ID="btnApproveUser" runat="server" CssClass="btn-primary small" CommandName="ApproveUser" CommandArgument='<%# Eval("Id") %>'>通过</asp:LinkButton>
                                    <asp:LinkButton ID="btnRejectUser" runat="server" CssClass="btn-secondary small" CommandName="RejectUser" CommandArgument='<%# Eval("Id") %>'>驳回</asp:LinkButton>
                                </div>
                            </article>
                        </ItemTemplate>
                    </asp:Repeater>
                </div>
            </article>

            <article class="about-panel">
                <div class="section-heading left">
                    <h2>充值审核</h2>
                    <p>确认支付方式、付款账号和申请金额后，再决定是否入账到钱包。</p>
                </div>
                <div class="reservation-list">
                    <asp:Repeater ID="rptPendingRechargeRequests" runat="server" OnItemCommand="rptPendingRechargeRequests_ItemCommand">
                        <ItemTemplate>
                            <article class="reservation-card">
                                <h3><%# Eval("DisplayName") %> / ￥<%# Eval("Amount", "{0:F2}") %></h3>
                                <p>充值单号：<%# Eval("RechargeOrderNo") %></p>
                                <p>方式：<%# DisplayPaymentMethod(Eval("PaymentMethod")) %> · 账号：<%# Eval("PaymentAccountMasked") %></p>
                                <p>提交时间：<%# Eval("SubmittedAt", "{0:yyyy-MM-dd HH:mm}") %></p>
                                <asp:TextBox ID="txtRechargeRemark" runat="server" CssClass="input-control" placeholder="审核备注" Text='<%# Eval("ReviewRemark") %>' />
                                <div class="hero-actions">
                                    <asp:LinkButton ID="btnApproveRecharge" runat="server" CssClass="btn-primary small" CommandName="ApproveRecharge" CommandArgument='<%# Eval("Id") %>'>通过充值</asp:LinkButton>
                                    <asp:LinkButton ID="btnRejectRecharge" runat="server" CssClass="btn-secondary small" CommandName="RejectRecharge" CommandArgument='<%# Eval("Id") %>'>驳回申请</asp:LinkButton>
                                </div>
                            </article>
                        </ItemTemplate>
                    </asp:Repeater>
                </div>
            </article>
        </div>
    </section>

    <section class="section-block alt" id="store-requests">
        <div class="container">
            <div class="section-heading left">
                <h2>到店联系单</h2>
                <p>用于安排试玩、拼车、改期到店和特殊需求沟通，可直接在后台分配房间并回复用户。</p>
            </div>
            <div class="reservation-list">
                <asp:Repeater ID="rptStoreVisitRequests" runat="server" OnItemCommand="rptStoreVisitRequests_ItemCommand">
                    <ItemTemplate>
                        <article class="reservation-card">
                            <span class="badge-inline soft"><%# DisplayStoreVisitStatus(Eval("RequestStatus")) %></span>
                            <h3><%# Eval("ContactName") %> · <%# Eval("ScriptName") %></h3>
                            <p>到店时间：<%# Eval("PreferredArriveTime", "{0:yyyy-MM-dd HH:mm}") %> · 人数：<%# Eval("TeamSize") %> · 手机：<%# Eval("PhoneMasked") %></p>
                            <p>用户备注：<%# Eval("Note") %></p>
                            <asp:TextBox ID="txtAssignedRoomName" runat="server" CssClass="input-control" placeholder="安排房间" Text='<%# Eval("AssignedRoomName") %>' />
                            <asp:TextBox ID="txtStoreRemark" runat="server" CssClass="input-control" placeholder="后台备注" Text='<%# Eval("AdminRemark") %>' />
                            <asp:TextBox ID="txtStoreReply" runat="server" CssClass="input-control textarea" TextMode="MultiLine" Rows="3" placeholder="回复用户" Text='<%# Eval("AdminReply") %>' />
                            <div class="hero-actions">
                                <asp:LinkButton ID="btnArrangeStore" runat="server" CssClass="btn-primary small" CommandName="ArrangeStore" CommandArgument='<%# Eval("Id") %>'>安排排期</asp:LinkButton>
                                <asp:LinkButton ID="btnCompleteStore" runat="server" CssClass="btn-secondary small" CommandName="CompleteStore" CommandArgument='<%# Eval("Id") %>'>登记到店完成</asp:LinkButton>
                                <asp:LinkButton ID="btnCloseStore" runat="server" CssClass="btn-secondary small" CommandName="CloseStore" CommandArgument='<%# Eval("Id") %>'>关闭联系单</asp:LinkButton>
                            </div>
                        </article>
                    </ItemTemplate>
                </asp:Repeater>
            </div>
        </div>
    </section>

    <section class="section-block" id="reservation-orders">
        <div class="container">
            <div class="section-heading left">
                <h2>预约订单履约</h2>
                <p>确认订单、登记到店、取消订单和服务会话跳转都在这里处理。</p>
            </div>
            <div class="reservation-list">
                <asp:Repeater ID="rptReservationOrders" runat="server" OnItemCommand="rptReservationOrders_ItemCommand">
                    <ItemTemplate>
                        <article class="reservation-card">
                            <span class="badge-inline"><%# DisplayReservationStatus(Eval("Status")) %></span>
                            <h3>订单 #<%# Eval("Id") %> · <%# Eval("ScriptName") %></h3>
                            <p>联系人：<%# Eval("ContactName") %> · 手机：<%# Eval("PhoneMasked") %> · 房间：<%# Eval("RoomName") %></p>
                            <p>开场：<%# Eval("SessionDateTime", "{0:yyyy-MM-dd HH:mm}") %> · 人数：<%# Eval("PlayerCount") %> · 支付：<%# Eval("PaymentStatus") %></p>
                            <p>核销码：<%# Eval("CheckInCode") %></p>
                            <asp:TextBox ID="txtReservationRemark" runat="server" CssClass="input-control" placeholder="后台备注" Text='<%# Eval("AdminRemark") %>' />
                            <asp:TextBox ID="txtReservationReply" runat="server" CssClass="input-control textarea" TextMode="MultiLine" Rows="3" placeholder="回复用户" Text='<%# Eval("AdminReply") %>' />
                            <div class="hero-actions">
                                <asp:LinkButton ID="btnConfirmReservation" runat="server" CssClass="btn-primary small" CommandName="ConfirmReservation" CommandArgument='<%# Eval("Id") %>'>确认预约</asp:LinkButton>
                                <asp:LinkButton ID="btnArriveReservation" runat="server" CssClass="btn-secondary small" CommandName="ArriveReservation" CommandArgument='<%# Eval("Id") %>'>登记到店</asp:LinkButton>
                                <asp:LinkButton ID="btnCancelReservation" runat="server" CssClass="btn-secondary small" CommandName="CancelReservation" CommandArgument='<%# Eval("Id") %>'>取消订单</asp:LinkButton>
                                <asp:HyperLink runat="server" CssClass="btn-secondary small" NavigateUrl='<%# "OrderDetails.aspx?reservationId=" + Eval("Id") %>' Text="订单详情" />
                                <asp:HyperLink runat="server" CssClass="btn-secondary small" NavigateUrl='<%# "OrderConversation.aspx?reservationId=" + Eval("Id") %>' Text="订单沟通" />
                            </div>
                        </article>
                    </ItemTemplate>
                </asp:Repeater>
            </div>
        </div>
    </section>

    <section class="section-block alt" id="after-sale-admin">
        <div class="container">
            <div class="section-heading left">
                <h2>售后与退款</h2>
                <p>处理退款、投诉、改期协商和二次申诉，证据、时间线和处理意见都集中展示。</p>
            </div>
            <div class="reservation-list">
                <asp:Repeater ID="rptAfterSaleRequests" runat="server" OnItemCommand="rptAfterSaleRequests_ItemCommand">
                    <ItemTemplate>
                        <article class="reservation-card">
                            <span class="badge-inline warning"><%# Eval("Status") %></span>
                            <h3>售后 #<%# Eval("Id") %> · 订单 #<%# Eval("ReservationId") %></h3>
                            <p><%# Eval("ContactName") %> · <%# Eval("ScriptName") %> / <%# Eval("RoomName") %> / <%# Eval("SessionDateTime", "{0:MM-dd HH:mm}") %></p>
                            <p>类型：<%# Eval("RequestType") %> · 申请金额：￥<%# Eval("RequestedAmount", "{0:F2}") %> · 已退：￥<%# Eval("RefundedAmount", "{0:F2}") %></p>
                            <p>原因：<%# Eval("Reason") %></p>
                            <div class="service-timeline"><%# DisplayAfterSaleTimeline(Container.DataItem) %></div>
                            <%# DisplayAfterSaleEvidence(Eval("EvidenceUrl")) %>
                            <asp:DropDownList ID="ddlAfterSaleStatus" runat="server" CssClass="input-control">
                                <asp:ListItem Text="已受理" Value="已受理" />
                                <asp:ListItem Text="待复审" Value="待复审" />
                                <asp:ListItem Text="退款完成" Value="退款完成" />
                                <asp:ListItem Text="已驳回" Value="已驳回" />
                                <asp:ListItem Text="已关闭" Value="已关闭" />
                            </asp:DropDownList>
                            <asp:TextBox ID="txtAfterSaleReply" runat="server" CssClass="input-control textarea" TextMode="MultiLine" Rows="3" placeholder="回复用户" Text='<%# Eval("AdminReply") %>' />
                            <asp:TextBox ID="txtAfterSaleRejectReason" runat="server" CssClass="input-control" placeholder="驳回原因" Text='<%# Eval("RejectReason") %>' />
                            <asp:TextBox ID="txtAfterSaleRemark" runat="server" CssClass="input-control" placeholder="内部备注" Text='<%# Eval("AdminRemark") %>' />
                            <div class="hero-actions">
                                <asp:LinkButton ID="btnReviewAfterSale" runat="server" CssClass="btn-primary small" CommandName="ReviewAfterSale" CommandArgument='<%# Eval("Id") %>'>提交售后处理</asp:LinkButton>
                            </div>
                        </article>
                    </ItemTemplate>
                </asp:Repeater>
            </div>
        </div>
    </section>

    <section class="section-block">
        <div class="container split-grid detail-split">
            <article class="about-panel">
                <div class="section-heading left">
                    <h2>优惠券发放</h2>
                    <p>补贴老客、活动用户和评价补偿都可以通过后台发券完成。</p>
                </div>
                <div class="form-grid">
                    <div class="field-group"><label for="<%= ddlCouponUser.ClientID %>">发放用户</label><asp:DropDownList ID="ddlCouponUser" runat="server" CssClass="input-control" /></div>
                    <div class="field-group"><label for="<%= txtCouponTitle.ClientID %>">优惠券标题</label><asp:TextBox ID="txtCouponTitle" runat="server" CssClass="input-control" /></div>
                    <div class="field-group"><label for="<%= txtCouponAmount.ClientID %>">抵扣金额</label><asp:TextBox ID="txtCouponAmount" runat="server" CssClass="input-control" /></div>
                    <div class="field-group"><label for="<%= txtCouponMinSpend.ClientID %>">最低消费</label><asp:TextBox ID="txtCouponMinSpend" runat="server" CssClass="input-control" /></div>
                    <div class="field-group"><label for="<%= txtCouponValidDays.ClientID %>">有效天数</label><asp:TextBox ID="txtCouponValidDays" runat="server" CssClass="input-control" /></div>
                    <div class="field-group"><label for="<%= txtCouponSource.ClientID %>">发券来源</label><asp:TextBox ID="txtCouponSource" runat="server" CssClass="input-control" placeholder="如：复购召回 / 差评安抚" /></div>
                </div>
                <div class="hero-actions">
                    <asp:Button ID="btnIssueCoupon" runat="server" Text="发放优惠券" CssClass="btn-primary" OnClick="btnIssueCoupon_Click" />
                </div>
                <div class="reservation-list top-gap">
                    <asp:Repeater ID="rptRecentCoupons" runat="server">
                        <ItemTemplate>
                            <article class="reservation-card">
                                <h3><%# Eval("Title") %> · ￥<%# Eval("DiscountAmount", "{0:F2}") %></h3>
                                <p>用户：<%# Eval("UserDisplayName") %> · 状态：<%# Eval("Status") %></p>
                                <p>门槛：￥<%# Eval("MinSpend", "{0:F2}") %> · 有效期至 <%# Eval("ValidUntil", "{0:yyyy-MM-dd}") %></p>
                            </article>
                        </ItemTemplate>
                    </asp:Repeater>
                </div>
            </article>

            <article class="about-panel" id="service-message-admin">
                <div class="section-heading left">
                    <h2>核销与服务消息</h2>
                    <p>支持前台输入核销码登记到店，也能统一查看用户与管理员围绕订单的连续消息。</p>
                </div>
                <div class="hero-actions">
                    <asp:TextBox ID="txtCheckInCode" runat="server" CssClass="input-control" placeholder="输入预约核销码" />
                    <asp:Button ID="btnCheckInReservation" runat="server" Text="核销到店" CssClass="btn-primary" OnClick="btnCheckInReservation_Click" />
                </div>
                <div class="reservation-list top-gap">
                    <asp:Repeater ID="rptServiceMessages" runat="server" OnItemCommand="rptServiceMessages_ItemCommand">
                        <ItemTemplate>
                            <article class="reservation-card">
                                <span class="badge-inline soft"><%# DisplayBusinessType(Eval("BusinessType")) %></span>
                                <h3><%# Eval("SenderName") %> · <%# Eval("CreatedAt", "{0:yyyy-MM-dd HH:mm}") %></h3>
                                <p>角色：<%# Eval("SenderRole") %> · 业务编号：<%# Eval("BusinessId") %></p>
                                <p><%# Eval("Content") %></p>
                                <asp:TextBox ID="txtServiceReply" runat="server" CssClass="input-control textarea" TextMode="MultiLine" Rows="3" placeholder="回复本条服务会话" />
                                <div class="hero-actions">
                                    <asp:LinkButton ID="btnReplyService" runat="server" CssClass="btn-primary small" CommandName="ReplyService" CommandArgument='<%# Eval("BusinessType") + "|" + Eval("BusinessId") %>'>发送回复</asp:LinkButton>
                                    <asp:HyperLink runat="server" CssClass="btn-secondary small" NavigateUrl='<%# GetBusinessConversationUrl(Eval("BusinessType"), Eval("BusinessId")) %>' Visible='<%# HasBusinessConversation(Eval("BusinessType")) %>' Text="查看订单会话" />
                                </div>
                            </article>
                        </ItemTemplate>
                    </asp:Repeater>
                </div>
            </article>
        </div>
    </section>

    <section class="section-block alt">
        <div class="container split-grid detail-split">
            <article class="about-panel">
                <div class="section-heading left">
                    <h2>评价管理</h2>
                    <p>查看订单绑定评价、处理低分反馈，并决定是否精选展示或隐藏。</p>
                </div>
                <div class="analytics-kpi-grid">
                    <div class="analytics-stat-card"><p>评价总数</p><strong><asp:Literal ID="litReviewAdminTotal" runat="server" /></strong></div>
                    <div class="analytics-stat-card"><p>平均评分</p><strong><asp:Literal ID="litReviewAdminAverage" runat="server" /></strong></div>
                    <div class="analytics-stat-card"><p>低分待处理</p><strong><asp:Literal ID="litReviewLowPendingCount" runat="server" /></strong></div>
                    <div class="analytics-stat-card"><p>已绑订单</p><strong><asp:Literal ID="litReviewOrderBoundCount" runat="server" /></strong></div>
                </div>
                <div class="reservation-list top-gap">
                    <asp:Repeater ID="rptAdminReviews" runat="server" OnItemCommand="rptAdminReviews_ItemCommand">
                        <ItemTemplate>
                            <article class="reservation-card">
                                <h3><%# Eval("ScriptName") %> · <%# Eval("ReviewerName") %> · <span class="rating-badge"><%# Eval("Rating") %>.0</span></h3>
                                <p><%# Eval("Content") %></p>
                                <p class="meta-copy">标签：<%# DisplayReviewTags(Eval("HighlightTag")) %></p>
                                <p class="meta-copy"><%# DisplayReviewBinding(Container.DataItem) %></p>
                                <label><asp:CheckBox ID="chkReviewFeatured" runat="server" Checked='<%# Eval("IsFeatured") %>' /> 精选展示</label>
                                <label><asp:CheckBox ID="chkReviewHidden" runat="server" Checked='<%# Eval("IsHidden") %>' /> 隐藏评价</label>
                                <asp:TextBox ID="txtReviewReply" runat="server" CssClass="input-control textarea" TextMode="MultiLine" Rows="3" placeholder="管理员回复评价" Text='<%# Eval("AdminReply") %>' />
                                <div class="hero-actions">
                                    <asp:LinkButton ID="btnModerateReview" runat="server" CssClass="btn-primary small" CommandName="ModerateReview" CommandArgument='<%# Eval("Id") %>'>保存评价处理</asp:LinkButton>
                                </div>
                            </article>
                        </ItemTemplate>
                    </asp:Repeater>
                </div>
            </article>

            <article class="about-panel">
                <div class="section-heading left">
                    <h2>回复日志与业务动作</h2>
                    <p>记录管理员对外回复和关键业务操作，方便答辩时展示后台痕迹链路。</p>
                </div>
                <div class="reservation-list">
                    <asp:Repeater ID="rptAdminReplyLogs" runat="server">
                        <ItemTemplate>
                            <article class="reservation-card">
                                <h3><%# Eval("AdminName") %> · <%# Eval("CreatedAt", "{0:yyyy-MM-dd HH:mm}") %></h3>
                                <p>业务：<%# DisplayBusinessType(Eval("BusinessType")) %> #<%# Eval("BusinessId") %></p>
                                <p><%# Eval("ReplyContent") %></p>
                            </article>
                        </ItemTemplate>
                    </asp:Repeater>
                    <asp:Repeater ID="rptBusinessActionLogs" runat="server">
                        <ItemTemplate>
                            <article class="reservation-card">
                                <h3><%# Eval("ActionTitle") %> · <%# Eval("CreatedAt", "{0:yyyy-MM-dd HH:mm}") %></h3>
                                <p>操作人：<%# Eval("OperatorName") %> · 业务：<%# DisplayBusinessType(Eval("BusinessType")) %> #<%# Eval("BusinessId") %></p>
                                <p><%# Eval("ActionContent") %></p>
                            </article>
                        </ItemTemplate>
                    </asp:Repeater>
                </div>
            </article>
        </div>
    </section>

    <section class="section-block" id="room-session-admin">
        <div class="container split-grid detail-split">
            <article class="about-panel">
                <div class="section-heading left">
                    <h2>创建排期与 DM 协同</h2>
                    <p>管理员可以直接创建场次、指定房间和主持人，并同步主持备注。</p>
                </div>
                <div class="form-grid">
                    <div class="field-group"><label for="<%= ddlScheduleScript.ClientID %>">剧本</label><asp:DropDownList ID="ddlScheduleScript" runat="server" CssClass="input-control" /></div>
                    <div class="field-group"><label for="<%= ddlScheduleRoom.ClientID %>">房间</label><asp:DropDownList ID="ddlScheduleRoom" runat="server" CssClass="input-control" /></div>
                    <div class="field-group"><label for="<%= txtScheduleDateTime.ClientID %>">开场时间</label><asp:TextBox ID="txtScheduleDateTime" runat="server" CssClass="input-control" /></div>
                    <div class="field-group"><label for="<%= txtScheduleHostName.ClientID %>">主持名称</label><asp:TextBox ID="txtScheduleHostName" runat="server" CssClass="input-control" /></div>
                    <div class="field-group"><label for="<%= ddlScheduleDm.ClientID %>">绑定 DM</label><asp:DropDownList ID="ddlScheduleDm" runat="server" CssClass="input-control" /></div>
                    <div class="field-group"><label for="<%= txtSchedulePrice.ClientID %>">人均价格</label><asp:TextBox ID="txtSchedulePrice" runat="server" CssClass="input-control" /></div>
                    <div class="field-group"><label for="<%= txtScheduleMaxPlayers.ClientID %>">最大人数</label><asp:TextBox ID="txtScheduleMaxPlayers" runat="server" CssClass="input-control" /></div>
                    <div class="field-group full"><label for="<%= txtScheduleBriefing.ClientID %>">主持备注</label><asp:TextBox ID="txtScheduleBriefing" runat="server" CssClass="input-control textarea" TextMode="MultiLine" Rows="3" /></div>
                </div>
                <div class="hero-actions">
                    <asp:Button ID="btnCreateSession" runat="server" Text="创建排期场次" CssClass="btn-primary" OnClick="btnCreateSession_Click" />
                </div>
            </article>

            <article class="about-panel">
                <div class="section-heading left">
                    <h2>房间状态</h2>
                    <p>可快速调整房间是否启用、维护或暂停接待，并同步展示未来场次数。</p>
                </div>
                <div class="reservation-list">
                    <asp:Repeater ID="rptAdminRooms" runat="server" OnItemCommand="rptAdminRooms_ItemCommand">
                        <ItemTemplate>
                            <article class="reservation-card">
                                <h3><%# Eval("Name") %></h3>
                                <p>主题：<%# Eval("Theme") %> · 容量：<%# Eval("Capacity") %> · 状态：<%# Eval("Status") %></p>
                                <p><%# Eval("Description") %></p>
                                <div class="hero-actions">
                                    <asp:LinkButton ID="btnEnableRoom" runat="server" CssClass="btn-primary small" CommandName="EnableRoom" CommandArgument='<%# Eval("Id") %>'>启用</asp:LinkButton>
                                    <asp:LinkButton ID="btnMaintainRoom" runat="server" CssClass="btn-secondary small" CommandName="MaintainRoom" CommandArgument='<%# Eval("Id") %>'>维护</asp:LinkButton>
                                    <asp:LinkButton ID="btnPauseRoom" runat="server" CssClass="btn-secondary small" CommandName="PauseRoom" CommandArgument='<%# Eval("Id") %>'>暂停接待</asp:LinkButton>
                                </div>
                            </article>
                        </ItemTemplate>
                    </asp:Repeater>
                </div>
            </article>
        </div>
    </section>

    <section class="section-block alt">
        <div class="container split-grid detail-split">
            <article class="about-panel">
                <div class="section-heading left">
                    <h2>已创建场次</h2>
                    <p>核对剧本、房间、主持人和剩余席位，避免排期信息和履约信息脱节。</p>
                </div>
                <div class="reservation-list">
                    <asp:Repeater ID="rptAdminSessions" runat="server">
                        <ItemTemplate>
                            <article class="reservation-card">
                                <h3><%# Eval("ScriptName") %> / <%# Eval("RoomName") %></h3>
                                <p>开场：<%# Eval("SessionDateTime", "{0:yyyy-MM-dd HH:mm}") %> · 主持：<%# Eval("HostName") %></p>
                                <p>价格：￥<%# Eval("BasePrice", "{0:F2}") %> · 人数 <%# Eval("ReservedPlayers") %>/<%# Eval("MaxPlayers") %> · 状态：<%# Eval("Status") %></p>
                                <p class="meta-copy">主持备注：<%# Eval("HostBriefing") %></p>
                            </article>
                        </ItemTemplate>
                    </asp:Repeater>
                </div>
            </article>

            <article class="about-panel">
                <div class="section-heading left">
                    <h2>公告发布</h2>
                    <p>用于预约变更、节假日排期、活动上新和答辩时展示站内通知能力。</p>
                </div>
                <div class="form-grid">
                    <div class="field-group"><label for="<%= txtAnnouncementTitle.ClientID %>">公告标题</label><asp:TextBox ID="txtAnnouncementTitle" runat="server" CssClass="input-control" /></div>
                    <div class="field-group full"><label for="<%= txtAnnouncementSummary.ClientID %>">公告摘要</label><asp:TextBox ID="txtAnnouncementSummary" runat="server" CssClass="input-control textarea" TextMode="MultiLine" Rows="3" /></div>
                    <div class="field-group"><label><asp:CheckBox ID="chkAnnouncementImportant" runat="server" /> 设为重要公告</label></div>
                </div>
                <div class="hero-actions">
                    <asp:Button ID="btnPublishAnnouncement" runat="server" Text="发布公告" CssClass="btn-primary" OnClick="btnPublishAnnouncement_Click" />
                </div>
                <div class="reservation-list top-gap">
                    <asp:Repeater ID="rptAdminAnnouncements" runat="server">
                        <ItemTemplate>
                            <article class="reservation-card">
                                <span class='badge-inline <%# Convert.ToBoolean(Eval("IsImportant")) ? "warning" : "soft" %>'><%# Convert.ToBoolean(Eval("IsImportant")) ? "重要" : "普通" %></span>
                                <h3><%# Eval("Title") %></h3>
                                <p><%# Eval("Summary") %></p>
                                <small><%# Eval("PublishDate", "{0:yyyy-MM-dd HH:mm}") %></small>
                            </article>
                        </ItemTemplate>
                    </asp:Repeater>
                </div>
            </article>
        </div>
    </section>

    <section class="section-block">
        <div class="container split-grid detail-split">
            <article class="about-panel">
                <div class="section-heading left">
                    <h2>剧本审核</h2>
                    <p>处理创作者提交的剧本，确认后进入剧本库，驳回时保留审核意见。</p>
                </div>
                <div class="reservation-list">
                    <asp:Repeater ID="rptPendingScripts" runat="server" OnItemCommand="rptPendingScripts_ItemCommand">
                        <ItemTemplate>
                            <article class="reservation-card">
                                <h3><%# Eval("Name") %></h3>
                                <p>作者：<%# Eval("CreatorDisplayName") %> · 类型：<%# Eval("GenreName") %> · 时长：<%# Eval("DurationMinutes") %> 分钟</p>
                                <p><%# Eval("Slogan") %></p>
                                <asp:TextBox ID="txtScriptRemark" runat="server" CssClass="input-control textarea" TextMode="MultiLine" Rows="3" placeholder="审核意见" Text='<%# Eval("AuditComment") %>' />
                                <div class="hero-actions">
                                    <asp:LinkButton ID="btnApproveScript" runat="server" CssClass="btn-primary small" CommandName="ApproveScript" CommandArgument='<%# Eval("Id") %>'>通过剧本</asp:LinkButton>
                                    <asp:LinkButton ID="btnRejectScript" runat="server" CssClass="btn-secondary small" CommandName="RejectScript" CommandArgument='<%# Eval("Id") %>'>驳回剧本</asp:LinkButton>
                                </div>
                            </article>
                        </ItemTemplate>
                    </asp:Repeater>
                </div>
            </article>

            <article class="about-panel">
                <div class="section-heading left">
                    <h2>剧本总览</h2>
                    <p>当前所有剧本的状态、评分、排期数和审核结果，可直接做下架和整理。</p>
                </div>
                <div class="reservation-list">
                    <asp:Repeater ID="rptAllScripts" runat="server" OnItemCommand="rptAllScripts_ItemCommand">
                        <ItemTemplate>
                            <article class="reservation-card">
                                <h3><%# Eval("Name") %></h3>
                                <p>状态：<%# Eval("Status") %> · 审核：<%# DisplayAuditStatus(Eval("AuditStatus")) %> · 评分：<%# Eval("AverageRating", "{0:F1}") %></p>
                                <p>排期：<%# Eval("UpcomingSessionCount") %> 场 · 评论：<%# Eval("ReviewCount") %> 条</p>
                                <div class="hero-actions">
                                    <asp:HyperLink runat="server" CssClass="btn-secondary small" NavigateUrl='<%# "ScriptDetails.aspx?id=" + Eval("Id") %>' Text="查看详情" />
                                    <asp:LinkButton ID="btnDeleteScript" runat="server" CssClass="btn-secondary small" CommandName="DeleteScript" CommandArgument='<%# Eval("Id") %>' OnClientClick="return confirm('确定删除这个剧本吗？');">删除剧本</asp:LinkButton>
                                </div>
                            </article>
                        </ItemTemplate>
                    </asp:Repeater>
                </div>
            </article>
        </div>
    </section>

    <section class="section-block alt">
        <div class="container split-grid detail-split">
            <article class="about-panel">
                <div class="section-heading left">
                    <h2>充值审核流水</h2>
                    <p>展示最近审核过的充值记录，便于核对是否都已经入账。</p>
                </div>
                <div class="reservation-list">
                    <asp:Repeater ID="rptRechargeAuditRecords" runat="server">
                        <ItemTemplate>
                            <article class="reservation-card">
                                <h3><%# Eval("DisplayName") %> · ￥<%# Eval("Amount", "{0:F2}") %></h3>
                                <p>状态：<%# DisplayAuditStatus(Eval("RequestStatus")) %> · 方式：<%# DisplayPaymentMethod(Eval("PaymentMethod")) %></p>
                                <p>审核人：<%# Eval("ReviewedByName") %> · 时间：<%# Eval("ReviewedAt", "{0:yyyy-MM-dd HH:mm}") %></p>
                                <p><%# Eval("ReviewRemark") %></p>
                            </article>
                        </ItemTemplate>
                    </asp:Repeater>
                </div>
            </article>

            <article class="about-panel">
                <div class="section-heading left">
                    <h2>退款审核流水</h2>
                    <p>核对最近的退款处理结果、驳回原因和最终到账金额。</p>
                </div>
                <div class="reservation-list">
                    <asp:Repeater ID="rptRefundAuditRecords" runat="server">
                        <ItemTemplate>
                            <article class="reservation-card">
                                <h3>售后 #<%# Eval("Id") %> · <%# Eval("RequestType") %></h3>
                                <p>订单 #<%# Eval("ReservationId") %> · 状态：<%# Eval("Status") %></p>
                                <p>申请金额：￥<%# Eval("RequestedAmount", "{0:F2}") %> · 已退：￥<%# Eval("RefundedAmount", "{0:F2}") %></p>
                                <p><%# string.IsNullOrWhiteSpace(Convert.ToString(Eval("RejectReason"))) ? Eval("AdminReply") : Eval("RejectReason") %></p>
                            </article>
                        </ItemTemplate>
                    </asp:Repeater>
                </div>
            </article>
        </div>
    </section>

    <section class="section-block">
        <div class="container">
            <div class="section-heading left">
                <h2>钱包流水审计</h2>
                <p>展示最近的余额变更，异常流水会带出审计备注，方便答辩时说明财务闭环。</p>
            </div>
            <div class="reservation-list">
                <asp:Repeater ID="rptAdminWalletTransactions" runat="server">
                    <ItemTemplate>
                        <article class="reservation-card">
                            <span class='badge-inline <%# Convert.ToBoolean(Eval("IsAnomaly")) ? "warning" : "soft" %>'><%# Convert.ToBoolean(Eval("IsAnomaly")) ? "异常" : "正常" %></span>
                            <h3><%# Eval("UserDisplayName") %> · <%# Eval("TransactionType") %></h3>
                            <p>金额：￥<%# Eval("Amount", "{0:F2}") %> · 余额：￥<%# Eval("BalanceAfter", "{0:F2}") %></p>
                            <p><%# Eval("Summary") %></p>
                            <small><%# Eval("CreatedAt", "{0:yyyy-MM-dd HH:mm}") %> · <%# Eval("AuditNote") %></small>
                        </article>
                    </ItemTemplate>
                </asp:Repeater>
            </div>
        </div>
    </section>
</asp:Content>
