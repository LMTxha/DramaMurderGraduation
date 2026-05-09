<%@ Page Title="在线预约 | 剧本杀系统" Language="C#" MasterPageFile="~/Site.Master" AutoEventWireup="true" CodeBehind="Booking.aspx.cs" Inherits="DramaMurderGraduation.Web.BookingPage" %>
<%-- 页面用途：Booking 页面负责承载对应功能的 Web Forms 标记、服务端控件和前端布局。 --%>
<asp:Content ID="Content1" ContentPlaceHolderID="TitleContent" runat="server">
    在线预约 | 剧本杀系统
</asp:Content>
<asp:Content ID="Content2" ContentPlaceHolderID="MainContent" runat="server">
    <%-- 页面分区：把当前页面内容按业务模块拆分展示。 --%>
    <section class="inner-hero">
        <div class="container">
            <p class="eyebrow">Reservation Form</p>
            <h1>在线预约场次</h1>
            <p><asp:Literal ID="litBookingIntro" runat="server" /></p>
        </div>
    </section>

    <%-- 主要内容区：承载当前页面的核心业务列表、表单或详情内容。 --%>
    <section class="section-block">
        <div class="container split-grid detail-split">
            <%-- 表单面板：承载筛选条件或业务提交输入项。 --%>
            <article class="form-panel">
                <%-- 模块标题区：说明当前业务模块的名称和处理说明。 --%>
                <div class="section-heading left">
                    <h2>填写预约信息</h2>
                    <p>预约成功后，系统会自动从账户余额扣除费用，并写入预约记录和钱包流水。</p>
                </div>

                <asp:PlaceHolder ID="phScriptFilter" runat="server" Visible="false">
                    <%-- 统计网格：集中展示多个关键业务指标。 --%>
                    <div class="wallet-summary-grid booking-filter-grid">
                        <%-- 统计卡片：展示一个后台指标或运营数据。 --%>
                        <article class="wallet-summary-card">
                            <span>当前筛选剧本</span>
                            <strong><asp:Literal ID="litCurrentScriptName" runat="server" /></strong>
                            <small>当前页面只显示这个剧本的可预约场次</small>
                        </article>
                    </div>
                </asp:PlaceHolder>

                <%-- 统计网格：集中展示多个关键业务指标。 --%>
                <div class="wallet-summary-grid">
                    <%-- 统计卡片：展示一个后台指标或运营数据。 --%>
                    <article class="wallet-summary-card accent">
                        <span>当前余额</span>
                        <strong>￥<asp:Literal ID="litWalletBalance" runat="server" /></strong>
                        <a class="text-link light" href="Wallet.aspx">去充值</a>
                    </article>
                    <%-- 统计卡片：展示一个后台指标或运营数据。 --%>
                    <article class="wallet-summary-card">
                        <span>所选场次</span>
                        <strong><asp:Literal ID="litSelectedSession" runat="server" /></strong>
                        <small>剩余 <asp:Literal ID="litRemainingSeats" runat="server" /> 位 · 单价 ￥<asp:Literal ID="litUnitPrice" runat="server" /></small>
                    </article>
                    <%-- 统计卡片：展示一个后台指标或运营数据。 --%>
                    <article class="wallet-summary-card">
                        <span>预计支付</span>
                        <strong>￥<asp:Literal ID="litEstimatedAmount" runat="server" /></strong>
                        <small>已扣除可用优惠券</small>
                    </article>
                    <%-- 统计卡片：展示一个后台指标或运营数据。 --%>
                    <article class="wallet-summary-card">
                        <span>优惠抵扣</span>
                        <strong>-￥<asp:Literal ID="litCouponDiscount" runat="server" /></strong>
                        <small>管理员发放后可在下方选择</small>
                    </article>
                </div>

                <%-- 面板控件 pnlMessage：后台可通过 Visible/CssClass 控制整块内容是否显示以及提示样式。 --%>
                <asp:Panel ID="pnlMessage" runat="server" Visible="false" CssClass="status-message">
                    <asp:Literal ID="litMessage" runat="server" />
                </asp:Panel>

                <%-- 表单网格：按响应式布局排列输入框、下拉框和筛选条件。 --%>
                <div class="form-grid">
                    <div class="field-group">
                        <label for="<%= ddlSessions.ClientID %>">选择房间场次</label>
                        <%-- 下拉控件 ddlSessions：提供状态、分类或角色等固定选项。 --%>
                        <asp:DropDownList ID="ddlSessions" runat="server" CssClass="input-control" AutoPostBack="true" OnSelectedIndexChanged="ddlSessions_SelectedIndexChanged" />
                    </div>
                    <div class="field-group">
                        <label for="<%= txtContactName.ClientID %>">联系人</label>
                        <%-- 输入控件 txtContactName：接收用户输入或展示后台已有备注。 --%>
                        <asp:TextBox ID="txtContactName" runat="server" CssClass="input-control" placeholder="请输入联系人姓名" />
                    </div>
                    <div class="field-group">
                        <label for="<%= txtPhone.ClientID %>">联系电话</label>
                        <%-- 输入控件 txtPhone：接收用户输入或展示后台已有备注。 --%>
                        <asp:TextBox ID="txtPhone" runat="server" CssClass="input-control" placeholder="请输入手机号" />
                    </div>
                    <div class="field-group">
                        <label for="<%= txtPlayerCount.ClientID %>">预约人数</label>
                        <%-- 输入控件 txtPlayerCount：接收用户输入或展示后台已有备注。 --%>
                        <asp:TextBox ID="txtPlayerCount" runat="server" CssClass="input-control" Text="1" AutoPostBack="true" OnTextChanged="txtPlayerCount_TextChanged" />
                    </div>
                    <div class="field-group full">
                        <label for="<%= ddlCoupons.ClientID %>">预约优惠券</label>
                        <%-- 下拉控件 ddlCoupons：提供状态、分类或角色等固定选项。 --%>
                        <asp:DropDownList ID="ddlCoupons" runat="server" CssClass="input-control" AutoPostBack="true" OnSelectedIndexChanged="ddlCoupons_SelectedIndexChanged" />
                        <small class="form-hint">只显示当前订单金额可用、未过期、未使用的优惠券。</small>
                    </div>
                    <div class="field-group full">
                        <%-- 操作按钮 btnSubmit：点击后触发后台事件处理当前业务动作。 --%>
                        <asp:Button ID="btnSubmit" runat="server" Text="提交预约" CssClass="btn-primary wide-button" OnClick="btnSubmit_Click" />
                    </div>
                    <div class="field-group full">
                        <label for="<%= txtRemark.ClientID %>">备注</label>
                        <%-- 输入控件 txtRemark：接收用户输入或展示后台已有备注。 --%>
                        <asp:TextBox ID="txtRemark" runat="server" CssClass="input-control textarea" TextMode="MultiLine" Rows="4" placeholder="例如：新手局、团建局、希望安排同一房间等" />
                    </div>
                </div>

                <%-- 模块标题区：说明当前业务模块的名称和处理说明。 --%>
                <div class="section-heading left top-gap">
                    <h2>满员候补</h2>
                    <p>如果想约的场次已经满员，可以先加入候补队列，腾出名额后通知中心会提醒你回来抢位。</p>
                </div>
                <%-- 表单网格：按响应式布局排列输入框、下拉框和筛选条件。 --%>
                <div class="form-grid">
                    <div class="field-group full">
                        <label for="<%= ddlWaitlistSessions.ClientID %>">候补场次</label>
                        <%-- 下拉控件 ddlWaitlistSessions：提供状态、分类或角色等固定选项。 --%>
                        <asp:DropDownList ID="ddlWaitlistSessions" runat="server" CssClass="input-control" />
                    </div>
                </div>
                <%-- 操作按钮 btnJoinWaitlist：点击后触发后台事件处理当前业务动作。 --%>
                <asp:Button ID="btnJoinWaitlist" runat="server" Text="加入候补队列" CssClass="btn-secondary wide-button" OnClick="btnJoinWaitlist_Click" />
            </article>

            <%-- 内容卡片：用于组织当前模块中的一组相关信息。 --%>
            <article>
                <%-- 模块标题区：说明当前业务模块的名称和处理说明。 --%>
                <div class="section-heading left">
                    <h2>最近预约</h2>
                    <p>为保护隐私，页面只显示处理后的联系方式和必要的预约信息。</p>
                </div>
                <%-- 列表容器：承载 Repeater 渲染出的多条业务卡片。 --%>
                <div class="reservation-list">
                    <%-- 数据列表控件 rptRecentReservations：后台绑定集合数据后，按 ItemTemplate 循环渲染每条记录。 --%>
                    <asp:Repeater ID="rptRecentReservations" runat="server">
                        <%-- 列表项模板：定义 Repeater 中每一条业务记录的 HTML 结构和绑定字段。 --%>
                        <ItemTemplate>
                            <%-- 业务卡片：展示一条预约、审核、消息或统计记录。 --%>
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

                <%-- 模块标题区：说明当前业务模块的名称和处理说明。 --%>
                <div class="section-heading left top-gap">
                    <h2>我的候补队列</h2>
                    <p>这里会显示你排队中的满员场次，腾出名额后会提示“可立即预约”。</p>
                </div>
                <%-- 列表容器：承载 Repeater 渲染出的多条业务卡片。 --%>
                <div class="reservation-list">
                    <%-- 数据列表控件 rptMyWaitlists：后台绑定集合数据后，按 ItemTemplate 循环渲染每条记录。 --%>
                    <asp:Repeater ID="rptMyWaitlists" runat="server">
                        <%-- 列表项模板：定义 Repeater 中每一条业务记录的 HTML 结构和绑定字段。 --%>
                        <ItemTemplate>
                            <%-- 业务卡片：展示一条预约、审核、消息或统计记录。 --%>
                            <article class='reservation-card <%# Convert.ToBoolean(Eval("CanBookNow")) ? "waitlist-open-card" : string.Empty %>'>
                                <h3><%# Eval("ScriptName") %> · <%# Eval("PlayerCount") %> 人候补</h3>
                                <p><%# Eval("RoomName") %> / DM：<%# Eval("HostName") %></p>
                                <p>状态：<%# Eval("Status") %> · 剩余名额 <%# Eval("RemainingSeats") %></p>
                                <p><%# string.IsNullOrWhiteSpace(Convert.ToString(Eval("Note"))) ? "未填写候补备注" : Eval("Note") %></p>
                                <%-- 操作按钮区：集中放置提交、重置、跳转或审核动作。 --%>
                                <div class="hero-actions top-gap">
                                    <a class='btn-primary small <%# Convert.ToBoolean(Eval("CanBookNow")) ? string.Empty : "disabled-link" %>' href='Booking.aspx?sessionId=<%# Eval("SessionId") %>'>返回预约</a>
                                    <span class='badge-inline <%# Convert.ToBoolean(Eval("CanBookNow")) ? "success" : "soft" %>'><%# Convert.ToBoolean(Eval("CanBookNow")) ? "可立即预约" : "等待补位" %></span>
                                </div>
                                <small><%# Eval("SessionDateTime", "{0:yyyy-MM-dd HH:mm}") %> / 提交于 <%# Eval("CreatedAt", "{0:yyyy-MM-dd HH:mm}") %></small>
                            </article>
                        </ItemTemplate>
                    </asp:Repeater>
                </div>

                <%-- 模块标题区：说明当前业务模块的名称和处理说明。 --%>
                <div class="section-heading left top-gap" id="after-sale-center">
                    <h2>我的预约与售后</h2>
                    <p>门店确认、到店核销、改期和退款申请都会在这里形成记录。</p>
                </div>
                <%-- 列表容器：承载 Repeater 渲染出的多条业务卡片。 --%>
                <div class="reservation-list">
                    <%-- 数据列表控件 rptMyReservations：后台绑定集合数据后，按 ItemTemplate 循环渲染每条记录。 --%>
                    <asp:Repeater ID="rptMyReservations" runat="server" OnItemCommand="rptMyReservations_ItemCommand">
                        <%-- 列表项模板：定义 Repeater 中每一条业务记录的 HTML 结构和绑定字段。 --%>
                        <ItemTemplate>
                            <%-- 业务卡片：展示一条预约、审核、消息或统计记录。 --%>
                            <article class="reservation-card booking-service-card">
                                <h3><%# Eval("ScriptName") %> · <%# Eval("PlayerCount") %> 人</h3>
                                <p><%# Eval("RoomName") %> / 房间号：ROOM-<%# Eval("SessionId", "{0:D4}") %> / DM：<%# Eval("HostName") %></p>
                                <p>订单：<%# Eval("Status") %> · 支付：<%# Eval("PaymentStatus") %> · ￥<%# Eval("TotalAmount", "{0:F2}") %></p>
                                <p><%# Convert.ToDecimal(Eval("DiscountAmount")) > 0 ? "优惠：" + Eval("CouponTitle") + " · 已抵扣 ￥" + Eval("DiscountAmount", "{0:F2}") : "未使用优惠券" %></p>
                                <p>门店回复：<%# string.IsNullOrWhiteSpace(Convert.ToString(Eval("AdminReply"))) ? "暂未回复" : Eval("AdminReply") %></p>
                                <small><%# Eval("SessionDateTime", "{0:yyyy-MM-dd HH:mm}") %></small>
                                <%# RenderAfterSaleSummary(Eval("LatestAfterSaleType"), Eval("LatestAfterSaleStatus"), Eval("LatestAfterSaleCreatedAt")) %>
                                <div class="card-actions">
                                    <a class="btn-primary small" href='GameRoom.aspx?reservationId=<%# Eval("Id") %>'>进入游戏房间</a>
                                    <a class="btn-secondary small" href='GameLobby.aspx?reservationId=<%# Eval("Id") %>'>进入候场大厅</a>
                                    <a class="btn-secondary small" href='OrderDetails.aspx?reservationId=<%# Eval("Id") %>'>查看订单详情</a>
                                    <asp:LinkButton ID="btnLeaveReservation" runat="server" CssClass="btn-secondary small danger-button" CommandName="LeaveReservation" CommandArgument='<%# Eval("Id") %>' Visible='<%# CanLeaveReservation(Container.DataItem) %>' OnClientClick="return confirm('确认退出这个游戏房间吗？退出后会取消该预约并立即释放本场名额。');">退出游戏</asp:LinkButton>
                                </div>
                                <div class="booking-service-form">
                                    <%-- 下拉控件 ddlAfterSaleType：提供状态、分类或角色等固定选项。 --%>
                                    <asp:DropDownList ID="ddlAfterSaleType" runat="server" CssClass="input-control compact-input">
                                        <asp:ListItem Value="退款申请">退款申请</asp:ListItem>
                                        <asp:ListItem Value="改期协商">改期协商</asp:ListItem>
                                        <asp:ListItem Value="体验投诉">体验投诉</asp:ListItem>
                                        <asp:ListItem Value="其他售后">其他售后</asp:ListItem>
                                    </asp:DropDownList>
                                    <%-- 输入控件 txtAfterSaleAmount：接收用户输入或展示后台已有备注。 --%>
                                    <asp:TextBox ID="txtAfterSaleAmount" runat="server" CssClass="input-control compact-input" placeholder="退款金额，可不填" />
                                    <%-- 输入控件 txtAfterSaleReason：接收用户输入或展示后台已有备注。 --%>
                                    <asp:TextBox ID="txtAfterSaleReason" runat="server" CssClass="input-control textarea" TextMode="MultiLine" Rows="2" placeholder="说明售后原因、希望改期时间或退款说明" />
                                    <asp:FileUpload ID="fuAfterSaleEvidence" runat="server" CssClass="input-control compact-input" />
                                    <%-- 操作按钮 btnCreateAfterSale：点击后触发后台事件处理当前业务动作。 --%>
                                    <asp:Button ID="btnCreateAfterSale" runat="server" Text="提交售后" CssClass="btn-secondary" CommandName="CreateAfterSale" CommandArgument='<%# Eval("Id") %>' />
                                </div>
                            </article>
                        </ItemTemplate>
                    </asp:Repeater>
                </div>

                <%-- 模块标题区：说明当前业务模块的名称和处理说明。 --%>
                <div class="section-heading left top-gap">
                    <h2>我的售后处理进度</h2>
                    <p>这里集中展示售后凭证、状态时间线、驳回原因和二次申诉入口。</p>
                </div>
                <%-- 列表容器：承载 Repeater 渲染出的多条业务卡片。 --%>
                <div class="reservation-list">
                    <%-- 数据列表控件 rptAfterSaleRequests：后台绑定集合数据后，按 ItemTemplate 循环渲染每条记录。 --%>
                    <asp:Repeater ID="rptAfterSaleRequests" runat="server" OnItemCommand="rptAfterSaleRequests_ItemCommand">
                        <%-- 列表项模板：定义 Repeater 中每一条业务记录的 HTML 结构和绑定字段。 --%>
                        <ItemTemplate>
                            <%-- 业务卡片：展示一条预约、审核、消息或统计记录。 --%>
                            <article class="reservation-card aftersale-card">
                                <h3><%# Eval("RequestType") %> · <%# Eval("Status") %></h3>
                                <p><%# Eval("ScriptName") %> / 订单 #<%# Eval("ReservationId") %> / <%# Eval("SessionDateTime", "{0:yyyy-MM-dd HH:mm}") %></p>
                                <p>申请原因：<%# Eval("Reason") %></p>
                                <p><%# string.IsNullOrWhiteSpace(Convert.ToString(Eval("AdminReply"))) ? "门店暂未回复处理说明。" : "门店回复：" + Eval("AdminReply") %></p>
                                <p><%# string.IsNullOrWhiteSpace(Convert.ToString(Eval("RejectReason"))) ? string.Empty : "驳回原因：" + Eval("RejectReason") %></p>
                                <p><%# string.IsNullOrWhiteSpace(Convert.ToString(Eval("AppealReason"))) ? string.Empty : "申诉说明：" + Eval("AppealReason") %></p>
                                <div class="service-timeline"><%# RenderAfterSaleTimeline(Container.DataItem) %></div>
                                <%# RenderAfterSaleEvidence(Eval("EvidenceUrl")) %>
                                <%-- 面板控件 pnlAppeal：后台可通过 Visible/CssClass 控制整块内容是否显示以及提示样式。 --%>
                                <asp:Panel ID="pnlAppeal" runat="server" Visible='<%# CanAppealAfterSale(Container.DataItem) %>' CssClass="booking-service-form top-gap">
                                    <%-- 输入控件 txtAppealReason：接收用户输入或展示后台已有备注。 --%>
                                    <asp:TextBox ID="txtAppealReason" runat="server" CssClass="input-control textarea" TextMode="MultiLine" Rows="2" placeholder="如对驳回结果有异议，请写明补充说明后再次申诉" />
                                    <asp:FileUpload ID="fuAppealEvidence" runat="server" CssClass="input-control compact-input" />
                                    <%-- 操作按钮 btnSubmitAfterSaleAppeal：点击后触发后台事件处理当前业务动作。 --%>
                                    <asp:Button ID="btnSubmitAfterSaleAppeal" runat="server" Text="提交二次申诉" CssClass="btn-secondary" CommandName="SubmitAfterSaleAppeal" CommandArgument='<%# Eval("Id") %>' />
                                </asp:Panel>
                            </article>
                        </ItemTemplate>
                    </asp:Repeater>
                </div>
            </article>
        </div>
    </section>
</asp:Content>

