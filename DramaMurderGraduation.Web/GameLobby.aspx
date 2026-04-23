<%@ Page Title="房间大厅 | 剧本杀系统" Language="C#" MasterPageFile="~/Site.Master" AutoEventWireup="true" CodeBehind="GameLobby.aspx.cs" Inherits="DramaMurderGraduation.Web.GameLobbyPage" %>
<asp:Content ID="Content1" ContentPlaceHolderID="TitleContent" runat="server">
    房间大厅 | 剧本杀系统
</asp:Content>
<asp:Content ID="Content2" ContentPlaceHolderID="MainContent" runat="server">
    <asp:Panel ID="pnlNotFound" runat="server" Visible="false" CssClass="section-block">
        <div class="container empty-state">
            <h1>未找到对应预约</h1>
            <p>请先完成预约，再进入房间大厅开始游戏。</p>
            <a class="btn-primary" href="Booking.aspx">返回预约页面</a>
        </div>
    </asp:Panel>

    <asp:Panel ID="pnlLobby" runat="server" Visible="false">
        <section class="detail-hero">
            <div class="container detail-grid lobby-grid">
                <article class="detail-copy lobby-copy">
                    <div class="hero-badge-row">
                        <span class="site-badge">Team Formation Lobby</span>
                        <span class="site-badge soft">动态房间大厅</span>
                    </div>
                    <p class="eyebrow">GAME LOBBY</p>
                    <h1>组队大厅已准备就绪</h1>
                    <p class="hero-subtitle">确认队友、核对场次、查看 DM 和房间信息后，就可以进入正式游戏房间。</p>
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
                    <div class="hero-actions">
                        <a class="btn-primary" href='<%= "GameRoom.aspx?reservationId=" + Request.QueryString["reservationId"] %>'>进入游戏房间</a>
                        <a class="btn-secondary" href="ScriptsList.aspx">继续浏览剧本</a>
                    </div>
                    <asp:Panel ID="pnlLobbyMessage" runat="server" Visible="false" CssClass="status-message">
                        <asp:Literal ID="litLobbyMessage" runat="server" />
                    </asp:Panel>
                    <div class="form-grid single-form">
                        <div class="field-group full">
                            <label for="<%= txtReservationRescheduleRemark.ClientID %>">改期说明</label>
                            <asp:TextBox ID="txtReservationRescheduleRemark" runat="server" CssClass="input-control textarea" TextMode="MultiLine" Rows="2" placeholder="如需改期，请填写希望调整到的时间和原因" />
                        </div>
                    </div>
                    <div class="hero-actions">
                        <asp:Button ID="btnConfirmReservationReceived" runat="server" Text="我已收到" CssClass="btn-primary" OnClick="btnConfirmReservationReceived_Click" />
                        <asp:Button ID="btnRequestReservationReschedule" runat="server" Text="申请改期" CssClass="btn-secondary" OnClick="btnRequestReservationReschedule_Click" />
                    </div>
                </article>

                <article class="about-panel lobby-summary-panel">
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

        <section class="section-block alt">
            <div class="container split-grid">
                <article class="about-panel">
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

                <article class="about-panel">
                    <div class="section-heading left">
                        <h2>当前房间预览</h2>
                        <p>快速确认本场房间和剧本信息。</p>
                    </div>
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
