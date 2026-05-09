<%@ Page Title="剧本占用情况 | 剧本杀系统" Language="C#" MasterPageFile="~/Site.Master" AutoEventWireup="true" CodeBehind="AdminScriptOccupancy.aspx.cs" Inherits="DramaMurderGraduation.Web.AdminScriptOccupancyPage" MaintainScrollPositionOnPostback="true" %>
<%-- 剧本占用管理页：用于查看剧本在不同场次和房间中的排期占用情况。 --%>

<asp:Content ID="Content1" ContentPlaceHolderID="TitleContent" runat="server">
    剧本占用情况 | 剧本杀系统
</asp:Content>

<asp:Content ID="Content2" ContentPlaceHolderID="MainContent" runat="server">
    <section class="inner-hero">
        <div class="container">
            <p class="eyebrow">Script Occupancy</p>
            <h1><asp:Literal ID="litPageHeading" runat="server" /></h1>
            <p><asp:Literal ID="litPageSubtitle" runat="server" /></p>
        </div>
    </section>

    <div class="container">
        <asp:Panel ID="pnlMessage" runat="server" Visible="false" CssClass="status-message">
            <asp:Literal ID="litMessage" runat="server" />
        </asp:Panel>
    </div>

    <asp:Panel ID="pnlScriptList" runat="server">
        <section class="section-block">
            <div class="container">
            <div class="filter-bar">
                <div class="field-group">
                    <label for="<%= txtKeyword.ClientID %>">关键词</label>
                    <asp:TextBox ID="txtKeyword" runat="server" CssClass="input-control" placeholder="输入剧本名或卖点" />
                </div>
                <div class="field-group action">
                    <asp:Button ID="btnSearch" runat="server" Text="查询剧本" CssClass="btn-primary" OnClick="btnSearch_Click" />
                </div>
            </div>

            <div class="section-heading left compact">
                <h2>剧本库占用总览</h2>
                <p>共 <asp:Literal ID="litScriptCount" runat="server" /> 个剧本，点击卡片查看该剧本的占用明细。</p>
            </div>

            <div class="card-grid occupancy-script-grid">
                <asp:Repeater ID="rptScripts" runat="server">
                    <ItemTemplate>
                        <article class='script-card large occupancy-script-card <%# Eval("SelectedCssClass") %>'>
                            <a class="occupancy-card-link" href='AdminScriptOccupancy.aspx?scriptId=<%# Eval("Id") %>'>
                                <img src='<%# Eval("CoverImage") %>' alt='<%# Eval("Name") %>' />
                                <div class="card-body">
                                    <div class="card-meta">
                                        <span><%# Eval("GenreName") %></span>
                                        <span><%# Eval("Difficulty") %></span>
                                        <span><%# Eval("AvailabilityLabel") %></span>
                                    </div>
                                    <h3><%# Eval("Name") %></h3>
                                    <p><%# Eval("Slogan") %></p>
                                    <div class="card-stats">
                                        <span>查看订单 <%# Eval("ActiveReservationCount") %></span>
                                        <span>查看人数 <%# Eval("OccupiedPlayerCount") %></span>
                                        <span>查看场地 <%# Eval("OccupiedRoomCount") %></span>
                                        <span>未来排期 <%# Eval("FutureSessionCount") %></span>
                                    </div>
                                </div>
                            </a>
                        </article>
                    </ItemTemplate>
                </asp:Repeater>
            </div>
        </div>
        </section>
    </asp:Panel>

    <asp:Panel ID="pnlScriptDetail" runat="server">
        <section class="section-block" id="occupancy-detail">
            <div class="container">
            <div class="section-heading left compact">
                <h2><asp:Literal ID="litSelectedScriptName" runat="server" /></h2>
                <p><asp:Literal ID="litSelectedSummary" runat="server" /></p>
            </div>
            <div class="hero-actions">
                <asp:HyperLink ID="lnkBackToOccupancyList" runat="server" CssClass="btn-secondary" NavigateUrl="AdminScriptOccupancy.aspx" Text="返回剧本占用列表" />
                <asp:HyperLink ID="lnkBackAdminReview" runat="server" CssClass="btn-secondary" NavigateUrl="AdminReview.aspx" Text="返回后台审核" />
            </div>

            <div class="wallet-summary-grid occupancy-detail-summary">
                <article class="wallet-summary-card">
                    <span>真实占用订单</span>
                    <strong><asp:Literal ID="litSelectedOrderCount" runat="server" /></strong>
                    <small>当前仍占用该剧本名额的预约订单</small>
                </article>
                <article class="wallet-summary-card accent">
                    <span>真实占用人数</span>
                    <strong><asp:Literal ID="litSelectedPlayerCount" runat="server" /></strong>
                    <small>按每笔预约的玩家人数累加</small>
                </article>
                <article class="wallet-summary-card">
                    <span>真实占用场地</span>
                    <strong><asp:Literal ID="litSelectedRoomCount" runat="server" /></strong>
                    <small><asp:Literal ID="litSelectedRoomNames" runat="server" /></small>
                </article>
                <article class="wallet-summary-card">
                    <span>未来开放排期</span>
                    <strong><asp:Literal ID="litSelectedFutureSessionCount" runat="server" /></strong>
                    <small>玩家预约页只展示未来且开放预约的场次</small>
                </article>
            </div>

            <asp:Panel ID="pnlEmptyDetail" runat="server" Visible="false" CssClass="status-message">
                当前剧本暂无有效占用记录。
            </asp:Panel>

            <div class="reservation-list">
                <asp:Repeater ID="rptReservations" runat="server" OnItemCommand="rptReservations_ItemCommand">
                    <ItemTemplate>
                        <article class="reservation-card occupancy-reservation-card">
                            <span class="badge-inline"><%# Eval("Status") %></span>
                            <h3>订单 #<%# Eval("Id") %> · <%# Eval("ContactName") %></h3>
                            <p>房间场地：<%# Eval("RoomName") %> · 主持：<%# Eval("HostName") %></p>
                            <p>开场时间：<%# Eval("SessionDateTime", "{0:yyyy-MM-dd HH:mm}") %> · 占用名额：<%# Eval("PlayerCount") %> · 支付：<%# Eval("PaymentStatus") %></p>
                            <p>手机：<%# Eval("PhoneMasked") %> · 核销码：<%# Eval("CheckInCode") %></p>
                            <div class="hero-actions">
                                <asp:Button ID="btnCancelOccupancy" runat="server" Text="取消占用并释放名额" CssClass="btn-secondary small" CommandName="CancelOccupancy" CommandArgument='<%# Eval("Id") %>' CausesValidation="false" OnClientClick="return confirm('确认由管理员取消这笔占用吗？取消后会释放玩家名额和房间席位。');" />
                                <asp:HyperLink runat="server" CssClass="btn-secondary small" NavigateUrl='<%# "OrderDetails.aspx?reservationId=" + Eval("Id") %>' Text="订单详情" />
                                <asp:HyperLink runat="server" CssClass="btn-secondary small" NavigateUrl='<%# "OrderConversation.aspx?reservationId=" + Eval("Id") %>' Text="订单沟通" />
                            </div>
                        </article>
                    </ItemTemplate>
                </asp:Repeater>
            </div>
        </div>
        </section>
    </asp:Panel>
</asp:Content>
