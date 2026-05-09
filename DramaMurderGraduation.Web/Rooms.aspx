<%@ Page Title="房间场次 | 剧本杀系统" Language="C#" MasterPageFile="~/Site.Master" AutoEventWireup="true" CodeBehind="Rooms.aspx.cs" Inherits="DramaMurderGraduation.Web.RoomsPage" %>
<%-- 页面用途：Rooms 页面负责承载对应功能的 Web Forms 标记、服务端控件和前端布局。 --%>
<asp:Content ID="Content1" ContentPlaceHolderID="TitleContent" runat="server">
    房间场次 | 剧本杀系统
</asp:Content>
<asp:Content ID="Content2" ContentPlaceHolderID="MainContent" runat="server">
    <%-- 页面分区：把当前页面内容按业务模块拆分展示。 --%>
    <section class="inner-hero">
        <div class="container">
            <p class="eyebrow">Rooms & Sessions</p>
            <h1>主题房间与近期排期</h1>
            <p>先看每个房间的氛围和配置，再一键跳到这个房间的可约场次，整个选场流程会顺很多。</p>
        </div>
    </section>

    <%-- 主要内容区：承载当前页面的核心业务列表、表单或详情内容。 --%>
    <section class="section-block">
        <div class="container">
            <%-- 模块标题区：说明当前业务模块的名称和处理说明。 --%>
            <div class="section-heading">
                <h2>主题房间</h2>
                <p>房间卡片现在可以直接点开，帮你快速筛到对应房间的场次安排和最近可约入口。</p>
            </div>
            <div class="card-grid">
                <%-- 数据列表控件 rptRooms：后台绑定集合数据后，按 ItemTemplate 循环渲染每条记录。 --%>
                <asp:Repeater ID="rptRooms" runat="server">
                    <%-- 列表项模板：定义 Repeater 中每一条业务记录的 HTML 结构和绑定字段。 --%>
                    <ItemTemplate>
                        <a class='<%# GetRoomCardClass(Eval("Id")) %>' href='<%# GetRoomSessionsUrl(Eval("Id")) %>'>
                            <img src='<%# Eval("ImageUrl") %>' alt='<%# Eval("Name") %>' />
                            <div class="card-body">
                                <div class="card-meta">
                                    <span><%# Eval("Theme") %></span>
                                    <span><%# Eval("Status") %></span>
                                </div>
                                <h3><%# Eval("Name") %></h3>
                                <p><%# Eval("Description") %></p>
                                <div class="card-stats">
                                    <span>容纳 <%# Eval("Capacity") %> 人</span>
                                    <span>可约场次 <%# Eval("UpcomingSessionCount") %></span>
                                </div>
                                <div class="card-actions room-card-actions">
                                    <span class="btn-secondary small pseudo-button">查看本厅场次</span>
                                    <span class="text-link strong"><%# GetRoomBookingLabel(Eval("PrimarySessionId")) %></span>
                                </div>
                            </div>
                        </a>
                    </ItemTemplate>
                </asp:Repeater>
            </div>
        </div>
    </section>

    <%-- 次级内容区：展示玩家已占位的主题房间，便于离开网页后继续进入游戏。 --%>
    <section class="section-block" id="my-rooms">
        <div class="container">
            <div class="section-heading">
                <h2><%= GetMyRoomHeading() %></h2>
                <p><%= GetMyRoomDescription() %></p>
            </div>

            <div class="session-list my-room-list">
                <asp:Repeater ID="rptMyRooms" runat="server">
                    <ItemTemplate>
                        <article class="session-card wide my-room-card">
                            <div>
                                <div class="card-meta">
                                    <span><%# Eval("Status") %></span>
                                    <span>ROOM-<%# Eval("SessionId", "{0:D4}") %></span>
                                </div>
                                <h3><%# Eval("ScriptName") %></h3>
                                <p><%# Eval("RoomName") %> / DM <%# Eval("HostName") %> / <%# Eval("PlayerCount") %> 人</p>
                                <small>开场 <%# Eval("SessionDateTime", "{0:yyyy-MM-dd HH:mm}") %></small>
                            </div>
                            <div class="session-side">
                                <strong>已保留名额</strong>
                                <div class="card-actions room-reentry-actions">
                                    <a class="btn-primary small" href='GameRoom.aspx?reservationId=<%# Eval("Id") %>'>继续游戏</a>
                                    <a class="btn-secondary small" href='GameLobby.aspx?reservationId=<%# Eval("Id") %>'>进入候场</a>
                                </div>
                            </div>
                        </article>
                    </ItemTemplate>
                </asp:Repeater>

                <% if (!HasMyRooms) { %>
                <article class="session-card wide my-room-card">
                    <div>
                        <h3>还没有需要继续进入的房间</h3>
                        <p>预约成功后，只要不主动退出游戏，这里会保留继续游戏入口。</p>
                    </div>
                    <div class="session-side">
                        <a class="btn-secondary" href="#room-sessions">查看可预约场次</a>
                    </div>
                </article>
                <% } %>
            </div>
        </div>
    </section>

    <%-- 次级内容区：用于承载筛选、配置、辅助列表或补充信息。 --%>
    <section class="section-block alt" id="room-sessions">
        <div class="container">
            <%-- 模块标题区：说明当前业务模块的名称和处理说明。 --%>
            <div class="section-heading">
                <h2><%= GetSessionHeading() %></h2>
                <p><%= GetSessionDescription() %></p>
            </div>

            <% if (SelectedRoom != null) { %>
            <%-- 统计网格：集中展示多个关键业务指标。 --%>
            <div class="wallet-summary-grid booking-filter-grid room-filter-summary">
                <%-- 统计卡片：展示一个后台指标或运营数据。 --%>
                <article class="wallet-summary-card accent">
                    <span>当前房间</span>
                    <strong><%= Server.HtmlEncode(SelectedRoom.Name) %></strong>
                    <small><%= Server.HtmlEncode(SelectedRoom.Theme) %> / 容纳 <%= SelectedRoom.Capacity %> 人</small>
                </article>
                <%-- 统计卡片：展示一个后台指标或运营数据。 --%>
                <article class="wallet-summary-card">
                    <span>开放场次</span>
                    <strong><%= SelectedRoom.UpcomingSessionCount %></strong>
                    <small>下面只展示这个房间的可约时间</small>
                </article>
                <%-- 统计卡片：展示一个后台指标或运营数据。 --%>
                <article class="wallet-summary-card">
                    <span>切换视图</span>
                    <strong><a class="text-link strong" href="Rooms.aspx#room-sessions">查看全部场次</a></strong>
                    <small>如果你想换房间，回到上面的房间卡片继续挑就行</small>
                </article>
            </div>
            <% } %>

            <div class="session-list">
                <%-- 数据列表控件 rptSessions：后台绑定集合数据后，按 ItemTemplate 循环渲染每条记录。 --%>
                <asp:Repeater ID="rptSessions" runat="server">
                    <%-- 列表项模板：定义 Repeater 中每一条业务记录的 HTML 结构和绑定字段。 --%>
                    <ItemTemplate>
                        <%-- 内容卡片：用于组织当前模块中的一组相关信息。 --%>
                        <article class="session-card wide">
                            <div>
                                <h3><%# Eval("ScriptName") %></h3>
                                <p><%# Eval("RoomName") %> / DM <%# Eval("HostName") %> / ¥<%# Eval("BasePrice", "{0:F0}") %> 每人</p>
                                <small><%# Eval("SessionDateTime", "{0:yyyy-MM-dd HH:mm}") %></small>
                            </div>
                            <div class="session-side">
                                <strong>已报 <%# Eval("ReservedPlayers") %> / <%# Eval("MaxPlayers") %></strong>
                                <a class="btn-secondary" href='Booking.aspx?sessionId=<%# Eval("Id") %>'>预约此场次</a>
                            </div>
                        </article>
                    </ItemTemplate>
                </asp:Repeater>

                <% if (!HasVisibleSessions) { %>
                <%-- 内容卡片：用于组织当前模块中的一组相关信息。 --%>
                <article class="session-card wide">
                    <div>
                        <h3>这个房间暂时没有开放预约</h3>
                        <p>可以先看看其他房间，或者稍后再回来刷新一次最新排期。</p>
                    </div>
                    <div class="session-side">
                        <a class="btn-secondary" href="Rooms.aspx">返回全部房间</a>
                    </div>
                </article>
                <% } %>
            </div>
        </div>
    </section>
</asp:Content>
