<%@ Page Title="订单沟通页 | 剧本杀系统" Language="C#" MasterPageFile="~/Site.Master" AutoEventWireup="true" CodeBehind="OrderConversation.aspx.cs" Inherits="DramaMurderGraduation.Web.OrderConversationPage" %>
<asp:Content ID="Content1" ContentPlaceHolderID="TitleContent" runat="server">
    订单沟通页 | 剧本杀系统
</asp:Content>
<asp:Content ID="Content2" ContentPlaceHolderID="MainContent" runat="server">
    <asp:Panel ID="pnlNotFound" runat="server" Visible="false" CssClass="section-block">
        <div class="container empty-state">
            <h1>未找到对应订单会话</h1>
            <p>订单不存在，或当前账号没有查看这笔订单沟通记录的权限。</p>
            <a class="btn-primary" href="PlayerHub.aspx?tab=orders">返回我的订单</a>
        </div>
    </asp:Panel>

    <asp:Panel ID="pnlConversation" runat="server" Visible="false">
        <section class="detail-hero">
            <div class="container detail-grid">
                <article class="detail-copy">
                    <p class="eyebrow">ORDER CONVERSATION</p>
                    <h1><asp:Literal ID="litScriptName" runat="server" /></h1>
                    <p class="hero-subtitle">订单 #<asp:Literal ID="litReservationId" runat="server" /> 的独立服务会话</p>
                    <p class="hero-text">用户和门店围绕同一笔订单连续沟通，预约安排、特殊需求、改期确认和到店提醒都集中在这条会话里。</p>
                    <div class="detail-tags">
                        <span>开场时间：<asp:Literal ID="litSessionTime" runat="server" /></span>
                        <span>房间：<asp:Literal ID="litRoomName" runat="server" /></span>
                        <span>DM：<asp:Literal ID="litHostName" runat="server" /></span>
                    </div>
                    <div class="hero-actions">
                        <asp:HyperLink ID="lnkOrderDetails" runat="server" CssClass="btn-primary" Text="查看订单详情" />
                        <asp:HyperLink ID="lnkPlayerHub" runat="server" CssClass="btn-secondary" Text="返回订单列表" NavigateUrl="PlayerHub.aspx?tab=orders" />
                        <asp:HyperLink ID="lnkAdminReview" runat="server" CssClass="btn-secondary" Text="返回后台待办" Visible="false" NavigateUrl="AdminReview.aspx#service-message-admin" />
                    </div>
                </article>

                <article class="about-panel">
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

        <section class="section-block">
            <div class="container split-grid detail-split">
                <article class="about-panel">
                    <div class="section-heading left">
                        <h2>订单连续沟通</h2>
                        <p>按时间顺序保留用户追问、门店回复和处理说明，避免订单处理记录散落在多个地方。</p>
                    </div>
                    <div class="service-conversation-thread">
                        <asp:Repeater ID="rptMessages" runat="server">
                            <ItemTemplate>
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

                <article class="about-panel">
                    <div class="section-heading left">
                        <h2>发送新消息</h2>
                        <p>门店和用户都可以在这里补充要求、确认变更和跟进履约安排。</p>
                    </div>
                    <asp:Panel ID="pnlComposeMessage" runat="server" Visible="false" CssClass="status-message">
                        <asp:Literal ID="litComposeMessage" runat="server" />
                    </asp:Panel>
                    <div class="form-grid single-form conversation-compose">
                        <div class="field-group full">
                            <label for="<%= txtMessageContent.ClientID %>">消息内容</label>
                            <asp:TextBox ID="txtMessageContent" runat="server" CssClass="input-control textarea" TextMode="MultiLine" Rows="6" MaxLength="800" placeholder="填写订单安排、人数变化、到店问题、特殊需求或改期确认。" />
                        </div>
                    </div>
                    <div class="hero-actions">
                        <asp:Button ID="btnSendMessage" runat="server" Text="发送到本订单会话" CssClass="btn-primary" OnClick="btnSendMessage_Click" />
                    </div>
                    <p class="inline-note">管理员发送的消息会同步到通知中心；玩家发送的追问会出现在后台服务会话列表里。</p>
                </article>
            </div>
        </section>
    </asp:Panel>
</asp:Content>
