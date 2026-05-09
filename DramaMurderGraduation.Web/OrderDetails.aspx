<%@ Page Title="订单详情 | 剧本杀系统" Language="C#" MasterPageFile="~/Site.Master" AutoEventWireup="true" CodeBehind="OrderDetails.aspx.cs" Inherits="DramaMurderGraduation.Web.OrderDetailsPage" %>
<%-- 页面用途：OrderDetails 页面负责承载对应功能的 Web Forms 标记、服务端控件和前端布局。 --%>
<asp:Content ID="Content1" ContentPlaceHolderID="TitleContent" runat="server">
    订单详情 | 剧本杀系统
</asp:Content>
<asp:Content ID="Content2" ContentPlaceHolderID="MainContent" runat="server">
    <%-- 面板控件 pnlNotFound：后台可通过 Visible/CssClass 控制整块内容是否显示以及提示样式。 --%>
    <asp:Panel ID="pnlNotFound" runat="server" Visible="false" CssClass="section-block">
        <div class="container empty-state">
            <h1>未找到订单</h1>
            <p>订单可能不存在，或者当前账号没有查看这笔订单的权限。</p>
            <a class="btn-primary" href="PlayerHub.aspx?tab=orders">返回我的订单</a>
        </div>
    </asp:Panel>

    <%-- 面板控件 pnlDetail：后台可通过 Visible/CssClass 控制整块内容是否显示以及提示样式。 --%>
    <asp:Panel ID="pnlDetail" runat="server" Visible="false">
        <%-- 页面头图区：展示当前功能的标题、说明和关键入口。 --%>
        <section class="detail-hero">
            <div class="container detail-grid">
                <%-- 说明卡片：展示页面主标题、摘要和关键标签。 --%>
                <article class="detail-copy">
                    <p class="eyebrow">ORDER DETAIL</p>
                    <h1><asp:Literal ID="litScriptName" runat="server" /></h1>
                    <p class="hero-subtitle">订单号 #<asp:Literal ID="litReservationId" runat="server" /> · <asp:Literal ID="litOrderStatus" runat="server" /></p>
                    <p class="hero-text">从下单、支付、接单、排房、核销到完成和评价，所有关键节点都集中在这一页查看。</p>
                    <%-- 摘要标签区：展示当前页面最重要的数量或状态提示。 --%>
                    <div class="detail-tags">
                        <span>开场时间：<asp:Literal ID="litSessionTime" runat="server" /></span>
                        <span>房间：<asp:Literal ID="litRoomName" runat="server" /></span>
                        <span>房间号：<asp:Literal ID="litRoomCode" runat="server" /></span>
                        <span>DM：<asp:Literal ID="litHostName" runat="server" /></span>
                    </div>
                    <%-- 操作按钮区：集中放置提交、重置、跳转或审核动作。 --%>
                    <div class="hero-actions">
                        <%-- 跳转链接控件：根据绑定数据生成详情页、沟通页或外部页面入口。 --%>
                        <asp:HyperLink ID="lnkGameRoom" runat="server" CssClass="btn-primary" Text="进入游戏房间" />
                        <asp:LinkButton ID="btnLeaveReservation" runat="server" CssClass="btn-secondary danger-button" OnClick="btnLeaveReservation_Click" OnClientClick="return confirm('确认退出这个游戏房间吗？退出后会取消该预约并立即释放本场名额。');">退出游戏</asp:LinkButton>
                        <%-- 跳转链接控件：根据绑定数据生成详情页、沟通页或外部页面入口。 --%>
                        <asp:HyperLink ID="lnkLobby" runat="server" CssClass="btn-primary" Text="进入候场大厅" />
                        <%-- 跳转链接控件：根据绑定数据生成详情页、沟通页或外部页面入口。 --%>
                        <asp:HyperLink ID="lnkConversation" runat="server" CssClass="btn-secondary" Text="订单沟通页" />
                        <%-- 跳转链接控件：根据绑定数据生成详情页、沟通页或外部页面入口。 --%>
                        <asp:HyperLink ID="lnkCheckInPass" runat="server" CssClass="btn-secondary" Text="核销通行证" />
                        <a class="btn-secondary" href="PlayerHub.aspx?tab=orders">返回订单列表</a>
                        <a class="btn-secondary" href="Reviews.aspx">查看点评</a>
                    </div>
                </article>

                <%-- 信息面板：承载一个独立的业务说明、列表或表单模块。 --%>
                <article class="about-panel">
                    <%-- 模块标题区：说明当前业务模块的名称和处理说明。 --%>
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
                    <%-- 操作按钮区：集中放置提交、重置、跳转或审核动作。 --%>
                    <div class="hero-actions top-gap">
                        <%-- 跳转链接控件：根据绑定数据生成详情页、沟通页或外部页面入口。 --%>
                        <asp:HyperLink ID="lnkCheckInPassInline" runat="server" CssClass="btn-secondary small" Text="打开核销通行证" />
                    </div>
                </article>
            </div>
        </section>

        <%-- 主要内容区：承载当前页面的核心业务列表、表单或详情内容。 --%>
        <section class="section-block">
            <div class="container split-grid detail-split">
                <%-- 信息面板：承载一个独立的业务说明、列表或表单模块。 --%>
                <article class="about-panel">
                    <%-- 模块标题区：说明当前业务模块的名称和处理说明。 --%>
                    <div class="section-heading left">
                        <h2>完整状态时间线</h2>
                        <p>按真实履约流程展示下单、支付、接单、排房、核销、完成和评价节点。</p>
                    </div>
                    <div class="service-timeline order-detail-timeline">
                        <%-- 数据列表控件 rptTimeline：后台绑定集合数据后，按 ItemTemplate 循环渲染每条记录。 --%>
                        <asp:Repeater ID="rptTimeline" runat="server">
                            <%-- 列表项模板：定义 Repeater 中每一条业务记录的 HTML 结构和绑定字段。 --%>
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

                <%-- 信息面板：承载一个独立的业务说明、列表或表单模块。 --%>
                <article class="about-panel">
                    <%-- 模块标题区：说明当前业务模块的名称和处理说明。 --%>
                    <div class="section-heading left">
                        <h2>处理说明</h2>
                        <p>不仅有状态值，还保留了玩家备注、门店备注和玩家确认结果。</p>
                    </div>
                    <%-- 列表容器：承载 Repeater 渲染出的多条业务卡片。 --%>
                    <div class="reservation-list">
                        <%-- 业务卡片：展示一条预约、审核、消息或统计记录。 --%>
                        <article class="reservation-card">
                            <h3>玩家备注</h3>
                            <p><asp:Literal ID="litUserRemark" runat="server" /></p>
                        </article>
                        <%-- 业务卡片：展示一条预约、审核、消息或统计记录。 --%>
                        <article class="reservation-card">
                            <h3>门店内部备注</h3>
                            <p><asp:Literal ID="litAdminRemark" runat="server" /></p>
                        </article>
                        <%-- 业务卡片：展示一条预约、审核、消息或统计记录。 --%>
                        <article class="reservation-card">
                            <h3>玩家确认结果</h3>
                            <p><asp:Literal ID="litConfirmRemark" runat="server" /></p>
                        </article>
                    </div>
                </article>
            </div>
        </section>

        <%-- 次级内容区：用于承载筛选、配置、辅助列表或补充信息。 --%>
        <section class="section-block alt">
            <div class="container split-grid detail-split">
                <%-- 信息面板：承载一个独立的业务说明、列表或表单模块。 --%>
                <article class="about-panel">
                    <%-- 模块标题区：说明当前业务模块的名称和处理说明。 --%>
                    <div class="section-heading left">
                        <h2>订单沟通记录</h2>
                        <p>这里展示当前订单的连续沟通记录，并可直接跳转到独立订单会话页继续聊天。</p>
                    </div>
                    <%-- 操作按钮区：集中放置提交、重置、跳转或审核动作。 --%>
                    <div class="hero-actions compact-actions">
                        <%-- 跳转链接控件：根据绑定数据生成详情页、沟通页或外部页面入口。 --%>
                        <asp:HyperLink ID="lnkConversationInline" runat="server" CssClass="btn-primary" Text="进入独立会话" />
                    </div>
                    <%-- 列表容器：承载 Repeater 渲染出的多条业务卡片。 --%>
                    <div class="reservation-list">
                        <%-- 数据列表控件 rptServiceMessages：后台绑定集合数据后，按 ItemTemplate 循环渲染每条记录。 --%>
                        <asp:Repeater ID="rptServiceMessages" runat="server">
                            <%-- 列表项模板：定义 Repeater 中每一条业务记录的 HTML 结构和绑定字段。 --%>
                            <ItemTemplate>
                                <%-- 业务卡片：展示一条预约、审核、消息或统计记录。 --%>
                                <article class="reservation-card service-reply-card">
                                    <h3><%# Eval("SenderName") %> · <%# GetServiceMessageRoleText(Eval("SenderRole")) %></h3>
                                    <p><%# Eval("Content") %></p>
                                    <small><%# Eval("CreatedAt", "{0:yyyy-MM-dd HH:mm}") %></small>
                                </article>
                            </ItemTemplate>
                        </asp:Repeater>
                    </div>
                </article>

                <%-- 信息面板：承载一个独立的业务说明、列表或表单模块。 --%>
                <article class="about-panel">
                    <%-- 模块标题区：说明当前业务模块的名称和处理说明。 --%>
                    <div class="section-heading left">
                        <h2>管理员回复日志</h2>
                        <p>保留管理员处理订单时给玩家的回复记录，便于展示服务闭环。</p>
                    </div>
                    <%-- 列表容器：承载 Repeater 渲染出的多条业务卡片。 --%>
                    <div class="reservation-list">
                        <%-- 数据列表控件 rptReplyLogs：后台绑定集合数据后，按 ItemTemplate 循环渲染每条记录。 --%>
                        <asp:Repeater ID="rptReplyLogs" runat="server">
                            <%-- 列表项模板：定义 Repeater 中每一条业务记录的 HTML 结构和绑定字段。 --%>
                            <ItemTemplate>
                                <%-- 业务卡片：展示一条预约、审核、消息或统计记录。 --%>
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

        <%-- 主要内容区：承载当前页面的核心业务列表、表单或详情内容。 --%>
        <section class="section-block">
            <div class="container">
                <%-- 信息面板：承载一个独立的业务说明、列表或表单模块。 --%>
                <article class="about-panel">
                    <%-- 模块标题区：说明当前业务模块的名称和处理说明。 --%>
                    <div class="section-heading left">
                        <h2>售后与评价状态</h2>
                        <p>订单完成后，售后申请和评价情况也会和订单绑定展示，不再分散在多个页面里查找。</p>
                    </div>
                    <asp:Panel ID="pnlRefundMessage" runat="server" Visible="false" CssClass="status-message">
                        <asp:Literal ID="litRefundMessage" runat="server" />
                    </asp:Panel>
                    <asp:Panel ID="pnlRefundTemplate" runat="server" CssClass="reservation-card top-gap">
                        <h3>退款 / 售后申请</h3>
                        <p>如果本次体验不满意、无法到店或需要协商退款，可以在这里提交申请。管理员会在后台“售后与退款”中审核处理。</p>
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
                                <label for="<%= txtAfterSaleAmount.ClientID %>">退款金额</label>
                                <asp:TextBox ID="txtAfterSaleAmount" runat="server" CssClass="input-control" placeholder="可留空，默认由管理员按订单金额审核" />
                            </div>
                        </div>
                        <div class="field-group">
                            <label for="<%= txtAfterSaleReason.ClientID %>">申请说明</label>
                            <asp:TextBox ID="txtAfterSaleReason" runat="server" CssClass="input-control textarea" TextMode="MultiLine" Rows="4" placeholder="请说明不满意原因、退款诉求或希望改期时间" />
                        </div>
                        <div class="field-group">
                            <label for="<%= fuAfterSaleEvidence.ClientID %>">凭证附件</label>
                            <asp:FileUpload ID="fuAfterSaleEvidence" runat="server" CssClass="input-control" />
                        </div>
                        <div class="hero-actions top-gap">
                            <asp:Button ID="btnCreateAfterSale" runat="server" Text="提交退款/售后申请" CssClass="btn-primary" OnClick="btnCreateAfterSale_Click" />
                        </div>
                    </asp:Panel>
                    <%-- 列表容器：承载 Repeater 渲染出的多条业务卡片。 --%>
                    <div class="reservation-list">
                        <%-- 数据列表控件 rptAfterSaleRequests：后台绑定集合数据后，按 ItemTemplate 循环渲染每条记录。 --%>
                        <asp:Repeater ID="rptAfterSaleRequests" runat="server">
                            <%-- 列表项模板：定义 Repeater 中每一条业务记录的 HTML 结构和绑定字段。 --%>
                            <ItemTemplate>
                                <%-- 业务卡片：展示一条预约、审核、消息或统计记录。 --%>
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
                    <%-- 操作按钮区：集中放置提交、重置、跳转或审核动作。 --%>
                    <div class="hero-actions top-gap">
                        <asp:Literal ID="litReviewBadge" runat="server" />
                        <a class="btn-secondary" href="Reviews.aspx">查看 / 提交评价</a>
                    </div>
                    <%-- 面板控件 pnlOrderReview：后台可通过 Visible/CssClass 控制整块内容是否显示以及提示样式。 --%>
                    <asp:Panel ID="pnlOrderReview" runat="server" Visible="false" CssClass="reservation-list top-gap">
                        <%-- 业务卡片：展示一条预约、审核、消息或统计记录。 --%>
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
