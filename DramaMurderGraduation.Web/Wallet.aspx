<%@ Page Title="钱包中心 | 剧本杀系统" Language="C#" MasterPageFile="~/Site.Master" AutoEventWireup="true" CodeBehind="Wallet.aspx.cs" Inherits="DramaMurderGraduation.Web.WalletPage" %>
<%-- 页面用途：Wallet 页面负责承载对应功能的 Web Forms 标记、服务端控件和前端布局。 --%>
<asp:Content ID="WalletTitle" ContentPlaceHolderID="TitleContent" runat="server">
    钱包中心 | 剧本杀系统
</asp:Content>
<asp:Content ID="WalletMain" ContentPlaceHolderID="MainContent" runat="server">
    <%-- 页面分区：把当前页面内容按业务模块拆分展示。 --%>
    <section class="inner-hero">
        <div class="container">
            <p class="eyebrow">Wallet Center</p>
            <h1>钱包与赠送金账户</h1>
            <p>现金余额用于预约和退款结算，赠送金账户用于礼物、互动激励和好友社交消费。</p>
        </div>
    </section>

    <%-- 主要内容区：承载当前页面的核心业务列表、表单或详情内容。 --%>
    <section class="section-block">
        <div class="container split-grid detail-split">
            <%-- 表单面板：承载筛选条件或业务提交输入项。 --%>
            <article class="form-panel">
                <%-- 模块标题区：说明当前业务模块的名称和处理说明。 --%>
                <div class="section-heading left">
                    <h2>现金充值</h2>
                    <p>快捷支付和扫码支付会立即到账，银行卡支付会进入后台审核，生成独立充值单号。</p>
                </div>

                <%-- 统计网格：集中展示多个关键业务指标。 --%>
                <div class="wallet-summary-grid">
                    <a class="wallet-summary-card accent click-card interactive-card" href="Booking.aspx">
                        <span>当前余额</span>
                        <strong>￥<asp:Literal ID="litBalance" runat="server" /></strong>
                        <small>当前账户：<asp:Literal ID="litWalletUserName" runat="server" /></small>
                    </a>
                    <a class="wallet-summary-card click-card interactive-card" href="Friends.aspx#gift-panel">
                        <span>赠送金余额</span>
                        <strong><asp:Literal ID="litGiftBalance" runat="server" /></strong>
                        <small>1 元可兑换 10 点赠送金</small>
                    </a>
                </div>

                <%-- 面板控件 pnlMessage：后台可通过 Visible/CssClass 控制整块内容是否显示以及提示样式。 --%>
                <asp:Panel ID="pnlMessage" runat="server" Visible="false" CssClass="status-message">
                    <asp:Literal ID="litMessage" runat="server" />
                </asp:Panel>

                <%-- 表单网格：按响应式布局排列输入框、下拉框和筛选条件。 --%>
                <div class="form-grid">
                    <div class="field-group">
                        <label for="<%= txtRechargeAmount.ClientID %>">充值金额</label>
                        <%-- 输入控件 txtRechargeAmount：接收用户输入或展示后台已有备注。 --%>
                        <asp:TextBox ID="txtRechargeAmount" runat="server" CssClass="input-control" Text="200" />
                    </div>
                    <div class="field-group">
                        <label>快捷金额</label>
                        <div class="quick-amounts">
                            <%-- 操作按钮 btnQuick100：点击后触发后台事件处理当前业务动作。 --%>
                            <asp:LinkButton ID="btnQuick100" runat="server" CssClass="btn-secondary small" OnClick="btnQuickAmount_Click" CommandArgument="100">￥100</asp:LinkButton>
                            <%-- 操作按钮 btnQuick200：点击后触发后台事件处理当前业务动作。 --%>
                            <asp:LinkButton ID="btnQuick200" runat="server" CssClass="btn-secondary small" OnClick="btnQuickAmount_Click" CommandArgument="200">￥200</asp:LinkButton>
                            <%-- 操作按钮 btnQuick500：点击后触发后台事件处理当前业务动作。 --%>
                            <asp:LinkButton ID="btnQuick500" runat="server" CssClass="btn-secondary small" OnClick="btnQuickAmount_Click" CommandArgument="500">￥500</asp:LinkButton>
                        </div>
                    </div>
                    <div class="field-group full">
                        <label for="<%= rblPaymentMethod.ClientID %>">支付方式</label>
                        <asp:RadioButtonList ID="rblPaymentMethod" runat="server" CssClass="payment-methods" RepeatDirection="Horizontal" AutoPostBack="true" OnSelectedIndexChanged="rblPaymentMethod_SelectedIndexChanged">
                            <asp:ListItem Value="WeChat" Selected="True">快捷支付</asp:ListItem>
                            <asp:ListItem Value="BankCard">银行卡支付</asp:ListItem>
                            <asp:ListItem Value="ScanCode">扫码支付</asp:ListItem>
                        </asp:RadioButtonList>
                    </div>
                    <%-- 面板控件 pnlBankCard：后台可通过 Visible/CssClass 控制整块内容是否显示以及提示样式。 --%>
                    <asp:Panel ID="pnlBankCard" runat="server" CssClass="field-group full" Visible="false">
                        <label for="<%= txtBankCardNumber.ClientID %>">银行卡号</label>
                        <%-- 输入控件 txtBankCardNumber：接收用户输入或展示后台已有备注。 --%>
                        <asp:TextBox ID="txtBankCardNumber" runat="server" CssClass="input-control" placeholder="请输入 12 到 30 位银行卡号" />
                        <small class="field-note">银行卡充值会先生成充值订单，管理员审核通过后才会到账。</small>
                    </asp:Panel>
                    <div class="field-group full">
                        <label>支付说明</label>
                        <p class="inline-note"><asp:Literal ID="litPaymentTip" runat="server" /></p>
                    </div>
                </div>

                <%-- 操作按钮 btnRecharge：点击后触发后台事件处理当前业务动作。 --%>
                <asp:Button ID="btnRecharge" runat="server" Text="提交现金充值" CssClass="btn-primary wide-button" OnClick="btnRecharge_Click" />
            </article>

            <%-- 表单面板：承载筛选条件或业务提交输入项。 --%>
            <article class="form-panel" id="gift-wallet">
                <%-- 模块标题区：说明当前业务模块的名称和处理说明。 --%>
                <div class="section-heading left">
                    <h2>赠送金兑换</h2>
                    <p>赠送金账户独立于现金余额，用于好友送礼、互动激励和答辩演示中的虚拟消费场景。</p>
                </div>

                <%-- 面板控件 pnlGiftMessage：后台可通过 Visible/CssClass 控制整块内容是否显示以及提示样式。 --%>
                <asp:Panel ID="pnlGiftMessage" runat="server" Visible="false" CssClass="status-message">
                    <asp:Literal ID="litGiftMessage" runat="server" />
                </asp:Panel>

                <%-- 表单网格：按响应式布局排列输入框、下拉框和筛选条件。 --%>
                <div class="form-grid">
                    <div class="field-group">
                        <label for="<%= txtGiftRechargeCoins.ClientID %>">兑换赠送金</label>
                        <%-- 输入控件 txtGiftRechargeCoins：接收用户输入或展示后台已有备注。 --%>
                        <asp:TextBox ID="txtGiftRechargeCoins" runat="server" CssClass="input-control" Text="100" />
                    </div>
                    <div class="field-group">
                        <label>快捷兑换</label>
                        <div class="quick-amounts">
                            <%-- 操作按钮 btnGiftQuick100：点击后触发后台事件处理当前业务动作。 --%>
                            <asp:LinkButton ID="btnGiftQuick100" runat="server" CssClass="btn-secondary small" OnClick="btnGiftQuickAmount_Click" CommandArgument="100">100 点</asp:LinkButton>
                            <%-- 操作按钮 btnGiftQuick520：点击后触发后台事件处理当前业务动作。 --%>
                            <asp:LinkButton ID="btnGiftQuick520" runat="server" CssClass="btn-secondary small" OnClick="btnGiftQuickAmount_Click" CommandArgument="520">520 点</asp:LinkButton>
                            <%-- 操作按钮 btnGiftQuick1314：点击后触发后台事件处理当前业务动作。 --%>
                            <asp:LinkButton ID="btnGiftQuick1314" runat="server" CssClass="btn-secondary small" OnClick="btnGiftQuickAmount_Click" CommandArgument="1314">1314 点</asp:LinkButton>
                        </div>
                    </div>
                    <div class="field-group full">
                        <label>兑换说明</label>
                        <p class="inline-note">兑换时会同步记录现金流水和赠送金流水，便于后台做财务审计和异常对账。</p>
                    </div>
                </div>

                <%-- 操作按钮 btnGiftRecharge：点击后触发后台事件处理当前业务动作。 --%>
                <asp:Button ID="btnGiftRecharge" runat="server" Text="兑换赠送金" CssClass="btn-primary wide-button" OnClick="btnGiftRecharge_Click" />
            </article>
        </div>
    </section>

    <%-- 次级内容区：用于承载筛选、配置、辅助列表或补充信息。 --%>
    <section class="section-block alt">
        <div class="container split-grid detail-split">
            <%-- 内容卡片：用于组织当前模块中的一组相关信息。 --%>
            <article>
                <%-- 模块标题区：说明当前业务模块的名称和处理说明。 --%>
                <div class="section-heading left">
                    <h2>最近充值订单</h2>
                    <p>所有充值都会生成订单号，便于后台审核、导出报表和后续对账。</p>
                </div>
                <%-- 列表容器：承载 Repeater 渲染出的多条业务卡片。 --%>
                <div class="reservation-list">
                    <%-- 数据列表控件 rptRechargeRequests：后台绑定集合数据后，按 ItemTemplate 循环渲染每条记录。 --%>
                    <asp:Repeater ID="rptRechargeRequests" runat="server">
                        <%-- 列表项模板：定义 Repeater 中每一条业务记录的 HTML 结构和绑定字段。 --%>
                        <ItemTemplate>
                            <%-- 业务卡片：展示一条预约、审核、消息或统计记录。 --%>
                            <article class="reservation-card">
                                <h3><%# TranslatePaymentMethod(Eval("PaymentMethod")) %> / ￥<%# Eval("Amount", "{0:F2}") %></h3>
                                <p>充值单号：<%# Eval("RechargeOrderNo") %></p>
                                <p>支付信息：<%# Eval("PaymentAccountMasked") %></p>
                                <p>状态：<%# TranslateRequestStatus(Eval("RequestStatus")) %></p>
                                <p><%# string.IsNullOrWhiteSpace(Convert.ToString(Eval("ReviewRemark"))) ? "等待系统处理或后台审核。" : Eval("ReviewRemark") %></p>
                                <small>提交时间：<%# Eval("SubmittedAt", "{0:yyyy-MM-dd HH:mm}") %></small>
                            </article>
                        </ItemTemplate>
                    </asp:Repeater>
                </div>
            </article>

            <%-- 内容卡片：用于组织当前模块中的一组相关信息。 --%>
            <article>
                <%-- 模块标题区：说明当前业务模块的名称和处理说明。 --%>
                <div class="section-heading left">
                    <h2>最近现金流水</h2>
                    <p>包括充值到账、预约扣费、退款和赠送金兑换等现金资金变化。</p>
                </div>
                <%-- 列表容器：承载 Repeater 渲染出的多条业务卡片。 --%>
                <div class="reservation-list">
                    <%-- 数据列表控件 rptTransactions：后台绑定集合数据后，按 ItemTemplate 循环渲染每条记录。 --%>
                    <asp:Repeater ID="rptTransactions" runat="server">
                        <%-- 列表项模板：定义 Repeater 中每一条业务记录的 HTML 结构和绑定字段。 --%>
                        <ItemTemplate>
                            <%-- 业务卡片：展示一条预约、审核、消息或统计记录。 --%>
                            <article class="reservation-card">
                                <h3><%# Eval("TransactionType") %> / ￥<%# Eval("Amount", "{0:F2}") %></h3>
                                <p><%# Eval("Summary") %></p>
                                <p>变动后余额：￥<%# Eval("BalanceAfter", "{0:F2}") %></p>
                                <small><%# Eval("CreatedAt", "{0:yyyy-MM-dd HH:mm}") %></small>
                            </article>
                        </ItemTemplate>
                    </asp:Repeater>
                </div>

                <%-- 模块标题区：说明当前业务模块的名称和处理说明。 --%>
                <div class="section-heading compact">
                    <h2>最近赠送金流水</h2>
                    <p>记录赠送金充值、送礼支出和收到礼物后的余额变化。</p>
                </div>
                <%-- 列表容器：承载 Repeater 渲染出的多条业务卡片。 --%>
                <div class="reservation-list">
                    <%-- 数据列表控件 rptGiftTransactions：后台绑定集合数据后，按 ItemTemplate 循环渲染每条记录。 --%>
                    <asp:Repeater ID="rptGiftTransactions" runat="server">
                        <%-- 列表项模板：定义 Repeater 中每一条业务记录的 HTML 结构和绑定字段。 --%>
                        <ItemTemplate>
                            <%-- 业务卡片：展示一条预约、审核、消息或统计记录。 --%>
                            <article class="reservation-card">
                                <h3><%# Eval("TransactionType") %> / <%# Eval("CoinAmount") %> 点</h3>
                                <p><%# Eval("Summary") %></p>
                                <p>变动后赠送金余额：<%# Eval("BalanceAfter") %></p>
                                <small><%# Eval("CreatedAt", "{0:yyyy-MM-dd HH:mm}") %></small>
                            </article>
                        </ItemTemplate>
                    </asp:Repeater>
                </div>
            </article>
        </div>
    </section>
</asp:Content>
