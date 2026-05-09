<%@ Page Title="订单沟通页 | 剧本杀系统" Language="C#" MasterPageFile="~/Site.Master" AutoEventWireup="true" CodeBehind="OrderConversation.aspx.cs" Inherits="DramaMurderGraduation.Web.OrderConversationPage" %>
<%-- 页面用途：OrderConversation 页面负责承载对应功能的 Web Forms 标记、服务端控件和前端布局。 --%>
<asp:Content ID="Content1" ContentPlaceHolderID="TitleContent" runat="server">
    订单沟通页 | 剧本杀系统
</asp:Content>
<asp:Content ID="Content2" ContentPlaceHolderID="MainContent" runat="server">
    <%-- 面板控件 pnlNotFound：后台可通过 Visible/CssClass 控制整块内容是否显示以及提示样式。 --%>
    <asp:Panel ID="pnlNotFound" runat="server" Visible="false" CssClass="section-block">
        <div class="container empty-state">
            <h1>未找到对应订单会话</h1>
            <p>订单不存在，或当前账号没有查看这笔订单沟通记录的权限。</p>
            <a class="btn-primary" href="PlayerHub.aspx?tab=orders">返回我的订单</a>
        </div>
    </asp:Panel>

    <%-- 面板控件 pnlConversation：后台可通过 Visible/CssClass 控制整块内容是否显示以及提示样式。 --%>
    <asp:Panel ID="pnlConversation" runat="server" Visible="false">
        <%-- 页面头图区：展示当前功能的标题、说明和关键入口。 --%>
        <section class="detail-hero">
            <div class="container detail-grid">
                <%-- 说明卡片：展示页面主标题、摘要和关键标签。 --%>
                <article class="detail-copy">
                    <p class="eyebrow">ORDER CONVERSATION</p>
                    <h1><asp:Literal ID="litScriptName" runat="server" /></h1>
                    <p class="hero-subtitle">订单 #<asp:Literal ID="litReservationId" runat="server" /> 的独立服务会话</p>
                    <p class="hero-text">用户和门店围绕同一笔订单连续沟通，预约安排、特殊需求、改期确认和到店提醒都集中在这条会话里。</p>
                    <%-- 摘要标签区：展示当前页面最重要的数量或状态提示。 --%>
                    <div class="detail-tags">
                        <span>开场时间：<asp:Literal ID="litSessionTime" runat="server" /></span>
                        <span>房间：<asp:Literal ID="litRoomName" runat="server" /></span>
                        <span>DM：<asp:Literal ID="litHostName" runat="server" /></span>
                    </div>
                    <%-- 操作按钮区：集中放置提交、重置、跳转或审核动作。 --%>
                    <div class="hero-actions">
                        <%-- 跳转链接控件：根据绑定数据生成详情页、沟通页或外部页面入口。 --%>
                        <asp:HyperLink ID="lnkOrderDetails" runat="server" CssClass="btn-primary" Text="查看订单详情" />
                        <%-- 跳转链接控件：根据绑定数据生成详情页、沟通页或外部页面入口。 --%>
                        <asp:HyperLink ID="lnkPlayerHub" runat="server" CssClass="btn-secondary" Text="返回订单列表" NavigateUrl="PlayerHub.aspx?tab=orders" />
                        <%-- 跳转链接控件：根据绑定数据生成详情页、沟通页或外部页面入口。 --%>
                        <asp:HyperLink ID="lnkAdminReview" runat="server" CssClass="btn-secondary" Text="返回后台待办" Visible="false" NavigateUrl="AdminReview.aspx#service-message-admin" />
                    </div>
                </article>

                <%-- 信息面板：承载一个独立的业务说明、列表或表单模块。 --%>
                <article class="about-panel">
                    <%-- 模块标题区：说明当前业务模块的名称和处理说明。 --%>
                    <div class="section-heading left">
                        <h2>会话总览</h2>
                        <p>这里显示订单参与人、当前状态、最近消息时间和未读情况，方便客服和玩家继续追踪。</p>
                    </div>
                    <div class="lobby-summary-list conversation-summary-list">
                        <div class="lobby-summary-item"><span>联系人</span><strong><asp:Literal ID="litContactName" runat="server" /></strong></div>
                        <div class="lobby-summary-item"><span>订单状态</span><strong><asp:Literal ID="litReservationStatus" runat="server" /></strong></div>
                        <div class="lobby-summary-item"><span>支付状态</span><strong><asp:Literal ID="litPaymentStatus" runat="server" /></strong></div>
                        <div class="lobby-summary-item"><span>会话消息</span><strong><asp:Literal ID="litMessageCount" runat="server" /></strong></div>
                        <div class="lobby-summary-item"><span>最新消息</span><strong><asp:Literal ID="litLastMessageTime" runat="server" /></strong></div>
                        <div class="lobby-summary-item"><span>未读来信</span><strong><asp:Literal ID="litUnreadSummary" runat="server" /></strong></div>
                    </div>
                    <p class="about-text top-gap">玩家备注：<asp:Literal ID="litUserRemark" runat="server" /></p>
                    <p class="about-text">门店备注：<asp:Literal ID="litAdminRemark" runat="server" /></p>
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
                        <h2>订单连续沟通</h2>
                        <p>按时间顺序保留用户追问、门店回复和处理说明，避免订单处理记录散落在多个地方。</p>
                    </div>
                    <div class="service-conversation-thread">
                        <%-- 数据列表控件 rptMessages：后台绑定集合数据后，按 ItemTemplate 循环渲染每条记录。 --%>
                        <asp:Repeater ID="rptMessages" runat="server">
                            <%-- 列表项模板：定义 Repeater 中每一条业务记录的 HTML 结构和绑定字段。 --%>
                            <ItemTemplate>
                                <%-- 内容卡片：用于组织当前模块中的一组相关信息。 --%>
                                <article class='service-message-bubble <%# GetMessageCssClass(Container.DataItem) %>'>
                                    <div class="service-message-meta">
                                        <strong><%# Eval("SenderName") %></strong>
                                        <span><%# GetSenderRoleText(Eval("SenderRole")) %> / <%# Eval("CreatedAt", "{0:yyyy-MM-dd HH:mm}") %></span>
                                    </div>
                                    <p><%# Eval("Content") %></p>
                                    <small><%# GetReadStateText(Container.DataItem) %></small>
                                </article>
                            </ItemTemplate>
                        </asp:Repeater>
                        <asp:Literal ID="litThreadEmpty" runat="server" />
                    </div>
                </article>

                <%-- 信息面板：承载一个独立的业务说明、列表或表单模块。 --%>
                <article class="about-panel">
                    <%-- 模块标题区：说明当前业务模块的名称和处理说明。 --%>
                    <div class="section-heading left">
                        <h2>发送新消息</h2>
                        <p>门店和用户都可以在这里补充要求、确认变更和跟进履约安排。</p>
                    </div>
                    <%-- 面板控件 pnlComposeMessage：后台可通过 Visible/CssClass 控制整块内容是否显示以及提示样式。 --%>
                    <asp:Panel ID="pnlComposeMessage" runat="server" Visible="false" CssClass="status-message">
                        <asp:Literal ID="litComposeMessage" runat="server" />
                    </asp:Panel>
                    <%-- 表单网格：按响应式布局排列输入框、下拉框和筛选条件。 --%>
                    <div class="form-grid single-form conversation-compose">
                        <div class="field-group full">
                            <label for="<%= txtMessageContent.ClientID %>">消息内容</label>
                            <%-- 输入控件 txtMessageContent：接收用户输入或展示后台已有备注。 --%>
                            <asp:TextBox ID="txtMessageContent" runat="server" CssClass="input-control textarea" TextMode="MultiLine" Rows="6" MaxLength="800" placeholder="填写订单安排、人数变化、到店问题、特殊需求或改期确认。" />
                        </div>
                    </div>
                    <%-- 操作按钮区：集中放置提交、重置、跳转或审核动作。 --%>
                    <div class="hero-actions">
                        <%-- 操作按钮 btnSendMessage：点击后触发后台事件处理当前业务动作。 --%>
                        <asp:Button ID="btnSendMessage" runat="server" Text="发送到本订单会话" CssClass="btn-primary" OnClick="btnSendMessage_Click" />
                    </div>
                    <p class="inline-note">管理员发送的消息会同步到通知中心；玩家发送的追问会出现在后台服务会话列表里。</p>
                </article>
            </div>
        </section>
    </asp:Panel>
</asp:Content>
