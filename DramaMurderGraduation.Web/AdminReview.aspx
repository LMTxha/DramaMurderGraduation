<%@ Page Title="管理员后台 | 剧本杀系统" Language="C#" MasterPageFile="~/Site.Master" AutoEventWireup="true" CodeBehind="AdminReview.aspx.cs" Inherits="DramaMurderGraduation.Web.AdminReviewPage" MaintainScrollPositionOnPostBack="true" %>
<%-- 页面用途：AdminReview 页面负责承载对应功能的 Web Forms 标记、服务端控件和前端布局。 --%>
<asp:Content ID="Content1" ContentPlaceHolderID="TitleContent" runat="server">
    管理员后台 | 剧本杀系统
</asp:Content>
<asp:Content ID="Content2" ContentPlaceHolderID="MainContent" runat="server">
    <%-- 后台首页头图区域：展示管理员控制台定位，以及几个最高优先级的业务数量摘要。 --%>
    <section class="detail-hero">
        <div class="container detail-grid">
            <%-- 说明卡片：展示页面主标题、摘要和关键标签。 --%>
            <article class="detail-copy">
                <%-- 左侧主说明区：用于说明后台覆盖的业务范围。 --%>
                <p class="eyebrow">ADMIN CONSOLE</p>
                <h1>门店运营后台</h1>
                <p class="hero-subtitle">集中处理账号审核、充值审核、预约履约、售后退款、服务会话、评价处理、场次排期、公告发布和剧本管理。</p>
                <%-- 顶部摘要标签：这些 Literal 在后台 Page_Load 中绑定，用于快速提示当前待处理数量。 --%>
                <div class="detail-tags">
                    <span>待审账号 <asp:Literal ID="litPendingUserCountSummary" runat="server" /></span>
                    <span>待审充值 <asp:Literal ID="litPendingRechargeCountSummary" runat="server" /></span>
                    <span>到店联系单 <asp:Literal ID="litStoreVisitCountSummary" runat="server" /></span>
                    <span>预约订单 <asp:Literal ID="litReservationCountSummary" runat="server" /></span>
                </div>
            </article>
            <%-- 信息面板：承载一个独立的业务说明、列表或表单模块。 --%>
            <article class="about-panel">
                <%-- 右侧今日重点：从后台构造的待办集合中筛出影响履约链路的事项。 --%>
                <div class="section-heading left">
                    <h2>今日重点</h2>
                    <p>优先处理会直接影响履约和评价的事项，保证答辩时演示链路稳定完整。</p>
                </div>
                <%-- 列表容器：承载 Repeater 渲染出的多条业务卡片。 --%>
                <div class="reservation-list">
                    <%-- 管理员待办 Repeater：每条待办卡片都带有优先级样式、数量提示和跳转锚点。 --%>
                    <asp:Repeater ID="rptAdminTodoItems" runat="server">
                        <%-- 列表项模板：定义 Repeater 中每一条业务记录的 HTML 结构和绑定字段。 --%>
                        <ItemTemplate>
                            <%-- Priority 控制卡片颜色；TargetAnchor 指向页面下方对应处理模块。 --%>
                            <a class='reservation-card todo-card <%# Eval("Priority") %>' href='<%# Eval("TargetAnchor") %>'>
                                <%-- CountText 显示待处理数量或状态标签。 --%>
                                <span class='badge-inline <%# Eval("Priority") %>'><%# Eval("CountText") %></span>
                                <%-- Title/Summary 是后台待办的标题和说明。 --%>
                                <h3><%# Eval("Title") %></h3>
                                <p><%# Eval("Summary") %></p>
                            </a>
                        </ItemTemplate>
                    </asp:Repeater>
                </div>
            </article>
        </div>
    </section>

    <%-- 主要内容区：承载当前页面的核心业务列表、表单或详情内容。 --%>
    <section class="section-block">
        <div class="container">
            <%-- 统一操作反馈区：后台审核、保存、驳回等动作完成后在这里显示成功或错误提示。 --%>
            <asp:Panel ID="pnlMessage" runat="server" Visible="false" CssClass="status-message">
                <asp:Literal ID="litMessage" runat="server" />
            </asp:Panel>
            <asp:Panel ID="pnlScheduleMessage" runat="server" Visible="false" CssClass="status-message schedule-message">
                <asp:Literal ID="litScheduleMessage" runat="server" />
            </asp:Panel>

            <%-- 后台核心指标卡片：汇总账号、充值、剧本、联系单、预约、公告和今日履约相关数量。 --%>
            <div class="wallet-summary-grid dm-summary-grid">
                <%-- 用户审核队列：新注册用户需要管理员通过后才可以进入完整业务流程。 --%>
                <a class="wallet-summary-card accent admin-summary-link" href="AdminModule.aspx?module=pending-users"><span>待审用户</span><strong><asp:Literal ID="litPendingUserCount" runat="server" /></strong><small>还未完成管理员审核的新注册用户</small></a>
                <%-- 财务审核队列：充值申请确认后才会写入用户钱包余额。 --%>
                <a class="wallet-summary-card admin-summary-link" href="AdminModule.aspx?module=pending-recharge"><span>待审充值</span><strong><asp:Literal ID="litPendingRechargeCount" runat="server" /></strong><small>需要财务确认入账的充值申请</small></a>
                <%-- 内容审核队列：创作者提交的剧本需要审核后才进入剧本库。 --%>
                <a class="wallet-summary-card admin-summary-link" href="AdminModule.aspx?module=pending-scripts"><span>待审剧本</span><strong><asp:Literal ID="litPendingScriptCount" runat="server" /></strong><small>创作者提交后等待审核的剧本</small></a>
                <%-- 当前筛选条件下的到店咨询或试玩联系单数量。 --%>
                <a class="wallet-summary-card admin-summary-link" href="AdminModule.aspx?module=store-visits"><span>到店联系单</span><strong><asp:Literal ID="litStoreVisitCount" runat="server" /></strong><small>当前筛选结果中的到店联系单总数</small></a>
                <%-- 当前筛选条件下的预约订单数量。 --%>
                <a class="wallet-summary-card admin-summary-link" href="AdminModule.aspx?module=reservations"><span>预约订单</span><strong><asp:Literal ID="litReservationCount" runat="server" /></strong><small>当前筛选结果中的预约订单总数</small></a>
                <%-- 剧本库总量，用于展示当前内容储备规模。 --%>
                <a class="wallet-summary-card admin-summary-link" href="AdminModule.aspx?module=scripts"><span>剧本总数</span><strong><asp:Literal ID="litTotalScriptCount" runat="server" /></strong><small>当前剧本库条目总数</small></a>
                <%-- 今日计划到店的联系单数量，便于运营优先安排接待。 --%>
                <a class="wallet-summary-card admin-summary-link" href="AdminModule.aspx?module=today-store"><span>今日到店</span><strong><asp:Literal ID="litTodayStoreCount" runat="server" /></strong><small>今天计划到店的联系单</small></a>
                <%-- 今日需要履约的预约订单数量，便于排班和房间准备。 --%>
                <a class="wallet-summary-card admin-summary-link" href="AdminModule.aspx?module=today-reservations"><span>今日预约</span><strong><asp:Literal ID="litTodayReservationCount" runat="server" /></strong><small>今天需要履约处理的预约订单</small></a>
                <%-- 尚未开场的排期数量，用于观察后续可预约容量。 --%>
                <a class="wallet-summary-card admin-summary-link" href="AdminModule.aspx?module=upcoming-sessions"><span>未来场次</span><strong><asp:Literal ID="litUpcomingSessionCount" runat="server" /></strong><small>已创建但尚未开场的排期场次</small></a>
                <%-- 站内公告总量，用于确认运营公告维护情况。 --%>
                <a class="wallet-summary-card admin-summary-link" href="AdminModule.aspx?module=announcements"><span>公告数量</span><strong><asp:Literal ID="litAnnouncementCount" runat="server" /></strong><small>当前站内公告总数</small></a>
                <%-- 已安排或已到店完成的联系单数量，体现运营处理进度。 --%>
                <a class="wallet-summary-card admin-summary-link" href="AdminModule.aspx?module=arranged-store"><span>已安排到店</span><strong><asp:Literal ID="litArrangedStoreCount" runat="server" /></strong><small>已经安排房间或已到店完成</small></a>
                <%-- 已确认或已到店的预约订单数量，体现预约履约进度。 --%>
                <a class="wallet-summary-card admin-summary-link" href="AdminModule.aspx?module=confirmed-reservations"><span>已确认预约</span><strong><asp:Literal ID="litConfirmedReservationCount" runat="server" /></strong><small>已确认或已到店的预约订单</small></a>
            </div>
        </div>
    </section>

    <%-- 次级内容区：用于承载筛选、配置、辅助列表或补充信息。 --%>
    <section class="section-block alt" id="admin-filter">
        <div class="container split-grid detail-split">
            <%-- 表单面板：承载筛选条件或业务提交输入项。 --%>
            <article class="form-panel">
                <%-- 模块标题区：说明当前业务模块的名称和处理说明。 --%>
                <div class="section-heading left">
                    <h2>后台筛选</h2>
                    <p>按关键词、联系单状态、订单状态和日期范围快速聚焦待处理事项。</p>
                </div>
                <%-- 表单网格：按响应式布局排列输入框、下拉框和筛选条件。 --%>
                <div class="form-grid">
                    <div class="field-group"><label for="<%= txtAdminKeyword.ClientID %>">关键词</label><asp:TextBox ID="txtAdminKeyword" runat="server" CssClass="input-control" placeholder="联系人 / 剧本 / 房间 / 手机号" /></div>
                    <div class="field-group"><label for="<%= ddlStoreStatusFilter.ClientID %>">到店联系状态</label><asp:DropDownList ID="ddlStoreStatusFilter" runat="server" CssClass="input-control" /></div>
                    <div class="field-group"><label for="<%= ddlReservationStatusFilter.ClientID %>">预约订单状态</label><asp:DropDownList ID="ddlReservationStatusFilter" runat="server" CssClass="input-control" /></div>
                    <div class="field-group"><label for="<%= ddlAdminDateFilter.ClientID %>">日期范围</label><asp:DropDownList ID="ddlAdminDateFilter" runat="server" CssClass="input-control" /></div>
                </div>
                <%-- 操作按钮区：集中放置提交、重置、跳转或审核动作。 --%>
                <div class="hero-actions">
                    <%-- 操作按钮 btnApplyAdminFilter：点击后触发后台事件处理当前业务动作。 --%>
                    <asp:Button ID="btnApplyAdminFilter" runat="server" Text="应用筛选" CssClass="btn-primary" OnClick="btnApplyAdminFilter_Click" />
                    <%-- 操作按钮 btnResetAdminFilter：点击后触发后台事件处理当前业务动作。 --%>
                    <asp:Button ID="btnResetAdminFilter" runat="server" Text="重置条件" CssClass="btn-secondary" OnClick="btnResetAdminFilter_Click" />
                </div>
            </article>
            <%-- 信息面板：承载一个独立的业务说明、列表或表单模块。 --%>
            <article class="about-panel" id="finance-audit-admin">
                <%-- 模块标题区：说明当前业务模块的名称和处理说明。 --%>
                <div class="section-heading left">
                    <h2>财务审计概览</h2>
                    <p>快速确认充值、预约收入、退款和优惠抵扣是否平衡，异常交易会单独标出。</p>
                </div>
                <%-- 操作按钮区：集中放置提交、重置、跳转或审核动作。 --%>
                <div class="hero-actions">
                    <a class="btn-secondary small" href="AdminReview.aspx?export=finance">导出财务报表 CSV</a>
                </div>
                <%-- 统计网格：集中展示多个关键业务指标。 --%>
                <div class="analytics-kpi-grid">
                    <div class="analytics-stat-card"><p>充值总额</p><strong>￥<asp:Literal ID="litAuditRechargeTotal" runat="server" /></strong></div>
                    <div class="analytics-stat-card"><p>预约收入</p><strong>￥<asp:Literal ID="litAuditBookingTotal" runat="server" /></strong></div>
                    <div class="analytics-stat-card"><p>退款总额</p><strong>￥<asp:Literal ID="litAuditRefundTotal" runat="server" /></strong></div>
                    <div class="analytics-stat-card"><p>优惠抵扣</p><strong>￥<asp:Literal ID="litAuditCouponTotal" runat="server" /></strong></div>
                    <div class="analytics-stat-card"><p>待退款金额</p><strong>￥<asp:Literal ID="litAuditPendingRefundTotal" runat="server" /></strong></div>
                    <div class="analytics-stat-card"><p>异常流水</p><strong><asp:Literal ID="litAuditAnomalyCount" runat="server" /></strong></div>
                    <div class="analytics-stat-card"><p>驳回充值</p><strong><asp:Literal ID="litAuditRejectedRechargeCount" runat="server" /></strong></div>
                </div>
            </article>
        </div>
    </section>

    <%-- 主要内容区：承载当前页面的核心业务列表、表单或详情内容。 --%>
    <section class="section-block">
        <div class="container split-grid detail-split">
            <%-- 信息面板：承载一个独立的业务说明、列表或表单模块。 --%>
            <article class="about-panel">
                <%-- 模块标题区：说明当前业务模块的名称和处理说明。 --%>
                <div class="section-heading left">
                    <h2>账号审核</h2>
                    <p>新注册用户需要通过管理员审核后才能进入完整业务流程。</p>
                </div>
                <%-- 列表容器：承载 Repeater 渲染出的多条业务卡片。 --%>
                <div class="reservation-list">
                    <%-- 数据列表控件 rptPendingUsers：后台绑定集合数据后，按 ItemTemplate 循环渲染每条记录。 --%>
                    <asp:Repeater ID="rptPendingUsers" runat="server" OnItemCommand="rptPendingUsers_ItemCommand">
                        <%-- 列表项模板：定义 Repeater 中每一条业务记录的 HTML 结构和绑定字段。 --%>
                        <ItemTemplate>
                            <%-- 业务卡片：展示一条预约、审核、消息或统计记录。 --%>
                            <article class="reservation-card">
                                <h3><%# Eval("DisplayName") %> / <%# Eval("Username") %></h3>
                                <p>手机号：<%# Eval("Phone") %> · 角色：<%# Eval("RoleCode") %></p>
                                <p>注册时间：<%# Eval("CreatedAt", "{0:yyyy-MM-dd HH:mm}") %></p>
                                <%-- 输入控件 txtUserRemark：接收用户输入或展示后台已有备注。 --%>
                                <asp:TextBox ID="txtUserRemark" runat="server" CssClass="input-control" placeholder="审核备注" Text='<%# Eval("ReviewRemark") %>' />
                                <%-- 操作按钮区：集中放置提交、重置、跳转或审核动作。 --%>
                                <div class="hero-actions">
                                    <%-- 操作按钮 btnApproveUser：点击后触发后台事件处理当前业务动作。 --%>
                                    <asp:Button ID="btnApproveUser" runat="server" Text="通过" CssClass="btn-primary small" CommandName="ApproveUser" CommandArgument='<%# Eval("Id") %>' CausesValidation="false" />
                                    <%-- 操作按钮 btnRejectUser：点击后触发后台事件处理当前业务动作。 --%>
                                    <asp:Button ID="btnRejectUser" runat="server" Text="驳回" CssClass="btn-secondary small" CommandName="RejectUser" CommandArgument='<%# Eval("Id") %>' CausesValidation="false" />
                                </div>
                            </article>
                        </ItemTemplate>
                    </asp:Repeater>
                </div>
            </article>

            <%-- 信息面板：承载一个独立的业务说明、列表或表单模块。 --%>
            <article class="about-panel">
                <%-- 模块标题区：说明当前业务模块的名称和处理说明。 --%>
                <div class="section-heading left">
                    <h2>充值审核</h2>
                    <p>确认支付方式、付款账号和申请金额后，再决定是否入账到钱包。</p>
                </div>
                <%-- 列表容器：承载 Repeater 渲染出的多条业务卡片。 --%>
                <div class="reservation-list">
                    <%-- 数据列表控件 rptPendingRechargeRequests：后台绑定集合数据后，按 ItemTemplate 循环渲染每条记录。 --%>
                    <asp:Repeater ID="rptPendingRechargeRequests" runat="server" OnItemCommand="rptPendingRechargeRequests_ItemCommand">
                        <%-- 列表项模板：定义 Repeater 中每一条业务记录的 HTML 结构和绑定字段。 --%>
                        <ItemTemplate>
                            <%-- 业务卡片：展示一条预约、审核、消息或统计记录。 --%>
                            <article class="reservation-card">
                                <h3><%# Eval("DisplayName") %> / ￥<%# Eval("Amount", "{0:F2}") %></h3>
                                <p>充值单号：<%# Eval("RechargeOrderNo") %></p>
                                <p>方式：<%# DisplayPaymentMethod(Eval("PaymentMethod")) %> · 账号：<%# Eval("PaymentAccountMasked") %></p>
                                <p>提交时间：<%# Eval("SubmittedAt", "{0:yyyy-MM-dd HH:mm}") %></p>
                                <%-- 输入控件 txtRechargeRemark：接收用户输入或展示后台已有备注。 --%>
                                <asp:TextBox ID="txtRechargeRemark" runat="server" CssClass="input-control" placeholder="审核备注" Text='<%# Eval("ReviewRemark") %>' />
                                <%-- 操作按钮区：集中放置提交、重置、跳转或审核动作。 --%>
                                <div class="hero-actions">
                                    <%-- 操作按钮 btnApproveRecharge：点击后触发后台事件处理当前业务动作。 --%>
                                    <asp:Button ID="btnApproveRecharge" runat="server" Text="通过充值" CssClass="btn-primary small" CommandName="ApproveRecharge" CommandArgument='<%# Eval("Id") %>' CausesValidation="false" />
                                    <%-- 操作按钮 btnRejectRecharge：点击后触发后台事件处理当前业务动作。 --%>
                                    <asp:Button ID="btnRejectRecharge" runat="server" Text="驳回申请" CssClass="btn-secondary small" CommandName="RejectRecharge" CommandArgument='<%# Eval("Id") %>' CausesValidation="false" />
                                </div>
                            </article>
                        </ItemTemplate>
                    </asp:Repeater>
                </div>
            </article>
        </div>
    </section>

    <%-- 次级内容区：用于承载筛选、配置、辅助列表或补充信息。 --%>
    <section class="section-block alt" id="roleMatrixAdmin" runat="server">
        <div class="container">
            <%-- 面板控件 pnlRoleMatrix：后台可通过 Visible/CssClass 控制整块内容是否显示以及提示样式。 --%>
            <asp:Panel ID="pnlRoleMatrix" runat="server" Visible="false">
                <%-- 模块标题区：说明当前业务模块的名称和处理说明。 --%>
                <div class="section-heading left">
                    <h2>人员权限矩阵</h2>
                    <p>管理员可以在这里为已审核通过的账号分配运营、财务、客服、内容和 DM 等后台角色，登录后会按能力自动裁剪菜单和功能入口。</p>
                </div>
                <%-- 列表容器：承载 Repeater 渲染出的多条业务卡片。 --%>
                <div class="reservation-list">
                    <%-- 数据列表控件 rptRoleMatrixUsers：后台绑定集合数据后，按 ItemTemplate 循环渲染每条记录。 --%>
                    <asp:Repeater ID="rptRoleMatrixUsers" runat="server" OnItemCommand="rptPendingUsers_ItemCommand" OnItemDataBound="rptRoleMatrixUsers_ItemDataBound">
                        <%-- 列表项模板：定义 Repeater 中每一条业务记录的 HTML 结构和绑定字段。 --%>
                        <ItemTemplate>
                            <%-- 业务卡片：展示一条预约、审核、消息或统计记录。 --%>
                            <article class="reservation-card">
                                <h3><%# Eval("DisplayName") %> / <%# Eval("Username") %></h3>
                                <p>当前角色：<%# GetRoleDisplayName(Eval("RoleCode")) %> · 审核状态：<%# Eval("ReviewStatus") %></p>
                                <%-- 表单网格：按响应式布局排列输入框、下拉框和筛选条件。 --%>
                                <div class="form-grid single-form">
                                    <div class="field-group full">
                                        <label>调整角色</label>
                                        <%-- 下拉控件 ddlUserRole：提供状态、分类或角色等固定选项。 --%>
                                        <asp:DropDownList ID="ddlUserRole" runat="server" CssClass="input-control" />
                                    </div>
                                </div>
                                <%-- 操作按钮区：集中放置提交、重置、跳转或审核动作。 --%>
                                <div class="hero-actions">
                                    <%-- 操作按钮 btnUpdateUserRole：点击后触发后台事件处理当前业务动作。 --%>
                                    <asp:Button ID="btnUpdateUserRole" runat="server" Text="保存角色" CssClass="btn-primary small" CommandName="UpdateRole" CommandArgument='<%# Eval("Id") %>' CausesValidation="false" />
                                </div>
                            </article>
                        </ItemTemplate>
                    </asp:Repeater>
                </div>
            </asp:Panel>
        </div>
    </section>

    <%-- 次级内容区：用于承载筛选、配置、辅助列表或补充信息。 --%>
    <section class="section-block alt" id="store-requests">
        <div class="container">
            <%-- 模块标题区：说明当前业务模块的名称和处理说明。 --%>
            <div class="section-heading left">
                <h2>到店联系单</h2>
                <p>用于安排试玩、拼车、改期到店和特殊需求沟通，可直接在后台分配房间并回复用户。</p>
            </div>
            <%-- 列表容器：承载 Repeater 渲染出的多条业务卡片。 --%>
            <div class="reservation-list">
                <%-- 数据列表控件 rptStoreVisitRequests：后台绑定集合数据后，按 ItemTemplate 循环渲染每条记录。 --%>
                <asp:Repeater ID="rptStoreVisitRequests" runat="server" OnItemCommand="rptStoreVisitRequests_ItemCommand">
                    <%-- 列表项模板：定义 Repeater 中每一条业务记录的 HTML 结构和绑定字段。 --%>
                    <ItemTemplate>
                        <%-- 业务卡片：展示一条预约、审核、消息或统计记录。 --%>
                        <article class="reservation-card">
                            <span class="badge-inline soft"><%# DisplayStoreVisitStatus(Eval("RequestStatus")) %></span>
                            <h3><%# Eval("ContactName") %> · <%# Eval("ScriptName") %></h3>
                            <p>到店时间：<%# Eval("PreferredArriveTime", "{0:yyyy-MM-dd HH:mm}") %> · 人数：<%# Eval("TeamSize") %> · 手机：<%# Eval("PhoneMasked") %></p>
                            <p>用户备注：<%# Eval("Note") %></p>
                            <%-- 输入控件 txtAssignedRoomName：接收用户输入或展示后台已有备注。 --%>
                            <asp:TextBox ID="txtAssignedRoomName" runat="server" CssClass="input-control" placeholder="安排房间" Text='<%# Eval("AssignedRoomName") %>' />
                            <%-- 输入控件 txtStoreRemark：接收用户输入或展示后台已有备注。 --%>
                            <asp:TextBox ID="txtStoreRemark" runat="server" CssClass="input-control" placeholder="后台备注" Text='<%# Eval("AdminRemark") %>' />
                            <%-- 输入控件 txtStoreReply：接收用户输入或展示后台已有备注。 --%>
                            <asp:TextBox ID="txtStoreReply" runat="server" CssClass="input-control textarea" TextMode="MultiLine" Rows="3" placeholder="回复用户" Text='<%# Eval("AdminReply") %>' />
                            <%-- 操作按钮区：集中放置提交、重置、跳转或审核动作。 --%>
                            <div class="hero-actions">
                                <%-- 操作按钮 btnArrangeStore：点击后触发后台事件处理当前业务动作。 --%>
                                <asp:Button ID="btnArrangeStore" runat="server" Text="安排排期" CssClass="btn-primary small" CommandName="ArrangeStore" CommandArgument='<%# Eval("Id") %>' CausesValidation="false" Visible='<%# !IsLockedStoreVisitStatus(Eval("RequestStatus")) %>' />
                                <%-- 操作按钮 btnCompleteStore：点击后触发后台事件处理当前业务动作。 --%>
                                <asp:Button ID="btnCompleteStore" runat="server" Text="登记到店完成" CssClass="btn-secondary small" CommandName="CompleteStore" CommandArgument='<%# Eval("Id") %>' CausesValidation="false" Visible='<%# !IsLockedStoreVisitStatus(Eval("RequestStatus")) %>' />
                                <%-- 操作按钮 btnCloseStore：点击后触发后台事件处理当前业务动作。 --%>
                                <asp:Button ID="btnCloseStore" runat="server" Text="驳回/关闭" CssClass="btn-secondary small" CommandName="CloseStore" CommandArgument='<%# Eval("Id") %>' CausesValidation="false" Visible='<%# !IsLockedStoreVisitStatus(Eval("RequestStatus")) %>' />
                            </div>
                            <asp:PlaceHolder runat="server" Visible='<%# IsLockedStoreVisitStatus(Eval("RequestStatus")) %>'>
                                <p class="inline-note">该联系单已进入终态，不能重复登记或关闭。</p>
                            </asp:PlaceHolder>
                        </article>
                    </ItemTemplate>
                </asp:Repeater>
            </div>
        </div>
    </section>

    <%-- 主要内容区：承载当前页面的核心业务列表、表单或详情内容。 --%>
    <section class="section-block" id="reservation-orders">
        <div class="container">
            <%-- 模块标题区：说明当前业务模块的名称和处理说明。 --%>
            <div class="section-heading left">
                <h2>预约订单履约</h2>
                <p>确认订单、登记到店、取消订单和服务会话跳转都在这里处理。</p>
            </div>
            <%-- 列表容器：承载 Repeater 渲染出的多条业务卡片。 --%>
            <div class="reservation-list">
                <%-- 数据列表控件 rptReservationOrders：后台绑定集合数据后，按 ItemTemplate 循环渲染每条记录。 --%>
                <asp:Repeater ID="rptReservationOrders" runat="server" OnItemCommand="rptReservationOrders_ItemCommand">
                    <%-- 列表项模板：定义 Repeater 中每一条业务记录的 HTML 结构和绑定字段。 --%>
                    <ItemTemplate>
                        <%-- 业务卡片：展示一条预约、审核、消息或统计记录。 --%>
                        <article class="reservation-card">
                            <span class="badge-inline"><%# DisplayReservationStatus(Eval("Status")) %></span>
                            <h3>订单 #<%# Eval("Id") %> · <%# Eval("ScriptName") %></h3>
                            <p>联系人：<%# Eval("ContactName") %> · 手机：<%# Eval("PhoneMasked") %> · 房间：<%# Eval("RoomName") %></p>
                            <p>开场：<%# Eval("SessionDateTime", "{0:yyyy-MM-dd HH:mm}") %> · 人数：<%# Eval("PlayerCount") %> · 支付：<%# Eval("PaymentStatus") %></p>
                            <p>核销码：<%# Eval("CheckInCode") %></p>
                            <%-- 输入控件 txtReservationRemark：接收用户输入或展示后台已有备注。 --%>
                            <asp:TextBox ID="txtReservationRemark" runat="server" CssClass="input-control" placeholder="后台备注" Text='<%# Eval("AdminRemark") %>' />
                            <%-- 输入控件 txtReservationReply：接收用户输入或展示后台已有备注。 --%>
                            <asp:TextBox ID="txtReservationReply" runat="server" CssClass="input-control textarea" TextMode="MultiLine" Rows="3" placeholder="回复用户" Text='<%# Eval("AdminReply") %>' />
                            <%-- 操作按钮区：集中放置提交、重置、跳转或审核动作。 --%>
                            <div class="hero-actions">
                                <%-- 操作按钮 btnConfirmReservation：点击后触发后台事件处理当前业务动作。 --%>
                                <asp:Button ID="btnConfirmReservation" runat="server" Text="确认预约" CssClass="btn-primary small" CommandName="ConfirmReservation" CommandArgument='<%# Eval("Id") %>' CausesValidation="false" Visible='<%# !IsLockedReservationStatus(Eval("Status")) %>' />
                                <%-- 操作按钮 btnArriveReservation：点击后触发后台事件处理当前业务动作。 --%>
                                <asp:Button ID="btnArriveReservation" runat="server" Text="登记到店" CssClass="btn-secondary small" CommandName="ArriveReservation" CommandArgument='<%# Eval("Id") %>' CausesValidation="false" Visible='<%# !IsLockedReservationStatus(Eval("Status")) %>' />
                                <%-- 操作按钮 btnCancelReservation：点击后触发后台事件处理当前业务动作。 --%>
                                <asp:Button ID="btnCancelReservation" runat="server" Text="取消订单" CssClass="btn-secondary small" CommandName="CancelReservation" CommandArgument='<%# Eval("Id") %>' CausesValidation="false" Visible='<%# !IsLockedReservationStatus(Eval("Status")) %>' OnClientClick="return confirm('确认取消这条预约订单吗？取消后会从当前履约列表移出，并释放占用名额。');" />
                                <%-- 跳转链接控件：根据绑定数据生成详情页、沟通页或外部页面入口。 --%>
                                <asp:HyperLink runat="server" CssClass="btn-secondary small" NavigateUrl='<%# "OrderDetails.aspx?reservationId=" + Eval("Id") %>' Text="订单详情" />
                                <%-- 跳转链接控件：根据绑定数据生成详情页、沟通页或外部页面入口。 --%>
                                <asp:HyperLink runat="server" CssClass="btn-secondary small" NavigateUrl='<%# "OrderConversation.aspx?reservationId=" + Eval("Id") %>' Text="订单沟通" />
                                <%-- 跳转链接控件：管理员可以用该预约作为场次入口直接进入主持控制台。 --%>
                                <asp:HyperLink runat="server" CssClass="btn-primary small" NavigateUrl='<%# "GameRoom.aspx?reservationId=" + Eval("Id") + "&host=1" %>' Text="主持房间" Visible='<%# !IsLockedReservationStatus(Eval("Status")) %>' />
                                <asp:Button ID="btnDeleteReservation" runat="server" Text="删除订单" CssClass="btn-secondary small danger-button" CommandName="DeleteReservation" CommandArgument='<%# Eval("Id") %>' CausesValidation="false" Visible='<%# IsDeletableReservationStatus(Eval("Status")) %>' OnClientClick="return confirm('确认永久删除这条已取消或已完成的订单吗？相关房间消息、投票、角色分配、订单沟通、评价和售后记录也会一并删除。');" />
                            </div>
                        </article>
                    </ItemTemplate>
                </asp:Repeater>
            </div>
        </div>
    </section>

    <%-- 次级内容区：用于承载筛选、配置、辅助列表或补充信息。 --%>
    <section class="section-block alt" id="after-sale-admin">
        <div class="container">
            <%-- 模块标题区：说明当前业务模块的名称和处理说明。 --%>
            <div class="section-heading left">
                <h2>售后与退款</h2>
                <p>处理退款、投诉、改期协商和二次申诉，证据、时间线和处理意见都集中展示。</p>
            </div>
            <%-- 列表容器：承载 Repeater 渲染出的多条业务卡片。 --%>
            <div class="reservation-list">
                <%-- 数据列表控件 rptAfterSaleRequests：后台绑定集合数据后，按 ItemTemplate 循环渲染每条记录。 --%>
                <asp:Repeater ID="rptAfterSaleRequests" runat="server" OnItemCommand="rptAfterSaleRequests_ItemCommand">
                    <%-- 列表项模板：定义 Repeater 中每一条业务记录的 HTML 结构和绑定字段。 --%>
                    <ItemTemplate>
                        <%-- 业务卡片：展示一条预约、审核、消息或统计记录。 --%>
                        <article class="reservation-card">
                            <span class="badge-inline warning"><%# Eval("Status") %></span>
                            <h3>售后 #<%# Eval("Id") %> · 订单 #<%# Eval("ReservationId") %></h3>
                            <p><%# Eval("ContactName") %> · <%# Eval("ScriptName") %> / <%# Eval("RoomName") %> / <%# Eval("SessionDateTime", "{0:MM-dd HH:mm}") %></p>
                            <p>类型：<%# Eval("RequestType") %> · 申请金额：￥<%# Eval("RequestedAmount", "{0:F2}") %> · 已退：￥<%# Eval("RefundedAmount", "{0:F2}") %></p>
                            <p>原因：<%# Eval("Reason") %></p>
                            <div class="service-timeline"><%# DisplayAfterSaleTimeline(Container.DataItem) %></div>
                            <%# DisplayAfterSaleEvidence(Eval("EvidenceUrl")) %>
                            <%-- 下拉控件 ddlAfterSaleStatus：提供状态、分类或角色等固定选项。 --%>
                            <asp:DropDownList ID="ddlAfterSaleStatus" runat="server" CssClass="input-control">
                                <asp:ListItem Text="已受理" Value="已受理" />
                                <asp:ListItem Text="待复审" Value="待复审" />
                                <asp:ListItem Text="退款完成" Value="退款完成" />
                                <asp:ListItem Text="已驳回" Value="已驳回" />
                                <asp:ListItem Text="已关闭" Value="已关闭" />
                            </asp:DropDownList>
                            <%-- 输入控件 txtAfterSaleReply：接收用户输入或展示后台已有备注。 --%>
                            <asp:TextBox ID="txtAfterSaleReply" runat="server" CssClass="input-control textarea" TextMode="MultiLine" Rows="3" placeholder="回复用户" Text='<%# Eval("AdminReply") %>' />
                            <%-- 输入控件 txtAfterSaleRejectReason：接收用户输入或展示后台已有备注。 --%>
                            <asp:TextBox ID="txtAfterSaleRejectReason" runat="server" CssClass="input-control" placeholder="驳回原因" Text='<%# Eval("RejectReason") %>' />
                            <%-- 输入控件 txtAfterSaleRemark：接收用户输入或展示后台已有备注。 --%>
                            <asp:TextBox ID="txtAfterSaleRemark" runat="server" CssClass="input-control" placeholder="内部备注" Text='<%# Eval("AdminRemark") %>' />
                            <%-- 操作按钮区：集中放置提交、重置、跳转或审核动作。 --%>
                            <div class="hero-actions">
                                <%-- 操作按钮 btnReviewAfterSale：点击后触发后台事件处理当前业务动作。 --%>
                                <asp:Button ID="btnReviewAfterSale" runat="server" Text="提交售后处理" CssClass="btn-primary small" CommandName="ReviewAfterSale" CommandArgument='<%# Eval("Id") %>' CausesValidation="false" />
                            </div>
                        </article>
                    </ItemTemplate>
                </asp:Repeater>
            </div>
        </div>
    </section>

    <%-- 主要内容区：承载当前页面的核心业务列表、表单或详情内容。 --%>
    <section class="section-block">
        <div class="container split-grid detail-split">
            <%-- 信息面板：承载一个独立的业务说明、列表或表单模块。 --%>
            <article class="about-panel">
                <%-- 模块标题区：说明当前业务模块的名称和处理说明。 --%>
                <div class="section-heading left">
                    <h2>优惠券发放</h2>
                    <p>补贴老客、活动用户和评价补偿都可以通过后台发券完成。</p>
                </div>
                <%-- 表单网格：按响应式布局排列输入框、下拉框和筛选条件。 --%>
                <div class="form-grid">
                    <div class="field-group"><label for="<%= ddlCouponUser.ClientID %>">发放用户</label><asp:DropDownList ID="ddlCouponUser" runat="server" CssClass="input-control" /></div>
                    <div class="field-group"><label for="<%= txtCouponTitle.ClientID %>">优惠券标题</label><asp:TextBox ID="txtCouponTitle" runat="server" CssClass="input-control" /></div>
                    <div class="field-group"><label for="<%= txtCouponAmount.ClientID %>">抵扣金额</label><asp:TextBox ID="txtCouponAmount" runat="server" CssClass="input-control" /></div>
                    <div class="field-group"><label for="<%= txtCouponMinSpend.ClientID %>">最低消费</label><asp:TextBox ID="txtCouponMinSpend" runat="server" CssClass="input-control" /></div>
                    <div class="field-group"><label for="<%= txtCouponValidDays.ClientID %>">有效天数</label><asp:TextBox ID="txtCouponValidDays" runat="server" CssClass="input-control" /></div>
                    <div class="field-group"><label for="<%= txtCouponSource.ClientID %>">发券来源</label><asp:TextBox ID="txtCouponSource" runat="server" CssClass="input-control" placeholder="如：复购召回 / 差评安抚" /></div>
                </div>
                <%-- 操作按钮区：集中放置提交、重置、跳转或审核动作。 --%>
                <div class="hero-actions">
                    <%-- 操作按钮 btnIssueCoupon：点击后触发后台事件处理当前业务动作。 --%>
                    <asp:Button ID="btnIssueCoupon" runat="server" Text="发放优惠券" CssClass="btn-primary" OnClick="btnIssueCoupon_Click" />
                </div>
                <%-- 列表容器：承载 Repeater 渲染出的多条业务卡片。 --%>
                <div class="reservation-list top-gap">
                    <%-- 数据列表控件 rptRecentCoupons：后台绑定集合数据后，按 ItemTemplate 循环渲染每条记录。 --%>
                    <asp:Repeater ID="rptRecentCoupons" runat="server">
                        <%-- 列表项模板：定义 Repeater 中每一条业务记录的 HTML 结构和绑定字段。 --%>
                        <ItemTemplate>
                            <%-- 业务卡片：展示一条预约、审核、消息或统计记录。 --%>
                            <article class="reservation-card">
                                <h3><%# Eval("Title") %> · ￥<%# Eval("DiscountAmount", "{0:F2}") %></h3>
                                <p>用户：<%# Eval("UserDisplayName") %> · 状态：<%# Eval("Status") %></p>
                                <p>门槛：￥<%# Eval("MinSpend", "{0:F2}") %> · 有效期至 <%# Eval("ValidUntil", "{0:yyyy-MM-dd}") %></p>
                            </article>
                        </ItemTemplate>
                    </asp:Repeater>
                </div>
            </article>

            <%-- 信息面板：承载一个独立的业务说明、列表或表单模块。 --%>
            <article class="about-panel" id="service-message-admin">
                <%-- 模块标题区：说明当前业务模块的名称和处理说明。 --%>
                <div class="section-heading left">
                    <h2>核销与服务消息</h2>
                    <p>支持前台输入核销码登记到店，也能统一查看用户与管理员围绕订单的连续消息。</p>
                </div>
                <%-- 操作按钮区：集中放置提交、重置、跳转或审核动作。 --%>
                <div class="hero-actions">
                    <%-- 输入控件 txtCheckInCode：接收用户输入或展示后台已有备注。 --%>
                    <asp:TextBox ID="txtCheckInCode" runat="server" CssClass="input-control" placeholder="输入预约核销码" />
                    <%-- 操作按钮 btnCheckInReservation：点击后触发后台事件处理当前业务动作。 --%>
                    <asp:Button ID="btnCheckInReservation" runat="server" Text="核销到店" CssClass="btn-primary" OnClick="btnCheckInReservation_Click" />
                </div>
                <%-- 列表容器：承载 Repeater 渲染出的多条业务卡片。 --%>
                <div class="reservation-list top-gap">
                    <%-- 数据列表控件 rptServiceMessages：后台绑定集合数据后，按 ItemTemplate 循环渲染每条记录。 --%>
                    <asp:Repeater ID="rptServiceMessages" runat="server" OnItemCommand="rptServiceMessages_ItemCommand">
                        <%-- 列表项模板：定义 Repeater 中每一条业务记录的 HTML 结构和绑定字段。 --%>
                        <ItemTemplate>
                            <%-- 业务卡片：展示一条预约、审核、消息或统计记录。 --%>
                            <article class="reservation-card">
                                <span class="badge-inline soft"><%# DisplayBusinessType(Eval("BusinessType")) %></span>
                                <h3><%# Eval("SenderName") %> · <%# Eval("CreatedAt", "{0:yyyy-MM-dd HH:mm}") %></h3>
                                <p>角色：<%# Eval("SenderRole") %> · 业务编号：<%# Eval("BusinessId") %></p>
                                <p><%# Eval("Content") %></p>
                                <%-- 输入控件 txtServiceReply：接收用户输入或展示后台已有备注。 --%>
                                <asp:TextBox ID="txtServiceReply" runat="server" CssClass="input-control textarea" TextMode="MultiLine" Rows="3" placeholder="回复本条服务会话" />
                                <%-- 操作按钮区：集中放置提交、重置、跳转或审核动作。 --%>
                                <div class="hero-actions">
                                    <%-- 操作按钮 btnReplyService：点击后触发后台事件处理当前业务动作。 --%>
                                    <asp:Button ID="btnReplyService" runat="server" Text="发送回复" CssClass="btn-primary small" CommandName="ReplyService" CommandArgument='<%# Eval("BusinessType") + "|" + Eval("BusinessId") %>' CausesValidation="false" />
                                    <%-- 跳转链接控件：根据绑定数据生成详情页、沟通页或外部页面入口。 --%>
                                    <asp:HyperLink runat="server" CssClass="btn-secondary small" NavigateUrl='<%# GetBusinessConversationUrl(Eval("BusinessType"), Eval("BusinessId")) %>' Visible='<%# HasBusinessConversation(Eval("BusinessType")) %>' Text="查看订单会话" />
                                </div>
                            </article>
                        </ItemTemplate>
                    </asp:Repeater>
                </div>
            </article>
        </div>
    </section>

    <%-- 次级内容区：用于承载筛选、配置、辅助列表或补充信息。 --%>
    <section class="section-block alt" id="announcements-admin">
        <div class="container split-grid detail-split">
            <%-- 信息面板：承载一个独立的业务说明、列表或表单模块。 --%>
            <article class="about-panel">
                <%-- 模块标题区：说明当前业务模块的名称和处理说明。 --%>
                <div class="section-heading left">
                    <h2>评价管理</h2>
                    <p>查看订单绑定评价、处理低分反馈，并决定是否精选展示或隐藏。</p>
                </div>
                <%-- 统计网格：集中展示多个关键业务指标。 --%>
                <div class="analytics-kpi-grid">
                    <div class="analytics-stat-card"><p>评价总数</p><strong><asp:Literal ID="litReviewAdminTotal" runat="server" /></strong></div>
                    <div class="analytics-stat-card"><p>平均评分</p><strong><asp:Literal ID="litReviewAdminAverage" runat="server" /></strong></div>
                    <div class="analytics-stat-card"><p>低分待处理</p><strong><asp:Literal ID="litReviewLowPendingCount" runat="server" /></strong></div>
                    <div class="analytics-stat-card"><p>已绑订单</p><strong><asp:Literal ID="litReviewOrderBoundCount" runat="server" /></strong></div>
                </div>
                <%-- 列表容器：承载 Repeater 渲染出的多条业务卡片。 --%>
                <div class="reservation-list top-gap">
                    <%-- 数据列表控件 rptAdminReviews：后台绑定集合数据后，按 ItemTemplate 循环渲染每条记录。 --%>
                    <asp:Repeater ID="rptAdminReviews" runat="server" OnItemCommand="rptAdminReviews_ItemCommand">
                        <%-- 列表项模板：定义 Repeater 中每一条业务记录的 HTML 结构和绑定字段。 --%>
                        <ItemTemplate>
                            <%-- 业务卡片：展示一条预约、审核、消息或统计记录。 --%>
                            <article class="reservation-card">
                                <h3><%# Eval("ScriptName") %> · <%# Eval("ReviewerName") %> · <span class="rating-badge"><%# Eval("Rating") %>.0</span></h3>
                                <p><%# Eval("Content") %></p>
                                <p class="meta-copy">标签：<%# DisplayReviewTags(Eval("HighlightTag")) %></p>
                                <p class="meta-copy"><%# DisplayReviewBinding(Container.DataItem) %></p>
                                <label><asp:CheckBox ID="chkReviewFeatured" runat="server" Checked='<%# Eval("IsFeatured") %>' /> 精选展示</label>
                                <label><asp:CheckBox ID="chkReviewHidden" runat="server" Checked='<%# Eval("IsHidden") %>' /> 隐藏评价</label>
                                <%-- 输入控件 txtReviewReply：接收用户输入或展示后台已有备注。 --%>
                                <asp:TextBox ID="txtReviewReply" runat="server" CssClass="input-control textarea" TextMode="MultiLine" Rows="3" placeholder="管理员回复评价" Text='<%# Eval("AdminReply") %>' />
                                <%-- 操作按钮区：集中放置提交、重置、跳转或审核动作。 --%>
                                <div class="hero-actions">
                                    <%-- 操作按钮 btnModerateReview：点击后触发后台事件处理当前业务动作。 --%>
                                    <asp:Button ID="btnModerateReview" runat="server" Text="保存评价处理" CssClass="btn-primary small" CommandName="ModerateReview" CommandArgument='<%# Eval("Id") %>' CausesValidation="false" />
                                </div>
                            </article>
                        </ItemTemplate>
                    </asp:Repeater>
                </div>
            </article>

            <%-- 信息面板：承载一个独立的业务说明、列表或表单模块。 --%>
            <article class="about-panel">
                <%-- 模块标题区：说明当前业务模块的名称和处理说明。 --%>
                <div class="section-heading left">
                    <h2>回复日志与业务动作</h2>
                    <p>记录管理员对外回复和关键业务操作，方便答辩时展示后台痕迹链路。</p>
                </div>
                <%-- 列表容器：承载 Repeater 渲染出的多条业务卡片。 --%>
                <div class="reservation-list">
                    <%-- 数据列表控件 rptAdminReplyLogs：后台绑定集合数据后，按 ItemTemplate 循环渲染每条记录。 --%>
                    <asp:Repeater ID="rptAdminReplyLogs" runat="server">
                        <%-- 列表项模板：定义 Repeater 中每一条业务记录的 HTML 结构和绑定字段。 --%>
                        <ItemTemplate>
                            <%-- 业务卡片：展示一条预约、审核、消息或统计记录。 --%>
                            <article class="reservation-card">
                                <h3><%# Eval("AdminName") %> · <%# Eval("CreatedAt", "{0:yyyy-MM-dd HH:mm}") %></h3>
                                <p>业务：<%# DisplayBusinessType(Eval("BusinessType")) %> #<%# Eval("BusinessId") %></p>
                                <p><%# Eval("ReplyContent") %></p>
                            </article>
                        </ItemTemplate>
                    </asp:Repeater>
                    <%-- 数据列表控件 rptBusinessActionLogs：后台绑定集合数据后，按 ItemTemplate 循环渲染每条记录。 --%>
                    <asp:Repeater ID="rptBusinessActionLogs" runat="server">
                        <%-- 列表项模板：定义 Repeater 中每一条业务记录的 HTML 结构和绑定字段。 --%>
                        <ItemTemplate>
                            <%-- 业务卡片：展示一条预约、审核、消息或统计记录。 --%>
                            <article class="reservation-card">
                                <h3><%# Eval("ActionTitle") %> · <%# Eval("CreatedAt", "{0:yyyy-MM-dd HH:mm}") %></h3>
                                <p>操作人：<%# Eval("OperatorName") %> · 业务：<%# DisplayBusinessType(Eval("BusinessType")) %> #<%# Eval("BusinessId") %></p>
                                <p><%# Eval("ActionContent") %></p>
                            </article>
                        </ItemTemplate>
                    </asp:Repeater>
                </div>
            </article>
        </div>
    </section>

    <%-- 主要内容区：承载当前页面的核心业务列表、表单或详情内容。 --%>
    <section class="section-block" id="room-session-admin">
        <div class="container split-grid detail-split">
            <%-- 信息面板：承载一个独立的业务说明、列表或表单模块。 --%>
            <article class="about-panel">
                <%-- 模块标题区：说明当前业务模块的名称和处理说明。 --%>
                <div class="section-heading left">
                    <h2>创建排期与 DM 协同</h2>
                    <p>管理员可以直接创建场次、指定房间和主持人，并同步主持备注。</p>
                </div>
                <%-- 表单网格：按响应式布局排列输入框、下拉框和筛选条件。 --%>
                <asp:Panel ID="pnlScheduleInlineMessage" runat="server" Visible="false" CssClass="status-message schedule-message">
                    <asp:Literal ID="litScheduleInlineMessage" runat="server" />
                </asp:Panel>
                <div class="form-grid">
                    <div class="field-group"><label for="<%= ddlScheduleScript.ClientID %>">剧本</label><asp:DropDownList ID="ddlScheduleScript" runat="server" CssClass="input-control" /></div>
                    <div class="field-group"><label for="<%= ddlScheduleRoom.ClientID %>">房间</label><asp:DropDownList ID="ddlScheduleRoom" runat="server" CssClass="input-control" /></div>
                    <div class="field-group"><label for="<%= txtScheduleDateTime.ClientID %>">开场时间</label><asp:TextBox ID="txtScheduleDateTime" runat="server" CssClass="input-control" /></div>
                    <div class="field-group"><label for="<%= txtScheduleHostName.ClientID %>">主持名称</label><asp:TextBox ID="txtScheduleHostName" runat="server" CssClass="input-control" /></div>
                    <div class="field-group"><label for="<%= ddlScheduleDm.ClientID %>">绑定 DM</label><asp:DropDownList ID="ddlScheduleDm" runat="server" CssClass="input-control" /></div>
                    <div class="field-group"><label for="<%= txtSchedulePrice.ClientID %>">人均价格</label><asp:TextBox ID="txtSchedulePrice" runat="server" CssClass="input-control" /></div>
                    <div class="field-group"><label for="<%= txtScheduleMaxPlayers.ClientID %>">最大人数</label><asp:TextBox ID="txtScheduleMaxPlayers" runat="server" CssClass="input-control" /></div>
                    <div class="field-group full"><label for="<%= txtScheduleBriefing.ClientID %>">主持备注</label><asp:TextBox ID="txtScheduleBriefing" runat="server" CssClass="input-control textarea" TextMode="MultiLine" Rows="3" /></div>
                </div>
                <%-- 操作按钮区：集中放置提交、重置、跳转或审核动作。 --%>
                <div class="hero-actions">
                    <%-- 操作按钮 btnCreateSession：点击后触发后台事件处理当前业务动作。 --%>
                    <asp:Button ID="btnCreateSession" runat="server" Text="创建排期场次" CssClass="btn-primary" OnClick="btnCreateSession_Click" CausesValidation="false" />
                </div>
            </article>

            <%-- 信息面板：承载一个独立的业务说明、列表或表单模块。 --%>
            <article class="about-panel">
                <%-- 模块标题区：说明当前业务模块的名称和处理说明。 --%>
                <div class="section-heading left">
                    <h2>房间状态</h2>
                    <p>可快速调整房间是否启用、维护或暂停接待，并同步展示未来场次数。</p>
                </div>
                <%-- 列表容器：承载 Repeater 渲染出的多条业务卡片。 --%>
                <div class="reservation-list">
                    <%-- 数据列表控件 rptAdminRooms：后台绑定集合数据后，按 ItemTemplate 循环渲染每条记录。 --%>
                    <asp:Repeater ID="rptAdminRooms" runat="server" OnItemCommand="rptAdminRooms_ItemCommand">
                        <%-- 列表项模板：定义 Repeater 中每一条业务记录的 HTML 结构和绑定字段。 --%>
                        <ItemTemplate>
                            <%-- 业务卡片：展示一条预约、审核、消息或统计记录。 --%>
                            <article class="reservation-card">
                                <h3><%# Eval("Name") %></h3>
                                <p>主题：<%# Eval("Theme") %> · 容量：<%# Eval("Capacity") %> · 状态：<%# Eval("Status") %></p>
                                <p><%# Eval("Description") %></p>
                                <%-- 操作按钮区：集中放置提交、重置、跳转或审核动作。 --%>
                                <div class="hero-actions">
                                    <%-- 操作按钮 btnEnableRoom：点击后触发后台事件处理当前业务动作。 --%>
                                    <asp:Button ID="btnEnableRoom" runat="server" Text="启用" CssClass="btn-primary small" CommandName="EnableRoom" CommandArgument='<%# Eval("Id") %>' CausesValidation="false" />
                                    <%-- 操作按钮 btnMaintainRoom：点击后触发后台事件处理当前业务动作。 --%>
                                    <asp:Button ID="btnMaintainRoom" runat="server" Text="维护" CssClass="btn-secondary small" CommandName="MaintainRoom" CommandArgument='<%# Eval("Id") %>' CausesValidation="false" />
                                    <%-- 操作按钮 btnPauseRoom：点击后触发后台事件处理当前业务动作。 --%>
                                    <asp:Button ID="btnPauseRoom" runat="server" Text="暂停接待" CssClass="btn-secondary small" CommandName="PauseRoom" CommandArgument='<%# Eval("Id") %>' CausesValidation="false" />
                                </div>
                            </article>
                        </ItemTemplate>
                    </asp:Repeater>
                </div>
            </article>
        </div>
    </section>

    <%-- 次级内容区：用于承载筛选、配置、辅助列表或补充信息。 --%>
    <section class="section-block alt">
        <div class="container split-grid detail-split">
            <%-- 信息面板：承载一个独立的业务说明、列表或表单模块。 --%>
            <article class="about-panel">
                <%-- 模块标题区：说明当前业务模块的名称和处理说明。 --%>
                <div class="section-heading left">
                    <h2>已创建场次</h2>
                    <p>核对剧本、房间、主持人和剩余席位，避免排期信息和履约信息脱节。</p>
                </div>
                <%-- 列表容器：承载 Repeater 渲染出的多条业务卡片。 --%>
                <div class="reservation-list">
                    <%-- 数据列表控件 rptAdminSessions：后台绑定集合数据后，按 ItemTemplate 循环渲染每条记录。 --%>
                    <asp:Repeater ID="rptAdminSessions" runat="server">
                        <%-- 列表项模板：定义 Repeater 中每一条业务记录的 HTML 结构和绑定字段。 --%>
                        <ItemTemplate>
                            <%-- 业务卡片：展示一条预约、审核、消息或统计记录。 --%>
                            <article class="reservation-card">
                                <h3><%# Eval("ScriptName") %> / <%# Eval("RoomName") %></h3>
                                <p>开场：<%# Eval("SessionDateTime", "{0:yyyy-MM-dd HH:mm}") %> · 主持：<%# Eval("HostName") %></p>
                                <p>价格：￥<%# Eval("BasePrice", "{0:F2}") %> · 人数 <%# Eval("ReservedPlayers") %>/<%# Eval("MaxPlayers") %> · 状态：<%# Eval("Status") %></p>
                                <p class="meta-copy">主持备注：<%# Eval("HostBriefing") %></p>
                            </article>
                        </ItemTemplate>
                    </asp:Repeater>
                </div>
            </article>

            <%-- 信息面板：承载一个独立的业务说明、列表或表单模块。 --%>
            <article class="about-panel">
                <%-- 模块标题区：说明当前业务模块的名称和处理说明。 --%>
                <div class="section-heading left">
                    <h2>公告发布</h2>
                    <p>用于预约变更、节假日排期、活动上新和答辩时展示站内通知能力。</p>
                </div>
                <%-- 表单网格：按响应式布局排列输入框、下拉框和筛选条件。 --%>
                <div class="form-grid">
                    <div class="field-group"><label for="<%= txtAnnouncementTitle.ClientID %>">公告标题</label><asp:TextBox ID="txtAnnouncementTitle" runat="server" CssClass="input-control" /></div>
                    <div class="field-group full"><label for="<%= txtAnnouncementSummary.ClientID %>">公告摘要</label><asp:TextBox ID="txtAnnouncementSummary" runat="server" CssClass="input-control textarea" TextMode="MultiLine" Rows="3" /></div>
                    <div class="field-group"><label><asp:CheckBox ID="chkAnnouncementImportant" runat="server" /> 设为重要公告</label></div>
                </div>
                <%-- 操作按钮区：集中放置提交、重置、跳转或审核动作。 --%>
                <div class="hero-actions">
                    <%-- 操作按钮 btnPublishAnnouncement：点击后触发后台事件处理当前业务动作。 --%>
                    <asp:Button ID="btnPublishAnnouncement" runat="server" Text="发布公告" CssClass="btn-primary" OnClick="btnPublishAnnouncement_Click" />
                </div>
                <%-- 列表容器：承载 Repeater 渲染出的多条业务卡片。 --%>
                <div class="reservation-list top-gap">
                    <%-- 数据列表控件 rptAdminAnnouncements：后台绑定集合数据后，按 ItemTemplate 循环渲染每条记录。 --%>
                    <asp:Repeater ID="rptAdminAnnouncements" runat="server">
                        <%-- 列表项模板：定义 Repeater 中每一条业务记录的 HTML 结构和绑定字段。 --%>
                        <ItemTemplate>
                            <%-- 业务卡片：展示一条预约、审核、消息或统计记录。 --%>
                            <article class="reservation-card">
                                <span class='badge-inline <%# Convert.ToBoolean(Eval("IsImportant")) ? "warning" : "soft" %>'><%# Convert.ToBoolean(Eval("IsImportant")) ? "重要" : "普通" %></span>
                                <h3><%# Eval("Title") %></h3>
                                <p><%# Eval("Summary") %></p>
                                <small><%# Eval("PublishDate", "{0:yyyy-MM-dd HH:mm}") %></small>
                            </article>
                        </ItemTemplate>
                    </asp:Repeater>
                </div>
            </article>
        </div>
    </section>

    <%-- 主要内容区：承载当前页面的核心业务列表、表单或详情内容。 --%>
    <section class="section-block" id="script-admin">
        <div class="container split-grid detail-split">
            <%-- 信息面板：承载一个独立的业务说明、列表或表单模块。 --%>
            <article class="about-panel">
                <%-- 模块标题区：说明当前业务模块的名称和处理说明。 --%>
                <div class="section-heading left">
                    <h2>剧本审核</h2>
                    <p>处理创作者提交的剧本，确认后进入剧本库，驳回时保留审核意见。</p>
                </div>
                <%-- 列表容器：承载 Repeater 渲染出的多条业务卡片。 --%>
                <div class="reservation-list">
                    <%-- 数据列表控件 rptPendingScripts：后台绑定集合数据后，按 ItemTemplate 循环渲染每条记录。 --%>
                    <asp:Repeater ID="rptPendingScripts" runat="server" OnItemCommand="rptPendingScripts_ItemCommand">
                        <%-- 列表项模板：定义 Repeater 中每一条业务记录的 HTML 结构和绑定字段。 --%>
                        <ItemTemplate>
                            <%-- 业务卡片：展示一条预约、审核、消息或统计记录。 --%>
                            <article class="reservation-card">
                                <h3><%# Eval("Name") %></h3>
                                <p>作者：<%# Eval("CreatorDisplayName") %> · 类型：<%# Eval("GenreName") %> · 时长：<%# Eval("DurationMinutes") %> 分钟</p>
                                <p><%# Eval("Slogan") %></p>
                                <%-- 输入控件 txtScriptRemark：接收用户输入或展示后台已有备注。 --%>
                                <asp:TextBox ID="txtScriptRemark" runat="server" CssClass="input-control textarea" TextMode="MultiLine" Rows="3" placeholder="审核意见" Text='<%# Eval("AuditComment") %>' />
                                <%-- 操作按钮区：集中放置提交、重置、跳转或审核动作。 --%>
                                <div class="hero-actions">
                                    <%-- 操作按钮 btnApproveScript：点击后触发后台事件处理当前业务动作。 --%>
                                    <asp:Button ID="btnApproveScript" runat="server" Text="通过剧本" CssClass="btn-primary small" CommandName="ApproveScript" CommandArgument='<%# Eval("Id") %>' CausesValidation="false" />
                                    <%-- 操作按钮 btnRejectScript：点击后触发后台事件处理当前业务动作。 --%>
                                    <asp:Button ID="btnRejectScript" runat="server" Text="驳回剧本" CssClass="btn-secondary small" CommandName="RejectScript" CommandArgument='<%# Eval("Id") %>' CausesValidation="false" />
                                </div>
                            </article>
                        </ItemTemplate>
                    </asp:Repeater>
                </div>
            </article>

            <%-- 信息面板：承载一个独立的业务说明、列表或表单模块。 --%>
            <article class="about-panel">
                <%-- 模块标题区：说明当前业务模块的名称和处理说明。 --%>
                <div class="section-heading left">
                    <h2>剧本总览</h2>
                    <p>当前所有剧本的状态、评分、排期数和审核结果，可直接做下架和整理。</p>
                </div>
                <%-- 列表容器：承载 Repeater 渲染出的多条业务卡片。 --%>
                <div class="reservation-list">
                    <%-- 数据列表控件 rptAllScripts：后台绑定集合数据后，按 ItemTemplate 循环渲染每条记录。 --%>
                    <asp:Repeater ID="rptAllScripts" runat="server" OnItemCommand="rptAllScripts_ItemCommand">
                        <%-- 列表项模板：定义 Repeater 中每一条业务记录的 HTML 结构和绑定字段。 --%>
                        <ItemTemplate>
                            <%-- 业务卡片：展示一条预约、审核、消息或统计记录。 --%>
                            <article class="reservation-card">
                                <h3><%# Eval("Name") %></h3>
                                <p>状态：<%# Eval("Status") %> · 审核：<%# DisplayAuditStatus(Eval("AuditStatus")) %> · 评分：<%# Eval("AverageRating", "{0:F1}") %></p>
                                <p>排期：<%# Eval("UpcomingSessionCount") %> 场 · 评论：<%# Eval("ReviewCount") %> 条</p>
                                <%-- 操作按钮区：集中放置提交、重置、跳转或审核动作。 --%>
                                <div class="hero-actions">
                                    <%-- 跳转链接控件：根据绑定数据生成详情页、沟通页或外部页面入口。 --%>
                                    <asp:HyperLink runat="server" CssClass="btn-secondary small" NavigateUrl='<%# "ScriptDetails.aspx?id=" + Eval("Id") %>' Text="查看详情" />
                                    <%-- 操作按钮 btnDeleteScript：点击后触发后台事件处理当前业务动作。 --%>
                                    <asp:Button ID="btnDeleteScript" runat="server" Text="删除剧本" CssClass="btn-secondary small" CommandName="DeleteScript" CommandArgument='<%# Eval("Id") %>' OnClientClick="return confirm('确定删除这个剧本吗？');" CausesValidation="false" />
                                </div>
                            </article>
                        </ItemTemplate>
                    </asp:Repeater>
                </div>
            </article>
        </div>
    </section>

    <%-- 次级内容区：用于承载筛选、配置、辅助列表或补充信息。 --%>
    <section class="section-block alt">
        <div class="container split-grid detail-split">
            <%-- 信息面板：承载一个独立的业务说明、列表或表单模块。 --%>
            <article class="about-panel">
                <%-- 模块标题区：说明当前业务模块的名称和处理说明。 --%>
                <div class="section-heading left">
                    <h2>充值审核流水</h2>
                    <p>展示最近审核过的充值记录，便于核对是否都已经入账。</p>
                </div>
                <%-- 列表容器：承载 Repeater 渲染出的多条业务卡片。 --%>
                <div class="reservation-list">
                    <%-- 数据列表控件 rptRechargeAuditRecords：后台绑定集合数据后，按 ItemTemplate 循环渲染每条记录。 --%>
                    <asp:Repeater ID="rptRechargeAuditRecords" runat="server">
                        <%-- 列表项模板：定义 Repeater 中每一条业务记录的 HTML 结构和绑定字段。 --%>
                        <ItemTemplate>
                            <%-- 业务卡片：展示一条预约、审核、消息或统计记录。 --%>
                            <article class="reservation-card">
                                <h3><%# Eval("DisplayName") %> · ￥<%# Eval("Amount", "{0:F2}") %></h3>
                                <p>状态：<%# DisplayAuditStatus(Eval("RequestStatus")) %> · 方式：<%# DisplayPaymentMethod(Eval("PaymentMethod")) %></p>
                                <p>审核人：<%# Eval("ReviewedByName") %> · 时间：<%# Eval("ReviewedAt", "{0:yyyy-MM-dd HH:mm}") %></p>
                                <p><%# Eval("ReviewRemark") %></p>
                            </article>
                        </ItemTemplate>
                    </asp:Repeater>
                </div>
            </article>

            <%-- 信息面板：承载一个独立的业务说明、列表或表单模块。 --%>
            <article class="about-panel">
                <%-- 模块标题区：说明当前业务模块的名称和处理说明。 --%>
                <div class="section-heading left">
                    <h2>退款审核流水</h2>
                    <p>核对最近的退款处理结果、驳回原因和最终到账金额。</p>
                </div>
                <%-- 列表容器：承载 Repeater 渲染出的多条业务卡片。 --%>
                <div class="reservation-list">
                    <%-- 数据列表控件 rptRefundAuditRecords：后台绑定集合数据后，按 ItemTemplate 循环渲染每条记录。 --%>
                    <asp:Repeater ID="rptRefundAuditRecords" runat="server">
                        <%-- 列表项模板：定义 Repeater 中每一条业务记录的 HTML 结构和绑定字段。 --%>
                        <ItemTemplate>
                            <%-- 业务卡片：展示一条预约、审核、消息或统计记录。 --%>
                            <article class="reservation-card">
                                <h3>售后 #<%# Eval("Id") %> · <%# Eval("RequestType") %></h3>
                                <p>订单 #<%# Eval("ReservationId") %> · 状态：<%# Eval("Status") %></p>
                                <p>申请金额：￥<%# Eval("RequestedAmount", "{0:F2}") %> · 已退：￥<%# Eval("RefundedAmount", "{0:F2}") %></p>
                                <p><%# string.IsNullOrWhiteSpace(Convert.ToString(Eval("RejectReason"))) ? Eval("AdminReply") : Eval("RejectReason") %></p>
                            </article>
                        </ItemTemplate>
                    </asp:Repeater>
                </div>
            </article>
        </div>
    </section>

    <%-- 主要内容区：承载当前页面的核心业务列表、表单或详情内容。 --%>
    <section class="section-block">
        <div class="container">
            <%-- 模块标题区：说明当前业务模块的名称和处理说明。 --%>
            <div class="section-heading left">
                <h2>钱包流水审计</h2>
                <p>展示最近的余额变更，异常流水会带出审计备注，方便答辩时说明财务闭环。</p>
            </div>
            <%-- 列表容器：承载 Repeater 渲染出的多条业务卡片。 --%>
            <div class="reservation-list">
                <%-- 数据列表控件 rptAdminWalletTransactions：后台绑定集合数据后，按 ItemTemplate 循环渲染每条记录。 --%>
                <asp:Repeater ID="rptAdminWalletTransactions" runat="server">
                    <%-- 列表项模板：定义 Repeater 中每一条业务记录的 HTML 结构和绑定字段。 --%>
                    <ItemTemplate>
                        <%-- 业务卡片：展示一条预约、审核、消息或统计记录。 --%>
                        <article class="reservation-card">
                            <span class='badge-inline <%# Convert.ToBoolean(Eval("IsAnomaly")) ? "warning" : "soft" %>'><%# Convert.ToBoolean(Eval("IsAnomaly")) ? "异常" : "正常" %></span>
                            <h3><%# Eval("UserDisplayName") %> · <%# Eval("TransactionType") %></h3>
                            <p>金额：￥<%# Eval("Amount", "{0:F2}") %> · 余额：￥<%# Eval("BalanceAfter", "{0:F2}") %></p>
                            <p><%# Eval("Summary") %></p>
                            <small><%# Eval("CreatedAt", "{0:yyyy-MM-dd HH:mm}") %> · <%# Eval("AuditNote") %></small>
                        </article>
                    </ItemTemplate>
                </asp:Repeater>
            </div>
        </div>
    </section>
</asp:Content>
