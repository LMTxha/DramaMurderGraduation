<%@ Page Title="管理员后台 | 剧本杀系统" Language="C#" MasterPageFile="~/Site.Master" AutoEventWireup="true" CodeBehind="AdminReview.aspx.cs" Inherits="DramaMurderGraduation.Web.AdminReviewPage" %>
<asp:Content ID="Content1" ContentPlaceHolderID="TitleContent" runat="server">
    管理员后台 | 剧本杀系统
</asp:Content>
<asp:Content ID="Content2" ContentPlaceHolderID="MainContent" runat="server">
    <section class="inner-hero">
        <div class="container">
            <p class="eyebrow">Admin Console</p>
            <h1>门店管理员后台</h1>
            <p>这里不只处理审核，还能直接管理到店联系单、预约订单、今日排期和剧本库，是门店运营的统一入口。</p>
        </div>
    </section>

    <section class="section-block">
        <div class="container admin-layout">
            <aside class="about-panel admin-sidebar">
                <div class="section-heading left">
                    <h2>管理员权限</h2>
                    <p>左侧专栏汇总后台应有的核心权限，方便门店管理员按业务流快速处理。</p>
                </div>

                <div class="admin-nav-list">
                    <a class="admin-nav-item" href="#admin-overview">
                        <span>运营总览</span>
                        <strong><asp:Literal ID="litTodayReservationCount" runat="server" /></strong>
                    </a>
                    <a class="admin-nav-item" href="#pending-users">
                        <span>用户审核</span>
                        <strong><asp:Literal ID="litPendingUserCount" runat="server" /></strong>
                    </a>
                    <a class="admin-nav-item" href="#pending-recharges">
                        <span>充值审核</span>
                        <strong><asp:Literal ID="litPendingRechargeCount" runat="server" /></strong>
                    </a>
                    <a class="admin-nav-item" href="#store-requests">
                        <span>到店联系单</span>
                        <strong><asp:Literal ID="litStoreVisitCount" runat="server" /></strong>
                    </a>
                    <a class="admin-nav-item" href="#reservation-orders">
                        <span>预约订单</span>
                        <strong><asp:Literal ID="litReservationCount" runat="server" /></strong>
                    </a>
                    <a class="admin-nav-item" href="#room-session-admin">
                        <span>房间场次</span>
                        <strong><asp:Literal ID="litUpcomingSessionCount" runat="server" /></strong>
                    </a>
                    <a class="admin-nav-item" href="#announcement-admin">
                        <span>公告管理</span>
                        <strong><asp:Literal ID="litAnnouncementCount" runat="server" /></strong>
                    </a>
                    <a class="admin-nav-item" href="#pending-scripts">
                        <span>剧本审核</span>
                        <strong><asp:Literal ID="litPendingScriptCount" runat="server" /></strong>
                    </a>
                    <a class="admin-nav-item" href="#all-scripts">
                        <span>剧本库管理</span>
                        <strong><asp:Literal ID="litTotalScriptCount" runat="server" /></strong>
                    </a>
                </div>

                <div class="reservation-list compact-reservation-list">
                    <article class="reservation-card">
                        <h3>门店应有权限</h3>
                        <p>审核注册用户与充值申请，确认预约订单，处理到店联系单，安排房间排期，审核剧本发布，维护剧本库。</p>
                        <small>这样后台才是真正的门店管理系统，而不是单纯的展示页。</small>
                    </article>
                    <article class="reservation-card">
                        <h3>今日处理重点</h3>
                        <p>今日到店联系单 <strong><asp:Literal ID="litTodayStoreCount" runat="server" /></strong> 条，已安排排期 <strong><asp:Literal ID="litArrangedStoreCount" runat="server" /></strong> 条。</p>
                        <small>今日预约订单 <asp:Literal ID="litConfirmedReservationCount" runat="server" /> 条已完成门店确认。</small>
                    </article>
                </div>
            </aside>

            <div class="admin-main">
                <asp:Panel ID="pnlMessage" runat="server" Visible="false" CssClass="status-message">
                    <asp:Literal ID="litMessage" runat="server" />
                </asp:Panel>

                <div class="wallet-summary-grid admin-summary-grid" id="admin-overview">
                    <article class="wallet-summary-card accent">
                        <span>待审核用户</span>
                        <strong><asp:Literal ID="litPendingUserCountSummary" runat="server" /></strong>
                        <small>新注册用户需要门店审核后才能登录和预约</small>
                    </article>
                    <article class="wallet-summary-card">
                        <span>待审核充值</span>
                        <strong><asp:Literal ID="litPendingRechargeCountSummary" runat="server" /></strong>
                        <small>银行卡充值需要管理员确认到账</small>
                    </article>
                    <article class="wallet-summary-card">
                        <span>到店联系单</span>
                        <strong><asp:Literal ID="litStoreVisitCountSummary" runat="server" /></strong>
                        <small>玩家提交后由门店安排剧本、人数、时间和房间</small>
                    </article>
                    <article class="wallet-summary-card">
                        <span>预约订单</span>
                        <strong><asp:Literal ID="litReservationCountSummary" runat="server" /></strong>
                        <small>确认预约后可直接进入后续开本排期</small>
                    </article>
                </div>

                <div class="section-heading" id="pending-users">
                    <h2>待审核用户</h2>
                    <p>用户审核通过后才能登录、预约、提交剧本和进入玩家中心。</p>
                </div>
                <div class="admin-list">
                    <asp:Repeater ID="rptPendingUsers" runat="server" OnItemCommand="rptPendingUsers_ItemCommand">
                        <ItemTemplate>
                            <article class="admin-card">
                                <div class="admin-card-main">
                                    <h3><%# Eval("DisplayName") %>（<%# Eval("Username") %>）</h3>
                                    <p>邮箱：<%# Eval("Email") %> / 手机：<%# Eval("Phone") %></p>
                                    <small>注册时间：<%# Eval("CreatedAt", "{0:yyyy-MM-dd HH:mm}") %></small>
                                </div>
                                <div class="admin-card-side">
                                    <asp:TextBox ID="txtUserRemark" runat="server" CssClass="input-control" placeholder="填写审核意见（可选）" />
                                    <div class="card-actions">
                                        <asp:Button ID="btnApproveUser" runat="server" Text="通过" CssClass="btn-primary" CommandName="ApproveUser" CommandArgument='<%# Eval("Id") %>' />
                                        <asp:Button ID="btnRejectUser" runat="server" Text="驳回" CssClass="btn-secondary" CommandName="RejectUser" CommandArgument='<%# Eval("Id") %>' />
                                    </div>
                                </div>
                            </article>
                        </ItemTemplate>
                    </asp:Repeater>
                </div>

                <div class="section-heading top-gap" id="pending-recharges">
                    <h2>待审核充值申请</h2>
                    <p>银行卡支付需要门店管理员确认后到账，扫码和微信支付会自动完成。</p>
                </div>
                <div class="admin-list">
                    <asp:Repeater ID="rptPendingRechargeRequests" runat="server" OnItemCommand="rptPendingRechargeRequests_ItemCommand">
                        <ItemTemplate>
                            <article class="admin-card">
                                <div class="admin-card-main">
                                    <h3><%# Eval("DisplayName") %>（<%# Eval("Username") %>）</h3>
                                    <p>支付方式：<%# TranslatePaymentMethod(Eval("PaymentMethod")) %> / 金额：￥<%# Eval("Amount", "{0:F2}") %></p>
                                    <p>付款账号：<%# Eval("PaymentAccount") %></p>
                                    <small>提交时间：<%# Eval("SubmittedAt", "{0:yyyy-MM-dd HH:mm}") %></small>
                                </div>
                                <div class="admin-card-side">
                                    <asp:TextBox ID="txtRechargeRemark" runat="server" CssClass="input-control" placeholder="填写审核意见（可选）" />
                                    <div class="card-actions">
                                        <asp:Button ID="btnApproveRecharge" runat="server" Text="通过充值" CssClass="btn-primary" CommandName="ApproveRecharge" CommandArgument='<%# Eval("Id") %>' />
                                        <asp:Button ID="btnRejectRecharge" runat="server" Text="驳回充值" CssClass="btn-secondary" CommandName="RejectRecharge" CommandArgument='<%# Eval("Id") %>' />
                                    </div>
                                </div>
                            </article>
                        </ItemTemplate>
                    </asp:Repeater>
                </div>

                <div class="section-heading top-gap" id="store-requests">
                    <h2>到店联系单处理</h2>
                    <p>这是门店管理员最关键的权限之一。收到联系单后可以安排房间、记录备注，并更新联系状态。</p>
                </div>
                <article class="form-panel compact-form-panel">
                    <div class="section-heading left compact">
                        <h2>处理筛选</h2>
                        <p>按状态、到店日期和关键字筛选联系单与预约订单。</p>
                    </div>
                    <div class="form-grid">
                        <div class="field-group">
                            <label for="<%= txtAdminKeyword.ClientID %>">关键字</label>
                            <asp:TextBox ID="txtAdminKeyword" runat="server" CssClass="input-control" placeholder="联系人 / 电话 / 剧本 / 房间" />
                        </div>
                        <div class="field-group">
                            <label for="<%= ddlStoreStatusFilter.ClientID %>">到店联系单状态</label>
                            <asp:DropDownList ID="ddlStoreStatusFilter" runat="server" CssClass="input-control" />
                        </div>
                        <div class="field-group">
                            <label for="<%= ddlReservationStatusFilter.ClientID %>">预约订单状态</label>
                            <asp:DropDownList ID="ddlReservationStatusFilter" runat="server" CssClass="input-control" />
                        </div>
                        <div class="field-group">
                            <label for="<%= ddlAdminDateFilter.ClientID %>">日期范围</label>
                            <asp:DropDownList ID="ddlAdminDateFilter" runat="server" CssClass="input-control" />
                        </div>
                    </div>
                    <div class="hero-actions">
                        <asp:Button ID="btnApplyAdminFilter" runat="server" Text="应用筛选" CssClass="btn-primary" OnClick="btnApplyAdminFilter_Click" />
                        <asp:Button ID="btnResetAdminFilter" runat="server" Text="重置筛选" CssClass="btn-secondary" OnClick="btnResetAdminFilter_Click" />
                    </div>
                </article>
                <div class="admin-list">
                    <asp:Repeater ID="rptStoreVisitRequests" runat="server" OnItemCommand="rptStoreVisitRequests_ItemCommand">
                        <ItemTemplate>
                            <article class="admin-card">
                                <div class="admin-card-main">
                                    <h3><%# Eval("ScriptName") %></h3>
                                    <p>联系人：<%# Eval("ContactName") %> / 电话：<%# Eval("Phone") %> / 人数：<%# Eval("TeamSize") %> 人</p>
                                    <p>到店时间：<%# Eval("PreferredArriveTime", "{0:yyyy-MM-dd HH:mm}") %> / 状态：<%# TranslateStoreVisitStatus(Eval("RequestStatus")) %></p>
                                    <p><%# string.IsNullOrWhiteSpace(Convert.ToString(Eval("Note"))) ? "玩家没有填写额外备注。" : Eval("Note") %></p>
                                    <small>
                                        已安排房间：<%# string.IsNullOrWhiteSpace(Convert.ToString(Eval("AssignedRoomName"))) ? "待安排" : Eval("AssignedRoomName") %>
                                        / 处理时间：<%# Eval("ProcessedAt", "{0:yyyy-MM-dd HH:mm}") %>
                                    </small>
                                    <small>玩家确认：<%# string.IsNullOrWhiteSpace(Convert.ToString(Eval("ConfirmStatus"))) ? "未确认" : Eval("ConfirmStatus") %> <%# string.IsNullOrWhiteSpace(Convert.ToString(Eval("PlayerConfirmRemark"))) ? string.Empty : " / " + Eval("PlayerConfirmRemark") %></small>
                                    <p class="meta-copy">线上回复：<%# string.IsNullOrWhiteSpace(Convert.ToString(Eval("AdminReply"))) ? "尚未回复玩家" : Eval("AdminReply") %></p>
                                </div>
                                <div class="admin-card-side">
                                    <asp:TextBox ID="txtAssignedRoomName" runat="server" CssClass="input-control" placeholder="填写安排房间，如：长夜 B 厅" Text='<%# Eval("AssignedRoomName") %>' />
                                    <asp:TextBox ID="txtStoreRemark" runat="server" CssClass="input-control textarea" TextMode="MultiLine" Rows="3" placeholder="填写门店处理备注" Text='<%# Eval("AdminRemark") %>' />
                                    <asp:TextBox ID="txtStoreReply" runat="server" CssClass="input-control textarea" TextMode="MultiLine" Rows="3" placeholder="线上回复给玩家，例如：已安排长夜 B 厅，请 19:20 到店签到。" Text='<%# Eval("AdminReply") %>' />
                                    <div class="card-actions">
                                        <asp:Button ID="btnArrangeStore" runat="server" Text="安排排期" CssClass="btn-primary" CommandName="ArrangeStore" CommandArgument='<%# Eval("Id") %>' />
                                        <asp:Button ID="btnCompleteStore" runat="server" Text="到店完成" CssClass="btn-secondary" CommandName="CompleteStore" CommandArgument='<%# Eval("Id") %>' />
                                        <asp:Button ID="btnCloseStore" runat="server" Text="关闭联系单" CssClass="btn-secondary" CommandName="CloseStore" CommandArgument='<%# Eval("Id") %>' />
                                    </div>
                                </div>
                            </article>
                        </ItemTemplate>
                    </asp:Repeater>
                </div>

                <div class="section-heading top-gap" id="reservation-orders">
                    <h2>预约订单管理</h2>
                    <p>管理员可以确认预约、登记到店和取消预约，形成完整的门店订单流转。</p>
                </div>
                <div class="admin-list">
                    <asp:Repeater ID="rptReservationOrders" runat="server" OnItemCommand="rptReservationOrders_ItemCommand">
                        <ItemTemplate>
                            <article class="admin-card">
                                <div class="admin-card-main">
                                    <h3><%# Eval("ScriptName") %> / <%# Eval("RoomName") %></h3>
                                    <p>联系人：<%# Eval("ContactName") %> / 电话：<%# Eval("Phone") %> / 人数：<%# Eval("PlayerCount") %> 人</p>
                                    <p>场次：<%# Eval("SessionDateTime", "{0:yyyy-MM-dd HH:mm}") %> / DM：<%# Eval("HostName") %></p>
                                    <p>订单状态：<%# TranslateReservationStatus(Eval("Status")) %> / 支付：<%# Eval("PaymentStatus") %> / 金额：￥<%# Eval("TotalAmount", "{0:F2}") %></p>
                                    <p><%# string.IsNullOrWhiteSpace(Convert.ToString(Eval("Remark"))) ? "玩家没有填写预约备注。" : Eval("Remark") %></p>
                                    <small>管理员备注：<%# string.IsNullOrWhiteSpace(Convert.ToString(Eval("AdminRemark"))) ? "暂无" : Eval("AdminRemark") %></small>
                                    <small>玩家确认：<%# string.IsNullOrWhiteSpace(Convert.ToString(Eval("ConfirmStatus"))) ? "未确认" : Eval("ConfirmStatus") %> <%# string.IsNullOrWhiteSpace(Convert.ToString(Eval("PlayerConfirmRemark"))) ? string.Empty : " / " + Eval("PlayerConfirmRemark") %></small>
                                    <p class="meta-copy">线上回复：<%# string.IsNullOrWhiteSpace(Convert.ToString(Eval("AdminReply"))) ? "尚未回复玩家" : Eval("AdminReply") %></p>
                                </div>
                                <div class="admin-card-side">
                                    <asp:TextBox ID="txtReservationRemark" runat="server" CssClass="input-control textarea" TextMode="MultiLine" Rows="3" placeholder="填写订单处理备注" Text='<%# Eval("AdminRemark") %>' />
                                    <asp:TextBox ID="txtReservationReply" runat="server" CssClass="input-control textarea" TextMode="MultiLine" Rows="3" placeholder="线上回复给玩家，例如：预约已确认，请提前 10 分钟到店。" Text='<%# Eval("AdminReply") %>' />
                                    <div class="card-actions">
                                        <asp:Button ID="btnConfirmReservation" runat="server" Text="确认预约" CssClass="btn-primary" CommandName="ConfirmReservation" CommandArgument='<%# Eval("Id") %>' />
                                        <asp:Button ID="btnArriveReservation" runat="server" Text="登记到店" CssClass="btn-secondary" CommandName="ArriveReservation" CommandArgument='<%# Eval("Id") %>' />
                                        <asp:Button ID="btnCancelReservation" runat="server" Text="取消预约" CssClass="btn-secondary" CommandName="CancelReservation" CommandArgument='<%# Eval("Id") %>' />
                                    </div>
                                </div>
                            </article>
                        </ItemTemplate>
                    </asp:Repeater>
                </div>

                <div class="section-heading top-gap" id="admin-flow-logs">
                    <h2>回复历史与操作日志</h2>
                    <p>这里保存管理员回复、玩家确认和改期申请等真实业务流转记录。</p>
                </div>
                <div class="split-grid detail-split">
                    <article class="about-panel">
                        <div class="section-heading left compact">
                            <h2>最近线上回复</h2>
                            <p>每次给玩家的线上回复都会写入日志，不会只覆盖最新文本。</p>
                        </div>
                        <div class="reservation-list">
                            <asp:Repeater ID="rptAdminReplyLogs" runat="server">
                                <ItemTemplate>
                                    <article class="reservation-card">
                                        <h3><%# TranslateBusinessType(Eval("BusinessType")) %> #<%# Eval("BusinessId") %></h3>
                                        <p><%# Eval("ReplyContent") %></p>
                                        <small><%# Eval("AdminName") %> / <%# Eval("CreatedAt", "{0:yyyy-MM-dd HH:mm}") %></small>
                                    </article>
                                </ItemTemplate>
                            </asp:Repeater>
                        </div>
                    </article>

                    <article class="about-panel">
                        <div class="section-heading left compact">
                            <h2>最近业务操作</h2>
                            <p>安排排期、确认预约、玩家确认、申请改期都会在这里留下记录。</p>
                        </div>
                        <div class="reservation-list">
                            <asp:Repeater ID="rptBusinessActionLogs" runat="server">
                                <ItemTemplate>
                                    <article class="reservation-card">
                                        <h3><%# Eval("ActionTitle") %></h3>
                                        <p><%# TranslateBusinessType(Eval("BusinessType")) %> #<%# Eval("BusinessId") %> / <%# Eval("ActionType") %></p>
                                        <p><%# string.IsNullOrWhiteSpace(Convert.ToString(Eval("ActionContent"))) ? "无补充说明" : Eval("ActionContent") %></p>
                                        <small><%# Eval("OperatorName") %> / <%# Eval("CreatedAt", "{0:yyyy-MM-dd HH:mm}") %></small>
                                    </article>
                                </ItemTemplate>
                            </asp:Repeater>
                        </div>
                    </article>
                </div>

                <div class="section-heading top-gap" id="room-session-admin">
                    <h2>房间与场次管理</h2>
                    <p>管理员可以直接设置房间营业状态、补充新场次，并实时查看接下来可预约的门店排期。</p>
                </div>
                <div class="split-grid detail-split">
                    <article class="form-panel">
                        <div class="section-heading left compact">
                            <h2>新增预约场次</h2>
                            <p>选择已审核通过的剧本和房间，排入新的开放预约场次。</p>
                        </div>
                        <div class="form-grid">
                            <div class="field-group">
                                <label for="<%= ddlScheduleScript.ClientID %>">剧本</label>
                                <asp:DropDownList ID="ddlScheduleScript" runat="server" CssClass="input-control" />
                            </div>
                            <div class="field-group">
                                <label for="<%= ddlScheduleRoom.ClientID %>">房间</label>
                                <asp:DropDownList ID="ddlScheduleRoom" runat="server" CssClass="input-control" />
                            </div>
                            <div class="field-group">
                                <label for="<%= txtScheduleDateTime.ClientID %>">开场时间</label>
                                <asp:TextBox ID="txtScheduleDateTime" runat="server" CssClass="input-control" placeholder="例如：2026-04-18 19:30" />
                            </div>
                            <div class="field-group">
                                <label for="<%= txtScheduleHostName.ClientID %>">主持 DM</label>
                                <asp:TextBox ID="txtScheduleHostName" runat="server" CssClass="input-control" placeholder="填写 DM 名称" />
                            </div>
                            <div class="field-group">
                                <label for="<%= txtSchedulePrice.ClientID %>">人均价格</label>
                                <asp:TextBox ID="txtSchedulePrice" runat="server" CssClass="input-control" Text="228" />
                            </div>
                            <div class="field-group">
                                <label for="<%= txtScheduleMaxPlayers.ClientID %>">最大人数</label>
                                <asp:TextBox ID="txtScheduleMaxPlayers" runat="server" CssClass="input-control" Text="6" />
                            </div>
                        </div>
                        <asp:Button ID="btnCreateSession" runat="server" Text="创建新场次" CssClass="btn-primary wide-button" OnClick="btnCreateSession_Click" />
                    </article>

                    <article class="about-panel">
                        <div class="section-heading left compact">
                            <h2>房间状态管理</h2>
                            <p>门店可以随时切换房间营业状态，避免玩家继续预约维护中的房间。</p>
                        </div>
                        <div class="admin-list">
                            <asp:Repeater ID="rptAdminRooms" runat="server" OnItemCommand="rptAdminRooms_ItemCommand">
                                <ItemTemplate>
                                    <article class="admin-card">
                                        <div class="admin-card-main">
                                            <h3><%# Eval("Name") %></h3>
                                            <p>主题：<%# Eval("Theme") %> / 容量：<%# Eval("Capacity") %> 人</p>
                                            <p>房间状态：<strong><%# Eval("Status") %></strong> / 待开场次：<%# Eval("UpcomingSessionCount") %></p>
                                            <small><%# Eval("Description") %></small>
                                        </div>
                                        <div class="admin-card-side">
                                            <div class="card-actions">
                                                <asp:Button ID="btnEnableRoom" runat="server" Text="启用中" CssClass="btn-primary" CommandName="EnableRoom" CommandArgument='<%# Eval("Id") %>' />
                                                <asp:Button ID="btnMaintainRoom" runat="server" Text="维护中" CssClass="btn-secondary" CommandName="MaintainRoom" CommandArgument='<%# Eval("Id") %>' />
                                                <asp:Button ID="btnPauseRoom" runat="server" Text="暂停接待" CssClass="btn-secondary" CommandName="PauseRoom" CommandArgument='<%# Eval("Id") %>' />
                                            </div>
                                        </div>
                                    </article>
                                </ItemTemplate>
                            </asp:Repeater>
                        </div>
                    </article>
                </div>

                <div class="admin-list top-gap">
                    <asp:Repeater ID="rptAdminSessions" runat="server">
                        <ItemTemplate>
                            <article class="admin-card">
                                <div class="admin-card-main">
                                    <h3><%# Eval("ScriptName") %> / <%# Eval("RoomName") %></h3>
                                    <p>开场时间：<%# Eval("SessionDateTime", "{0:yyyy-MM-dd HH:mm}") %> / DM：<%# Eval("HostName") %></p>
                                    <p>状态：<%# Eval("Status") %> / 已预订：<%# Eval("ReservedPlayers") %> / 剩余：<%# Eval("RemainingSeats") %></p>
                                    <small>人均 ￥<%# Eval("BasePrice", "{0:F2}") %> / 最大人数 <%# Eval("MaxPlayers") %></small>
                                </div>
                            </article>
                        </ItemTemplate>
                    </asp:Repeater>
                </div>

                <div class="section-heading top-gap" id="announcement-admin">
                    <h2>公告管理</h2>
                    <p>管理员可以发布首页公告，重要公告会优先展示在前台首页与数据看板区域。</p>
                </div>
                <div class="split-grid detail-split">
                    <article class="form-panel">
                        <div class="section-heading left compact">
                            <h2>发布门店公告</h2>
                            <p>公告将直接从数据库读取并展示，不是写死在页面上的静态文案。</p>
                        </div>
                        <div class="form-grid single-form">
                            <div class="field-group">
                                <label for="<%= txtAnnouncementTitle.ClientID %>">公告标题</label>
                                <asp:TextBox ID="txtAnnouncementTitle" runat="server" CssClass="input-control" />
                            </div>
                            <div class="field-group">
                                <label for="<%= txtAnnouncementSummary.ClientID %>">公告内容</label>
                                <asp:TextBox ID="txtAnnouncementSummary" runat="server" CssClass="input-control textarea" TextMode="MultiLine" Rows="4" />
                            </div>
                            <div class="field-group">
                                <label class="inline-note">
                                    <asp:CheckBox ID="chkAnnouncementImportant" runat="server" />
                                    设为重要公告
                                </label>
                            </div>
                        </div>
                        <asp:Button ID="btnPublishAnnouncement" runat="server" Text="发布公告" CssClass="btn-primary wide-button" OnClick="btnPublishAnnouncement_Click" />
                    </article>

                    <article class="about-panel">
                        <div class="section-heading left compact">
                            <h2>最近公告</h2>
                            <p>这里展示当前数据库中的最新公告，方便管理员确认前台会看到什么内容。</p>
                        </div>
                        <div class="reservation-list">
                            <asp:Repeater ID="rptAdminAnnouncements" runat="server">
                                <ItemTemplate>
                                    <article class="reservation-card">
                                        <h3><%# Eval("Title") %></h3>
                                        <p><%# Eval("Summary") %></p>
                                        <small><%# Eval("PublishDate", "{0:yyyy-MM-dd}") %> <%# Convert.ToBoolean(Eval("IsImportant")) ? " / 重要公告" : string.Empty %></small>
                                    </article>
                                </ItemTemplate>
                            </asp:Repeater>
                        </div>
                    </article>
                </div>

                <div class="section-heading top-gap" id="pending-scripts">
                    <h2>待审核剧本</h2>
                    <p>审核通过后，剧本会自动进入前台剧本库，供玩家浏览、预约和评价。</p>
                </div>
                <div class="admin-list">
                    <asp:Repeater ID="rptPendingScripts" runat="server" OnItemCommand="rptPendingScripts_ItemCommand">
                        <ItemTemplate>
                            <article class="admin-card vertical">
                                <div class="admin-card-main">
                                    <h3><%# Eval("Name") %></h3>
                                    <p><%# Eval("GenreName") %> / <%# Eval("Difficulty") %> / 投稿人：<%# string.IsNullOrWhiteSpace(Convert.ToString(Eval("CreatorDisplayName"))) ? "系统种子数据" : Eval("CreatorDisplayName") %></p>
                                    <p><%# Eval("Slogan") %></p>
                                    <p><%# Eval("StoryBackground") %></p>
                                    <small>提交时间：<%# Eval("SubmittedAt", "{0:yyyy-MM-dd HH:mm}") %></small>
                                </div>
                                <div class="admin-card-side">
                                    <asp:TextBox ID="txtScriptRemark" runat="server" CssClass="input-control textarea" TextMode="MultiLine" Rows="3" placeholder="填写审核意见" />
                                    <div class="card-actions">
                                        <asp:Button ID="btnApproveScript" runat="server" Text="通过剧本" CssClass="btn-primary" CommandName="ApproveScript" CommandArgument='<%# Eval("Id") %>' />
                                        <asp:Button ID="btnRejectScript" runat="server" Text="驳回剧本" CssClass="btn-secondary" CommandName="RejectScript" CommandArgument='<%# Eval("Id") %>' />
                                    </div>
                                </div>
                            </article>
                        </ItemTemplate>
                    </asp:Repeater>
                </div>

                <div class="section-heading top-gap" id="all-scripts">
                    <h2>全部剧本管理</h2>
                    <p>删除剧本时会一并删除角色、评价、场次和预约记录，属于管理员级别权限，请谨慎操作。</p>
                </div>
                <div class="admin-list">
                    <asp:Repeater ID="rptAllScripts" runat="server" OnItemCommand="rptAllScripts_ItemCommand">
                        <ItemTemplate>
                            <article class="admin-card">
                                <div class="admin-card-main">
                                    <h3><%# Eval("Name") %></h3>
                                    <p><%# Eval("GenreName") %> / <%# Eval("Difficulty") %> / <%# Eval("PlayerMin") %>-<%# Eval("PlayerMax") %> 人</p>
                                    <p>审核状态：<%# TranslateAuditStatus(Eval("AuditStatus")) %> / 评分：<%# Eval("AverageRating", "{0:F1}") %> / 场次：<%# Eval("UpcomingSessionCount") %></p>
                                    <small>作者：<%# Eval("AuthorName") %> / 剧本 ID：<%# Eval("Id") %></small>
                                </div>
                                <div class="admin-card-side">
                                    <asp:Button ID="btnDeleteScript" runat="server" Text="删除剧本" CssClass="btn-secondary" CommandName="DeleteScript" CommandArgument='<%# Eval("Id") %>' OnClientClick="return confirm('删除后将同步删除该剧本的角色、评价、场次和预约记录，确定继续吗？');" />
                                </div>
                            </article>
                        </ItemTemplate>
                    </asp:Repeater>
                </div>
            </div>
        </div>
    </section>
</asp:Content>
