<%@ Page Title="观战中心 | 剧本杀系统" Language="C#" MasterPageFile="~/Site.Master" AutoEventWireup="true" CodeBehind="Spectator.aspx.cs" Inherits="DramaMurderGraduation.Web.SpectatorPage" %>
<asp:Content ID="Content1" ContentPlaceHolderID="TitleContent" runat="server">
    观战中心 | 剧本杀系统
</asp:Content>
<asp:Content ID="Content2" ContentPlaceHolderID="MainContent" runat="server">
    <section class="hero-section">
        <div class="container spectator-stage">
            <article class="spectator-visual">
                <asp:Image ID="imgSelectedCover" runat="server" AlternateText="观战房间封面" />
            </article>
            <article class="detail-copy spectator-sidebar">
                <div class="hero-badge-row">
                    <span class="site-badge">观战中心</span>
                    <span class="site-badge soft"><asp:Literal ID="litRoomStatus" runat="server" /></span>
                </div>
                <p class="eyebrow">SPECTATOR</p>
                <h1><asp:Literal ID="litSelectedRoomTitle" runat="server" /></h1>
                <p class="hero-subtitle"><asp:Literal ID="litSelectedRoomScript" runat="server" /></p>
                <div class="detail-tags">
                    <span>主持人 <asp:Literal ID="litSelectedHost" runat="server" /></span>
                    <span>观战码 <asp:Literal ID="litSelectedRouteCode" runat="server" /></span>
                </div>
                <div class="detail-prices">
                    <strong><asp:Literal ID="litSelectedViewerCount" runat="server" /></strong>
                    <span>热度 <asp:Literal ID="litSelectedHeatScore" runat="server" /></span>
                </div>
                <div class="hero-actions">
                    <a class="btn-primary" href="GameRoom.aspx?reservationId=1">进入演示房间</a>
                    <a class="btn-secondary" href="Discover.aspx">返回发现中心</a>
                </div>
            </article>
        </div>
    </section>

    <section class="section-block">
        <div class="container split-grid">
            <article class="about-panel">
                <div class="section-heading left">
                    <h2>观战模式选择</h2>
                    <p>这一块对应“观战模式选择”和“观战游戏视图”的入口设计。</p>
                </div>
                <div class="identity-grid">
                    <asp:Repeater ID="rptSpectatorModes" runat="server">
                        <ItemTemplate>
                            <a class="identity-card click-card interactive-card" href="#spectator-room-list">
                                <h3><%# Eval("Name") %></h3>
                                <p><%# Eval("Description") %></p>
                                <p class="meta-copy"><%# Eval("SceneText") %></p>
                            </a>
                        </ItemTemplate>
                    </asp:Repeater>
                </div>
            </article>

            <article class="about-panel">
                <div class="section-heading left" id="spectator-room-list">
                    <h2>正在观战的房间</h2>
                    <p>这里会列出正在开放的观战房间，点开就能切换到你感兴趣的那一局。</p>
                </div>
                <div class="mini-card-grid">
                    <asp:Repeater ID="rptSpectatorRooms" runat="server">
                        <ItemTemplate>
                            <a class="compact-card click-card interactive-card" href='Spectator.aspx?roomId=<%# Eval("Id") %>'>
                                <img src='<%# Eval("CoverImage") %>' alt='<%# Eval("Title") %>' />
                                <div class="compact-card-body">
                                    <span class="badge-inline"><%# Eval("RoomStatus") %></span>
                                    <h3><%# Eval("Title") %></h3>
                                    <p><%# Eval("ScriptName") %> · DM <%# Eval("HostName") %></p>
                                    <p class="meta-copy">观众 <%# Eval("ViewerCount") %> · 热度 <%# Eval("HeatScore") %></p>
                                    <span class="text-link strong">切换到该房间</span>
                                </div>
                            </a>
                        </ItemTemplate>
                    </asp:Repeater>
                </div>
            </article>
        </div>
    </section>

    <section class="section-block alt">
        <div class="container">
            <div class="section-heading">
                <h2>观战聊天互动</h2>
                <p>围观时也能一起聊剧情、聊翻盘点，把当晚最有火花的讨论留在这里。</p>
            </div>
            <div class="message-list">
                <asp:Repeater ID="rptSpectatorMessages" runat="server">
                    <ItemTemplate>
                        <article class="message-item">
                            <div class="message-head">
                                <strong><%# Eval("SenderName") %></strong>
                                <span class="badge-inline"><%# Eval("BadgeText") %></span>
                            </div>
                            <p><%# Eval("Content") %></p>
                            <small><%# Eval("SentAt", "{0:yyyy-MM-dd HH:mm}") %></small>
                        </article>
                    </ItemTemplate>
                </asp:Repeater>
            </div>
        </div>
    </section>
</asp:Content>
