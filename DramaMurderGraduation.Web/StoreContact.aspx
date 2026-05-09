<%@ Page Title="门店联系 | 剧本杀系统" Language="C#" MasterPageFile="~/Site.Master" AutoEventWireup="true" CodeBehind="StoreContact.aspx.cs" Inherits="DramaMurderGraduation.Web.StoreContactPage" %>
<%-- 页面用途：StoreContact 页面负责承载对应功能的 Web Forms 标记、服务端控件和前端布局。 --%>
<asp:Content ID="TitleStoreContact" ContentPlaceHolderID="TitleContent" runat="server">
    门店联系 | 剧本杀系统
</asp:Content>
<asp:Content ID="MainStoreContact" ContentPlaceHolderID="MainContent" runat="server">
    <%-- 页面分区：把当前页面内容按业务模块拆分展示。 --%>
    <section class="inner-hero">
        <div class="container">
            <p class="eyebrow">Store Concierge</p>
            <h1>联系线下门店</h1>
            <p>线上选本、充值支付、提交到店需求后，门店会按你的剧本和人数安排真实开本。</p>
        </div>
    </section>

    <%-- 主要内容区：承载当前页面的核心业务列表、表单或详情内容。 --%>
    <section class="section-block">
        <div class="container split-grid detail-split">
            <%-- 信息面板：承载一个独立的业务说明、列表或表单模块。 --%>
            <article class="about-panel">
                <%-- 模块标题区：说明当前业务模块的名称和处理说明。 --%>
                <div class="section-heading left">
                    <h2>门店信息</h2>
                    <p>这里展示当前门店的营业信息，也把线上流程和线下到店衔接在一起。</p>
                </div>

                <div class="lobby-summary-list">
                    <div class="lobby-summary-item">
                        <span>门店名称</span>
                        <strong><asp:Literal ID="litStoreName" runat="server" /></strong>
                    </div>
                    <div class="lobby-summary-item">
                        <span>门店地址</span>
                        <strong><asp:Literal ID="litStoreAddress" runat="server" /></strong>
                    </div>
                    <div class="lobby-summary-item">
                        <span>营业时间</span>
                        <strong><asp:Literal ID="litBusinessHours" runat="server" /></strong>
                    </div>
                    <div class="lobby-summary-item">
                        <span>联系电话</span>
                        <strong><asp:Literal ID="litPhone" runat="server" /></strong>
                    </div>
                    <div class="lobby-summary-item">
                        <span>联系账号</span>
                        <strong><asp:Literal ID="litWeChat" runat="server" /></strong>
                    </div>
                    <div class="lobby-summary-item">
                        <span>推荐场次</span>
                        <strong><asp:Literal ID="litRecommendedSession" runat="server" /></strong>
                    </div>
                </div>

                <div class="mini-card-grid store-link-grid">
                    <a class="metric-card click-card interactive-card" href="ScriptsList.aspx">
                        <p>线上选剧本</p>
                        <strong>查看全部剧本</strong>
                    </a>
                    <a class="metric-card click-card interactive-card" href="Wallet.aspx">
                        <p>线上充值支付</p>
                        <strong>进入钱包中心</strong>
                    </a>
                    <a class="metric-card click-card interactive-card" href="Booking.aspx">
                        <p>线上预约场次</p>
                        <strong>选择开本时间</strong>
                    </a>
                    <a class="metric-card accent click-card interactive-card" href="Rooms.aspx">
                        <p>查看线下房间</p>
                        <strong>了解主题房间</strong>
                    </a>
                </div>
            </article>

            <%-- 表单面板：承载筛选条件或业务提交输入项。 --%>
            <article class="form-panel">
                <%-- 模块标题区：说明当前业务模块的名称和处理说明。 --%>
                <div class="section-heading left">
                    <h2>提交到店需求</h2>
                    <p>提交后会生成门店联系单，方便门店确认剧本、人数、时间和房间安排。</p>
                </div>

                <%-- 面板控件 pnlMessage：后台可通过 Visible/CssClass 控制整块内容是否显示以及提示样式。 --%>
                <asp:Panel ID="pnlMessage" runat="server" Visible="false" CssClass="status-message">
                    <asp:Literal ID="litMessage" runat="server" />
                </asp:Panel>

                <%-- 面板控件 pnlAdminStoreManager：后台可通过 Visible/CssClass 控制整块内容是否显示以及提示样式。 --%>
                <asp:Panel ID="pnlAdminStoreManager" runat="server" Visible="false" CssClass="admin-contact-panel">
                    <%-- 模块标题区：说明当前业务模块的名称和处理说明。 --%>
                    <div class="section-heading left compact">
                        <h2>管理员审核玩家到店需求</h2>
                        <p>玩家从门店联系提交的剧本、人数、到店时间和备注会汇总在这里，管理员可以审核安排并线上回复玩家。</p>
                    </div>
                    <%-- 表单网格：按响应式布局排列输入框、下拉框和筛选条件。 --%>
                    <div class="form-grid compact-filter-grid">
                        <div class="field-group">
                            <label for="<%= txtAdminStoreKeyword.ClientID %>">搜索需求</label>
                            <%-- 输入控件 txtAdminStoreKeyword：接收用户输入或展示后台已有备注。 --%>
                            <asp:TextBox ID="txtAdminStoreKeyword" runat="server" CssClass="input-control" placeholder="联系人 / 电话 / 剧本 / 房间" />
                        </div>
                        <div class="field-group">
                            <label for="<%= ddlAdminStoreStatus.ClientID %>">处理状态</label>
                            <%-- 下拉控件 ddlAdminStoreStatus：提供状态、分类或角色等固定选项。 --%>
                            <asp:DropDownList ID="ddlAdminStoreStatus" runat="server" CssClass="input-control" />
                        </div>
                    </div>
                    <%-- 操作按钮区：集中放置提交、重置、跳转或审核动作。 --%>
                    <div class="hero-actions">
                        <%-- 操作按钮 btnFilterAdminStoreRequests：点击后触发后台事件处理当前业务动作。 --%>
                        <asp:Button ID="btnFilterAdminStoreRequests" runat="server" Text="筛选联系单" CssClass="btn-primary" OnClick="btnFilterAdminStoreRequests_Click" />
                        <%-- 操作按钮 btnResetAdminStoreRequests：点击后触发后台事件处理当前业务动作。 --%>
                        <asp:Button ID="btnResetAdminStoreRequests" runat="server" Text="重置" CssClass="btn-secondary" OnClick="btnResetAdminStoreRequests_Click" />
                    </div>

                    <div class="admin-list compact-admin-list">
                        <%-- 数据列表控件 rptAdminStoreRequests：后台绑定集合数据后，按 ItemTemplate 循环渲染每条记录。 --%>
                        <asp:Repeater ID="rptAdminStoreRequests" runat="server" OnItemCommand="rptAdminStoreRequests_ItemCommand">
                            <%-- 列表项模板：定义 Repeater 中每一条业务记录的 HTML 结构和绑定字段。 --%>
                            <ItemTemplate>
                                <%-- 内容卡片：用于组织当前模块中的一组相关信息。 --%>
                                <article class="admin-card">
                                    <div class="admin-card-main">
                                        <h3><%# Eval("ScriptName") %></h3>
                                        <p>玩家需求：<%# Eval("ContactName") %> / <%# Eval("Phone") %> / <%# Eval("TeamSize") %> 人</p>
                                        <p>到店时间：<%# Eval("PreferredArriveTime", "{0:yyyy-MM-dd HH:mm}") %> / 状态：<%# Eval("RequestStatus") %></p>
                                        <p><%# string.IsNullOrWhiteSpace(Convert.ToString(Eval("Note"))) ? "玩家没有填写额外备注。" : Eval("Note") %></p>
                                        <p class="meta-copy">已回复：<%# string.IsNullOrWhiteSpace(Convert.ToString(Eval("AdminReply"))) ? "尚未回复玩家" : Eval("AdminReply") %></p>
                                        <small>玩家确认：<%# string.IsNullOrWhiteSpace(Convert.ToString(Eval("ConfirmStatus"))) ? "未确认" : Eval("ConfirmStatus") %> <%# string.IsNullOrWhiteSpace(Convert.ToString(Eval("PlayerConfirmRemark"))) ? string.Empty : " / " + Eval("PlayerConfirmRemark") %></small>
                                    </div>
                                    <div class="admin-card-side">
                                        <%-- 输入控件 txtAdminAssignedRoomName：接收用户输入或展示后台已有备注。 --%>
                                        <asp:TextBox ID="txtAdminAssignedRoomName" runat="server" CssClass="input-control" placeholder="安排房间，例如：长夜 B 厅" Text='<%# Eval("AssignedRoomName") %>' />
                                        <%-- 输入控件 txtAdminStoreRemark：接收用户输入或展示后台已有备注。 --%>
                                        <asp:TextBox ID="txtAdminStoreRemark" runat="server" CssClass="input-control textarea" TextMode="MultiLine" Rows="2" placeholder="内部处理备注" Text='<%# Eval("AdminRemark") %>' />
                                        <%-- 输入控件 txtAdminStoreReply：接收用户输入或展示后台已有备注。 --%>
                                        <asp:TextBox ID="txtAdminStoreReply" runat="server" CssClass="input-control textarea" TextMode="MultiLine" Rows="3" placeholder="回复玩家，例如：已安排长夜 B 厅，请 19:20 到店签到。" Text='<%# Eval("AdminReply") %>' />
                                        <div class="card-actions">
                                            <%-- 操作按钮 btnApproveStoreRequest：点击后触发后台事件处理当前业务动作。 --%>
                                            <asp:Button ID="btnApproveStoreRequest" runat="server" Text="审核通过并安排" CssClass="btn-primary" CommandName="ApproveStore" CommandArgument='<%# Eval("Id") %>' />
                                            <%-- 操作按钮 btnCompleteStoreRequest：点击后触发后台事件处理当前业务动作。 --%>
                                            <asp:Button ID="btnCompleteStoreRequest" runat="server" Text="标记到店完成" CssClass="btn-secondary" CommandName="CompleteStore" CommandArgument='<%# Eval("Id") %>' />
                                            <%-- 操作按钮 btnRejectStoreRequest：点击后触发后台事件处理当前业务动作。 --%>
                                            <asp:Button ID="btnRejectStoreRequest" runat="server" Text="驳回/关闭" CssClass="btn-secondary" CommandName="RejectStore" CommandArgument='<%# Eval("Id") %>' />
                                        </div>
                                    </div>
                                </article>
                            </ItemTemplate>
                        </asp:Repeater>
                    </div>
                </asp:Panel>

                <%-- 表单网格：按响应式布局排列输入框、下拉框和筛选条件。 --%>
                <div class="form-grid">
                    <div class="field-group">
                        <label for="<%= ddlScripts.ClientID %>">意向剧本</label>
                        <%-- 下拉控件 ddlScripts：提供状态、分类或角色等固定选项。 --%>
                        <asp:DropDownList ID="ddlScripts" runat="server" CssClass="input-control" />
                    </div>
                    <div class="field-group">
                        <label for="<%= txtPreferredTime.ClientID %>">预计到店时间</label>
                        <%-- 输入控件 txtPreferredTime：接收用户输入或展示后台已有备注。 --%>
                        <asp:TextBox ID="txtPreferredTime" runat="server" CssClass="input-control" placeholder="例如：2026-04-18 18:45" />
                    </div>
                    <div class="field-group">
                        <label for="<%= txtTeamSize.ClientID %>">组队人数</label>
                        <%-- 输入控件 txtTeamSize：接收用户输入或展示后台已有备注。 --%>
                        <asp:TextBox ID="txtTeamSize" runat="server" CssClass="input-control" Text="6" />
                    </div>
                    <div class="field-group">
                        <label for="<%= txtContactName.ClientID %>">联系人</label>
                        <%-- 输入控件 txtContactName：接收用户输入或展示后台已有备注。 --%>
                        <asp:TextBox ID="txtContactName" runat="server" CssClass="input-control" />
                    </div>
                    <div class="field-group">
                        <label for="<%= txtPhone.ClientID %>">联系电话</label>
                        <%-- 输入控件 txtPhone：接收用户输入或展示后台已有备注。 --%>
                        <asp:TextBox ID="txtPhone" runat="server" CssClass="input-control" />
                    </div>
                    <div class="field-group full">
                        <label for="<%= txtNote.ClientID %>">到店备注</label>
                        <%-- 输入控件 txtNote：接收用户输入或展示后台已有备注。 --%>
                        <asp:TextBox ID="txtNote" runat="server" CssClass="input-control textarea" TextMode="MultiLine" Rows="4" placeholder="例如：想玩《潮声熄灯时》，6 人拼满，先线上支付，到店直接开本。" />
                    </div>
                </div>

                <%-- 操作按钮 btnSubmit：点击后触发后台事件处理当前业务动作。 --%>
                <asp:Button ID="btnSubmit" runat="server" Text="提交门店联系单" CssClass="btn-primary wide-button" OnClick="btnSubmit_Click" />
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
                    <h2>演示开本账号</h2>
                    <p>系统已经准备好 6 个可直接登录的玩家账号，能进入同一场《潮声熄灯时》进行真实开本演示。</p>
                </div>
                <%-- 列表容器：承载 Repeater 渲染出的多条业务卡片。 --%>
                <div class="reservation-list">
                    <%-- 业务卡片：展示一条预约、审核、消息或统计记录。 --%>
                    <article class="reservation-card">
                        <h3>统一密码</h3>
                        <p><strong>123456</strong></p>
                        <small>账号：user1、user2、user3、user4、user5、user6</small>
                    </article>
                    <%-- 业务卡片：展示一条预约、审核、消息或统计记录。 --%>
                    <article class="reservation-card">
                        <h3>演示剧本</h3>
                        <p>《潮声熄灯时》 / 长夜 B 厅 / 2026-04-18 19:30</p>
                        <small>6 位玩家已分别拥有自己的预约记录和角色分配入口</small>
                    </article>
                </div>
            </article>

            <%-- 信息面板：承载一个独立的业务说明、列表或表单模块。 --%>
            <article class="about-panel">
                <%-- 模块标题区：说明当前业务模块的名称和处理说明。 --%>
                <div class="section-heading left">
                    <h2>我的门店联系单</h2>
                    <p>登录后会显示当前账号提交过的联系单，方便查看门店排期与沟通状态。</p>
                </div>
                <%-- 面板控件 pnlAnonymousHint：后台可通过 Visible/CssClass 控制整块内容是否显示以及提示样式。 --%>
                <asp:Panel ID="pnlAnonymousHint" runat="server" Visible="false" CssClass="status-message">
                    登录后可自动带出联系人信息，并查看自己的门店联系单记录。
                </asp:Panel>
                <%-- 列表容器：承载 Repeater 渲染出的多条业务卡片。 --%>
                <div class="reservation-list">
                    <%-- 数据列表控件 rptRequests：后台绑定集合数据后，按 ItemTemplate 循环渲染每条记录。 --%>
                    <asp:Repeater ID="rptRequests" runat="server" OnItemCommand="rptRequests_ItemCommand">
                        <%-- 列表项模板：定义 Repeater 中每一条业务记录的 HTML 结构和绑定字段。 --%>
                        <ItemTemplate>
                            <%-- 业务卡片：展示一条预约、审核、消息或统计记录。 --%>
                            <article class="reservation-card">
                                <h3><%# Eval("ScriptName") %></h3>
                                <p><%# Eval("ContactName") %> / <%# Eval("TeamSize") %> 人 / <%# Eval("PhoneMasked") %></p>
                                <p>状态：<%# Eval("RequestStatus") %></p>
                                <p><%# Eval("Note") %></p>
                                <p>安排房间：<%# string.IsNullOrWhiteSpace(Convert.ToString(Eval("AssignedRoomName"))) ? "等待门店安排" : Eval("AssignedRoomName") %></p>
                                <p class="meta-copy">门店回复：<%# string.IsNullOrWhiteSpace(Convert.ToString(Eval("AdminReply"))) ? "门店暂未线上回复，请等待处理。" : Eval("AdminReply") %></p>
                                <p>我的确认：<%# string.IsNullOrWhiteSpace(Convert.ToString(Eval("ConfirmStatus"))) ? "未确认" : Eval("ConfirmStatus") %></p>
                                <%-- 输入控件 txtRescheduleRemark：接收用户输入或展示后台已有备注。 --%>
                                <asp:TextBox ID="txtRescheduleRemark" runat="server" CssClass="input-control textarea" TextMode="MultiLine" Rows="2" placeholder="如需改期，请填写希望调整到的时间和原因" />
                                <%-- 操作按钮区：集中放置提交、重置、跳转或审核动作。 --%>
                                <div class="hero-actions">
                                    <%-- 操作按钮 btnConfirmReceived：点击后触发后台事件处理当前业务动作。 --%>
                                    <asp:LinkButton ID="btnConfirmReceived" runat="server" CssClass="btn-primary small" CommandName="ConfirmReceived" CommandArgument='<%# Eval("Id") %>'>我已收到</asp:LinkButton>
                                    <%-- 操作按钮 btnRequestReschedule：点击后触发后台事件处理当前业务动作。 --%>
                                    <asp:LinkButton ID="btnRequestReschedule" runat="server" CssClass="btn-secondary small" CommandName="RequestReschedule" CommandArgument='<%# Eval("Id") %>'>申请改期</asp:LinkButton>
                                </div>
                                <small>到店时间：<%# Eval("PreferredArriveTime", "{0:yyyy-MM-dd HH:mm}") %> / 提交于 <%# Eval("CreatedAt", "{0:yyyy-MM-dd HH:mm}") %></small>
                                <small><%# Eval("RepliedAt") == null ? string.Empty : " / 回复于 " + Eval("RepliedAt", "{0:yyyy-MM-dd HH:mm}") %></small>
                            </article>
                        </ItemTemplate>
                    </asp:Repeater>
                </div>
            </article>
        </div>
    </section>
</asp:Content>
