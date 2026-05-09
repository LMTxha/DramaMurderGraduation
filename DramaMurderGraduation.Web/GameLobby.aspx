<%@ Page Title="房间大厅 | 剧本杀系统" Language="C#" MasterPageFile="~/Site.Master" AutoEventWireup="true" CodeBehind="GameLobby.aspx.cs" Inherits="DramaMurderGraduation.Web.GameLobbyPage" %>
<%-- 页面用途：GameLobby 页面负责承载对应功能的 Web Forms 标记、服务端控件和前端布局。 --%>
<asp:Content ID="Content1" ContentPlaceHolderID="TitleContent" runat="server">
    房间大厅 | 剧本杀系统
</asp:Content>
<asp:Content ID="Content2" ContentPlaceHolderID="MainContent" runat="server">
    <%-- 面板控件 pnlNotFound：后台可通过 Visible/CssClass 控制整块内容是否显示以及提示样式。 --%>
    <asp:Panel ID="pnlNotFound" runat="server" Visible="false" CssClass="section-block">
        <div class="container empty-state">
            <h1>未找到对应预约</h1>
            <p>请先完成预约，再进入房间大厅开始游戏。</p>
            <a class="btn-primary" href="Booking.aspx">返回预约页面</a>
        </div>
    </asp:Panel>

    <%-- 面板控件 pnlLobby：后台可通过 Visible/CssClass 控制整块内容是否显示以及提示样式。 --%>
    <asp:Panel ID="pnlLobby" runat="server" Visible="false">
        <%-- 页面头图区：展示当前功能的标题、说明和关键入口。 --%>
        <section class="detail-hero">
            <div class="container detail-grid lobby-grid">
                <%-- 说明卡片：展示页面主标题、摘要和关键标签。 --%>
                <article class="detail-copy lobby-copy">
                    <div class="hero-badge-row">
                        <span class="site-badge">Team Formation Lobby</span>
                        <span class="site-badge soft">动态房间大厅</span>
                    </div>
                    <p class="eyebrow">GAME LOBBY</p>
                    <h1>组队大厅已准备就绪</h1>
                    <p class="hero-subtitle">确认队友、核对场次、查看 DM 和房间信息后，就可以进入正式游戏房间。</p>
                    <%-- 摘要标签区：展示当前页面最重要的数量或状态提示。 --%>
                    <div class="detail-tags">
                        <span>剧本：<asp:Literal ID="litScriptName" runat="server" /></span>
                        <span>房间：<asp:Literal ID="litRoomName" runat="server" /></span>
                        <span>DM：<asp:Literal ID="litHostName" runat="server" /></span>
                    </div>
                    <div class="detail-prices">
                        <strong>¥<asp:Literal ID="litTotalAmount" runat="server" /></strong>
                        <span><asp:Literal ID="litPlayerCount" runat="server" /> 人入场</span>
                        <span><asp:Literal ID="litPaymentStatus" runat="server" /></span>
                    </div>
                    <%-- 操作按钮区：集中放置提交、重置、跳转或审核动作。 --%>
                    <div class="hero-actions">
                        <a class="btn-primary" href='<%= "GameRoom.aspx?reservationId=" + Request.QueryString["reservationId"] %>'>进入游戏房间</a>
                        <a class="btn-secondary" href="ScriptsList.aspx">继续浏览剧本</a>
                        <asp:LinkButton ID="btnLeaveReservation" runat="server" CssClass="btn-secondary danger-button" OnClick="btnLeaveReservation_Click" OnClientClick="return confirm('确认退出这个游戏吗？退出后会取消该预约并立即释放本场名额。');">退出游戏</asp:LinkButton>
                    </div>
                    <%-- 面板控件 pnlLobbyMessage：后台可通过 Visible/CssClass 控制整块内容是否显示以及提示样式。 --%>
                    <asp:Panel ID="pnlLobbyMessage" runat="server" Visible="false" CssClass="status-message">
                        <asp:Literal ID="litLobbyMessage" runat="server" />
                    </asp:Panel>
                    <%-- 表单网格：按响应式布局排列输入框、下拉框和筛选条件。 --%>
                    <div class="form-grid single-form">
                        <div class="field-group full">
                            <label for="<%= txtReservationRescheduleRemark.ClientID %>">改期说明</label>
                            <%-- 输入控件 txtReservationRescheduleRemark：接收用户输入或展示后台已有备注。 --%>
                            <asp:TextBox ID="txtReservationRescheduleRemark" runat="server" CssClass="input-control textarea" TextMode="MultiLine" Rows="2" placeholder="如需改期，请填写希望调整到的时间和原因" />
                        </div>
                    </div>
                    <%-- 操作按钮区：集中放置提交、重置、跳转或审核动作。 --%>
                    <div class="hero-actions">
                        <%-- 操作按钮 btnConfirmReservationReceived：点击后触发后台事件处理当前业务动作。 --%>
                        <asp:Button ID="btnConfirmReservationReceived" runat="server" Text="我已收到" CssClass="btn-primary" OnClick="btnConfirmReservationReceived_Click" />
                        <%-- 操作按钮 btnRequestReservationReschedule：点击后触发后台事件处理当前业务动作。 --%>
                        <asp:Button ID="btnRequestReservationReschedule" runat="server" Text="申请改期" CssClass="btn-secondary" OnClick="btnRequestReservationReschedule_Click" />
                    </div>
                </article>

                <%-- 信息面板：承载一个独立的业务说明、列表或表单模块。 --%>
                <article class="about-panel lobby-summary-panel">
                    <%-- 模块标题区：说明当前业务模块的名称和处理说明。 --%>
                    <div class="section-heading left">
                        <h2>入场信息</h2>
                        <p>这些字段来自预约、场次和房间数据。</p>
                    </div>
                    <div class="lobby-summary-list">
                        <div class="lobby-summary-item"><span>预约编号</span><strong><asp:Literal ID="litReservationId" runat="server" /></strong></div>
                        <div class="lobby-summary-item"><span>联系人</span><strong><asp:Literal ID="litContactName" runat="server" /></strong></div>
                        <div class="lobby-summary-item"><span>开场时间</span><strong><asp:Literal ID="litSessionTime" runat="server" /></strong></div>
                        <div class="lobby-summary-item"><span>预约状态</span><strong><asp:Literal ID="litReservationStatus" runat="server" /></strong></div>
                        <div class="lobby-summary-item"><span>房间编号</span><strong><asp:Literal ID="litRoomCode" runat="server" /></strong></div>
                        <div class="lobby-summary-item"><span>门店回复</span><strong><asp:Literal ID="litAdminReply" runat="server" /></strong></div>
                    </div>
                </article>
            </div>
        </section>

        <%-- 次级内容区：用于承载筛选、配置、辅助列表或补充信息。 --%>
        <section class="section-block alt">
            <div class="container split-grid">
                <%-- 信息面板：承载一个独立的业务说明、列表或表单模块。 --%>
                <article class="about-panel">
                    <%-- 模块标题区：说明当前业务模块的名称和处理说明。 --%>
                    <div class="section-heading left">
                        <h2>进入后可以体验什么</h2>
                        <p>正式房间包含角色本、阶段推进、线索、聊天、投票和 DM 控场。</p>
                    </div>
                    <div class="feature-list-vertical">
                        <p class="about-text">1. 同房玩家席位与视频快照同步</p>
                        <p class="about-text">2. 角色卡、剧情阶段与线索板联动</p>
                        <p class="about-text">3. 文字聊天、语音留言和房间互动</p>
                        <p class="about-text">4. 调查行动、阶段推进与终局投票</p>
                    </div>
                </article>

                <%-- 信息面板：承载一个独立的业务说明、列表或表单模块。 --%>
                <article class="about-panel">
                    <%-- 模块标题区：说明当前业务模块的名称和处理说明。 --%>
                    <div class="section-heading left">
                        <h2>当前房间预览</h2>
                        <p>快速确认本场房间和剧本信息。</p>
                    </div>
                    <%-- 摘要标签区：展示当前页面最重要的数量或状态提示。 --%>
                    <div class="detail-tags">
                        <span>房间号：<asp:Literal ID="litRoomCodePreview" runat="server" /></span>
                        <span>开场：<asp:Literal ID="litSessionTimePreview" runat="server" /></span>
                    </div>
                    <p class="about-text">主持人：<asp:Literal ID="litHostNamePreview" runat="server" /></p>
                    <p class="about-text">当前剧本：<asp:Literal ID="litScriptNamePreview" runat="server" /></p>
                </article>
            </div>
        </section>
    </asp:Panel>
</asp:Content>
