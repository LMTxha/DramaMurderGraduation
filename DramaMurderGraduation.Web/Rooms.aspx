<%@ Page Title="房间场次 | 剧本杀系统" Language="C#" MasterPageFile="~/Site.Master" AutoEventWireup="true" CodeBehind="Rooms.aspx.cs" Inherits="DramaMurderGraduation.Web.RoomsPage" %>
<asp:Content ID="Content1" ContentPlaceHolderID="TitleContent" runat="server">
    房间场次 | 剧本杀系统
</asp:Content>
<asp:Content ID="Content2" ContentPlaceHolderID="MainContent" runat="server">
    <section class="inner-hero">
        <div class="container">
            <p class="eyebrow">Rooms & Sessions</p>
            <h1>主题房间与近期排期</h1>
            <p>先看每个房间的氛围和配置，再一键跳到这个房间的可约场次，整个选场流程会顺很多。</p>
        </div>
    </section>

    <section class="section-block">
        <div class="container">
            <div class="section-heading">
                <h2>主题房间</h2>
                <p>房间卡片现在可以直接点开，帮你快速筛到对应房间的场次安排和最近可约入口。</p>
            </div>
            <div class="card-grid">
                <asp:Repeater ID="rptRooms" runat="server">
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

    <section class="section-block alt" id="room-sessions">
        <div class="container">
            <div class="section-heading">
                <h2><%= GetSessionHeading() %></h2>
                <p><%= GetSessionDescription() %></p>
            </div>

            <% if (SelectedRoom != null) { %>
            <div class="wallet-summary-grid booking-filter-grid room-filter-summary">
                <article class="wallet-summary-card accent">
                    <span>当前房间</span>
                    <strong><%= Server.HtmlEncode(SelectedRoom.Name) %></strong>
                    <small><%= Server.HtmlEncode(SelectedRoom.Theme) %> / 容纳 <%= SelectedRoom.Capacity %> 人</small>
                </article>
                <article class="wallet-summary-card">
                    <span>开放场次</span>
                    <strong><%= SelectedRoom.UpcomingSessionCount %></strong>
                    <small>下面只展示这个房间的可约时间</small>
                </article>
                <article class="wallet-summary-card">
                    <span>切换视图</span>
                    <strong><a class="text-link strong" href="Rooms.aspx#room-sessions">查看全部场次</a></strong>
                    <small>如果你想换房间，回到上面的房间卡片继续挑就行</small>
                </article>
            </div>
            <% } %>

            <div class="session-list">
                <asp:Repeater ID="rptSessions" runat="server">
                    <ItemTemplate>
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
