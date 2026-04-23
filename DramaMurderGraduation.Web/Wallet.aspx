<%@ Page Title="钱包中心 | 剧本杀系统" Language="C#" MasterPageFile="~/Site.Master" AutoEventWireup="true" CodeBehind="Wallet.aspx.cs" Inherits="DramaMurderGraduation.Web.WalletPage" %>
<asp:Content ID="Content1" ContentPlaceHolderID="TitleContent" runat="server">
    钱包中心 | 剧本杀系统
</asp:Content>
<asp:Content ID="Content2" ContentPlaceHolderID="MainContent" runat="server">
    <section class="inner-hero">
        <div class="container">
            <p class="eyebrow">Wallet Center</p>
            <h1>钱包与礼物币中心</h1>
            <p>现金余额用于预约扣费，礼物币用于互动送礼，两个账户都会在这里清楚展示。</p>
        </div>
    </section>

    <section class="section-block">
        <div class="container split-grid detail-split">
            <article class="form-panel">
                <div class="section-heading left">
                    <h2>现金余额</h2>
                    <p>微信和扫码支付会立即到账，银行卡支付仍需要管理员审核。</p>
                </div>

                <div class="wallet-summary-grid">
                    <a class="wallet-summary-card accent click-card interactive-card" href="Booking.aspx">
                        <span>当前余额</span>
                        <strong>￥<asp:Literal ID="litBalance" runat="server" /></strong>
                        <small>登录账号：<asp:Literal ID="litWalletUserName" runat="server" /></small>
                    </a>
                    <a class="wallet-summary-card click-card interactive-card" href="Friends.aspx#gift-panel">
                        <span>礼物币余额</span>
                        <strong><asp:Literal ID="litGiftBalance" runat="server" /></strong>
                        <small>1 元可兑换 10 礼物币</small>
                    </a>
                </div>

                <asp:Panel ID="pnlMessage" runat="server" Visible="false" CssClass="status-message">
                    <asp:Literal ID="litMessage" runat="server" />
                </asp:Panel>

                <div class="form-grid">
                    <div class="field-group">
                        <label for="<%= txtRechargeAmount.ClientID %>">充值金额</label>
                        <asp:TextBox ID="txtRechargeAmount" runat="server" CssClass="input-control" Text="200" />
                    </div>
                    <div class="field-group">
                        <label>快捷充值</label>
                        <div class="quick-amounts">
                            <asp:LinkButton ID="btnQuick100" runat="server" CssClass="btn-secondary small" OnClick="btnQuickAmount_Click" CommandArgument="100">￥100</asp:LinkButton>
                            <asp:LinkButton ID="btnQuick200" runat="server" CssClass="btn-secondary small" OnClick="btnQuickAmount_Click" CommandArgument="200">￥200</asp:LinkButton>
                            <asp:LinkButton ID="btnQuick500" runat="server" CssClass="btn-secondary small" OnClick="btnQuickAmount_Click" CommandArgument="500">￥500</asp:LinkButton>
                        </div>
                    </div>
                    <div class="field-group full">
                        <label for="<%= rblPaymentMethod.ClientID %>">支付方式</label>
                        <asp:RadioButtonList ID="rblPaymentMethod" runat="server" CssClass="payment-methods" RepeatDirection="Horizontal" AutoPostBack="true" OnSelectedIndexChanged="rblPaymentMethod_SelectedIndexChanged">
                            <asp:ListItem Value="WeChat" Selected="True">微信支付</asp:ListItem>
                            <asp:ListItem Value="BankCard">银行卡支付</asp:ListItem>
                            <asp:ListItem Value="ScanCode">扫码支付</asp:ListItem>
                        </asp:RadioButtonList>
                    </div>
                    <asp:Panel ID="pnlBankCard" runat="server" CssClass="field-group full" Visible="false">
                        <label for="<%= txtBankCardNumber.ClientID %>">银行卡号</label>
                        <asp:TextBox ID="txtBankCardNumber" runat="server" CssClass="input-control" placeholder="请输入 12 到 30 位银行卡号" />
                        <small class="field-note">银行卡充值会先提交到后台审核，通过后才会写入现金余额。</small>
                    </asp:Panel>
                    <div class="field-group full">
                        <label>支付说明</label>
                        <p class="inline-note"><asp:Literal ID="litPaymentTip" runat="server" /></p>
                    </div>
                </div>

                <asp:Button ID="btnRecharge" runat="server" Text="提交现金充值" CssClass="btn-primary wide-button" OnClick="btnRecharge_Click" />
            </article>

            <article class="form-panel" id="gift-wallet">
                <div class="section-heading left">
                    <h2>礼物币充值</h2>
                    <p>礼物币可以从余额兑换，用来给好友送礼、累积互动值和查看收礼记录。</p>
                </div>

                <asp:Panel ID="pnlGiftMessage" runat="server" Visible="false" CssClass="status-message">
                    <asp:Literal ID="litGiftMessage" runat="server" />
                </asp:Panel>

                <div class="form-grid">
                    <div class="field-group">
                        <label for="<%= txtGiftRechargeCoins.ClientID %>">兑换礼物币</label>
                        <asp:TextBox ID="txtGiftRechargeCoins" runat="server" CssClass="input-control" Text="100" />
                    </div>
                    <div class="field-group">
                        <label>快捷礼包</label>
                        <div class="quick-amounts">
                            <asp:LinkButton ID="btnGiftQuick100" runat="server" CssClass="btn-secondary small" OnClick="btnGiftQuickAmount_Click" CommandArgument="100">100 币</asp:LinkButton>
                            <asp:LinkButton ID="btnGiftQuick520" runat="server" CssClass="btn-secondary small" OnClick="btnGiftQuickAmount_Click" CommandArgument="520">520 币</asp:LinkButton>
                            <asp:LinkButton ID="btnGiftQuick1314" runat="server" CssClass="btn-secondary small" OnClick="btnGiftQuickAmount_Click" CommandArgument="1314">1314 币</asp:LinkButton>
                        </div>
                    </div>
                    <div class="field-group full">
                        <label>兑换说明</label>
                        <p class="inline-note">兑换时会自动扣除对应余额，并把记录同步到钱包流水和礼物明细里，方便你随时回看。</p>
                    </div>
                </div>

                <asp:Button ID="btnGiftRecharge" runat="server" Text="兑换礼物币" CssClass="btn-primary wide-button" OnClick="btnGiftRecharge_Click" />
            </article>
        </div>
    </section>

    <section class="section-block alt">
        <div class="container split-grid detail-split">
            <article>
                <div class="section-heading left">
                    <h2>最近现金充值申请</h2>
                    <p>银行卡支付会先停留在待审核状态，微信和扫码支付会立即到账。</p>
                </div>
                <div class="reservation-list">
                    <asp:Repeater ID="rptRechargeRequests" runat="server">
                        <ItemTemplate>
                            <article class="reservation-card">
                                <h3><%# TranslatePaymentMethod(Eval("PaymentMethod")) %> · ￥<%# Eval("Amount", "{0:F2}") %></h3>
                                <p>支付信息：<%# Eval("PaymentAccountMasked") %></p>
                                <p>状态：<%# TranslateRequestStatus(Eval("RequestStatus")) %></p>
                                <p><%# string.IsNullOrWhiteSpace(Convert.ToString(Eval("ReviewRemark"))) ? "等待系统处理或后台审核。" : Eval("ReviewRemark") %></p>
                                <small>提交时间：<%# Eval("SubmittedAt", "{0:yyyy-MM-dd HH:mm}") %></small>
                            </article>
                        </ItemTemplate>
                    </asp:Repeater>
                </div>
            </article>

            <article>
                <div class="section-heading left">
                    <h2>最近现金流水</h2>
                    <p>包括充值到账、预约扣费和兑换礼物币等现金变动记录。</p>
                </div>
                <div class="reservation-list">
                    <asp:Repeater ID="rptTransactions" runat="server">
                        <ItemTemplate>
                            <article class="reservation-card">
                                <h3><%# Eval("TransactionType") %> · ￥<%# Eval("Amount", "{0:F2}") %></h3>
                                <p><%# Eval("Summary") %></p>
                                <p>变动后余额：￥<%# Eval("BalanceAfter", "{0:F2}") %></p>
                                <small><%# Eval("CreatedAt", "{0:yyyy-MM-dd HH:mm}") %></small>
                            </article>
                        </ItemTemplate>
                    </asp:Repeater>
                </div>

                <div class="section-heading compact">
                    <h2>最近礼物币流水</h2>
                    <p>礼物币充值、送礼支出等记录都会出现在这里。</p>
                </div>
                <div class="reservation-list">
                    <asp:Repeater ID="rptGiftTransactions" runat="server">
                        <ItemTemplate>
                            <article class="reservation-card">
                                <h3><%# Eval("TransactionType") %> · <%# Eval("CoinAmount") %> 币</h3>
                                <p><%# Eval("Summary") %></p>
                                <p>变动后礼物币余额：<%# Eval("BalanceAfter") %></p>
                                <small><%# Eval("CreatedAt", "{0:yyyy-MM-dd HH:mm}") %></small>
                            </article>
                        </ItemTemplate>
                    </asp:Repeater>
                </div>
            </article>
        </div>
    </section>
</asp:Content>
