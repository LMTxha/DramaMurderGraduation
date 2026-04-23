<%@ Page Title="在线预约 | 剧本杀系统" Language="C#" MasterPageFile="~/Site.Master" AutoEventWireup="true" CodeBehind="Booking.aspx.cs" Inherits="DramaMurderGraduation.Web.BookingPage" %>
<asp:Content ID="Content1" ContentPlaceHolderID="TitleContent" runat="server">
    在线预约 | 剧本杀系统
</asp:Content>
<asp:Content ID="Content2" ContentPlaceHolderID="MainContent" runat="server">
    <section class="inner-hero">
        <div class="container">
            <p class="eyebrow">Reservation Form</p>
            <h1>在线预约场次</h1>
            <p><asp:Literal ID="litBookingIntro" runat="server" /></p>
        </div>
    </section>

    <section class="section-block">
        <div class="container split-grid detail-split">
            <article class="form-panel">
                <div class="section-heading left">
                    <h2>填写预约信息</h2>
                    <p>预约成功后，系统会自动从账户余额扣除费用，并写入预约记录和钱包流水。</p>
                </div>

                <asp:PlaceHolder ID="phScriptFilter" runat="server" Visible="false">
                    <div class="wallet-summary-grid booking-filter-grid">
                        <article class="wallet-summary-card">
                            <span>当前筛选剧本</span>
                            <strong><asp:Literal ID="litCurrentScriptName" runat="server" /></strong>
                            <small>当前页面只显示这个剧本的可预约场次</small>
                        </article>
                    </div>
                </asp:PlaceHolder>

                <div class="wallet-summary-grid">
                    <article class="wallet-summary-card accent">
                        <span>当前余额</span>
                        <strong>￥<asp:Literal ID="litWalletBalance" runat="server" /></strong>
                        <a class="text-link light" href="Wallet.aspx">去充值</a>
                    </article>
                    <article class="wallet-summary-card">
                        <span>所选场次</span>
                        <strong><asp:Literal ID="litSelectedSession" runat="server" /></strong>
                        <small>剩余 <asp:Literal ID="litRemainingSeats" runat="server" /> 位 · 单价 ￥<asp:Literal ID="litUnitPrice" runat="server" /></small>
                    </article>
                    <article class="wallet-summary-card">
                        <span>预计支付</span>
                        <strong>￥<asp:Literal ID="litEstimatedAmount" runat="server" /></strong>
                        <small>按当前预约人数自动计算</small>
                    </article>
                </div>

                <asp:Panel ID="pnlMessage" runat="server" Visible="false" CssClass="status-message">
                    <asp:Literal ID="litMessage" runat="server" />
                </asp:Panel>

                <div class="form-grid">
                    <div class="field-group">
                        <label for="<%= ddlSessions.ClientID %>">选择场次</label>
                        <asp:DropDownList ID="ddlSessions" runat="server" CssClass="input-control" AutoPostBack="true" OnSelectedIndexChanged="ddlSessions_SelectedIndexChanged" />
                    </div>
                    <div class="field-group">
                        <label for="<%= txtContactName.ClientID %>">联系人</label>
                        <asp:TextBox ID="txtContactName" runat="server" CssClass="input-control" placeholder="请输入联系人姓名" />
                    </div>
                    <div class="field-group">
                        <label for="<%= txtPhone.ClientID %>">联系电话</label>
                        <asp:TextBox ID="txtPhone" runat="server" CssClass="input-control" placeholder="请输入手机号" />
                    </div>
                    <div class="field-group">
                        <label for="<%= txtPlayerCount.ClientID %>">预约人数</label>
                        <asp:TextBox ID="txtPlayerCount" runat="server" CssClass="input-control" Text="1" AutoPostBack="true" OnTextChanged="txtPlayerCount_TextChanged" />
                    </div>
                    <div class="field-group full">
                        <label for="<%= txtRemark.ClientID %>">备注</label>
                        <asp:TextBox ID="txtRemark" runat="server" CssClass="input-control textarea" TextMode="MultiLine" Rows="4" placeholder="例如：新手局、团建局、希望安排同一房间等" />
                    </div>
                </div>

                <asp:Button ID="btnSubmit" runat="server" Text="提交预约" CssClass="btn-primary wide-button" OnClick="btnSubmit_Click" />
            </article>

            <article>
                <div class="section-heading left">
                    <h2>最近预约</h2>
                    <p>为保护隐私，页面只显示处理后的联系方式和必要的预约信息。</p>
                </div>
                <div class="reservation-list">
                    <asp:Repeater ID="rptRecentReservations" runat="server">
                        <ItemTemplate>
                            <article class="reservation-card">
                                <h3><%# Eval("ContactName") %> · <%# Eval("PlayerCount") %> 人</h3>
                                <p><%# Eval("ScriptName") %> / <%# Eval("RoomName") %></p>
                                <p><%# Eval("PhoneMasked") %> · <%# Eval("Status") %></p>
                                <p>支付 <%# Eval("PaymentStatus") %> · ￥<%# Eval("TotalAmount", "{0:F2}") %></p>
                                <small><%# Eval("SessionDateTime", "{0:yyyy-MM-dd HH:mm}") %></small>
                            </article>
                        </ItemTemplate>
                    </asp:Repeater>
                </div>
            </article>
        </div>
    </section>
</asp:Content>

