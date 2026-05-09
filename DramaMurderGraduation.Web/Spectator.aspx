<%@ Page Title="观战中心 | 剧本杀系统" Language="C#" MasterPageFile="~/Site.Master" AutoEventWireup="true" CodeBehind="Spectator.aspx.cs" Inherits="DramaMurderGraduation.Web.SpectatorPage" %>
<%-- 页面用途：Spectator 页面负责承载对应功能的 Web Forms 标记、服务端控件和前端布局。 --%>
<asp:Content ID="Content1" ContentPlaceHolderID="TitleContent" runat="server">
    观战中心 | 剧本杀系统
</asp:Content>
<asp:Content ID="Content2" ContentPlaceHolderID="MainContent" runat="server">
    <%-- 页面分区：把当前页面内容按业务模块拆分展示。 --%>
    <section class="hero-section">
        <div class="container spectator-stage">
            <%-- 内容卡片：用于组织当前模块中的一组相关信息。 --%>
            <article class="spectator-visual">
                <asp:Image ID="imgSelectedCover" runat="server" AlternateText="观战房间封面" />
            </article>
            <%-- 说明卡片：展示页面主标题、摘要和关键标签。 --%>
            <article class="detail-copy spectator-sidebar">
                <div class="hero-badge-row">
                    <span class="site-badge">观战中心</span>
                    <span class="site-badge soft"><asp:Literal ID="litRoomStatus" runat="server" /></span>
                </div>
                <p class="eyebrow">SPECTATOR</p>
                <h1><asp:Literal ID="litSelectedRoomTitle" runat="server" /></h1>
                <p class="hero-subtitle"><asp:Literal ID="litSelectedRoomScript" runat="server" /></p>
                <%-- 摘要标签区：展示当前页面最重要的数量或状态提示。 --%>
                <div class="detail-tags">
                    <span>主持人 <asp:Literal ID="litSelectedHost" runat="server" /></span>
                    <span>观战码 <asp:Literal ID="litSelectedRouteCode" runat="server" /></span>
                </div>
                <div class="detail-prices">
                    <strong><asp:Literal ID="litSelectedViewerCount" runat="server" /></strong>
                    <span>热度 <asp:Literal ID="litSelectedHeatScore" runat="server" /></span>
                </div>
                <%-- 操作按钮区：集中放置提交、重置、跳转或审核动作。 --%>
                <div class="hero-actions">
                    <a class="btn-primary" href="GameRoom.aspx?reservationId=1">进入演示房间</a>
                    <a class="btn-secondary" href="Discover.aspx">返回发现中心</a>
                </div>
            </article>
        </div>
    </section>

    <%-- 主要内容区：承载当前页面的核心业务列表、表单或详情内容。 --%>
    <section class="section-block">
        <div class="container split-grid">
            <%-- 信息面板：承载一个独立的业务说明、列表或表单模块。 --%>
            <article class="about-panel">
                <%-- 模块标题区：说明当前业务模块的名称和处理说明。 --%>
                <div class="section-heading left">
                    <h2>观战模式选择</h2>
                    <p>这一块对应“观战模式选择”和“观战游戏视图”的入口设计。</p>
                </div>
                <div class="identity-grid">
                    <%-- 数据列表控件 rptSpectatorModes：后台绑定集合数据后，按 ItemTemplate 循环渲染每条记录。 --%>
                    <asp:Repeater ID="rptSpectatorModes" runat="server">
                        <%-- 列表项模板：定义 Repeater 中每一条业务记录的 HTML 结构和绑定字段。 --%>
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

            <%-- 信息面板：承载一个独立的业务说明、列表或表单模块。 --%>
            <article class="about-panel">
                <%-- 模块标题区：说明当前业务模块的名称和处理说明。 --%>
                <div class="section-heading left" id="spectator-room-list">
                    <h2>正在观战的房间</h2>
                    <p>这里会列出正在开放的观战房间，点开就能切换到你感兴趣的那一局。</p>
                </div>
                <div class="mini-card-grid">
                    <%-- 数据列表控件 rptSpectatorRooms：后台绑定集合数据后，按 ItemTemplate 循环渲染每条记录。 --%>
                    <asp:Repeater ID="rptSpectatorRooms" runat="server">
                        <%-- 列表项模板：定义 Repeater 中每一条业务记录的 HTML 结构和绑定字段。 --%>
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

    <%-- 次级内容区：用于承载筛选、配置、辅助列表或补充信息。 --%>
    <section class="section-block alt">
        <div class="container">
            <%-- 模块标题区：说明当前业务模块的名称和处理说明。 --%>
            <div class="section-heading">
                <h2>观战聊天互动</h2>
                <p>围观时也能一起聊剧情、聊翻盘点，把当晚最有火花的讨论留在这里。</p>
            </div>
            <div class="message-list">
                <%-- 数据列表控件 rptSpectatorMessages：后台绑定集合数据后，按 ItemTemplate 循环渲染每条记录。 --%>
                <asp:Repeater ID="rptSpectatorMessages" runat="server">
                    <%-- 列表项模板：定义 Repeater 中每一条业务记录的 HTML 结构和绑定字段。 --%>
                    <ItemTemplate>
                        <%-- 内容卡片：用于组织当前模块中的一组相关信息。 --%>
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
