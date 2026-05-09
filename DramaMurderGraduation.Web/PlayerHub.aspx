<%@ Page Title="玩家中心 | 剧本杀系统" Language="C#" MasterPageFile="~/Site.Master" AutoEventWireup="true" CodeBehind="PlayerHub.aspx.cs" Inherits="DramaMurderGraduation.Web.PlayerHubPage" %>
<%-- 页面用途：PlayerHub 页面负责承载对应功能的 Web Forms 标记、服务端控件和前端布局。 --%>
<asp:Content ID="Content1" ContentPlaceHolderID="TitleContent" runat="server">
    玩家中心 | 剧本杀系统
</asp:Content>
<asp:Content ID="Content2" ContentPlaceHolderID="MainContent" runat="server">
    <%-- 页面分区：把当前页面内容按业务模块拆分展示。 --%>
    <section class="hero-section">
        <div class="container profile-banner">
            <div class="profile-avatar-shell">
                <asp:Image ID="imgAvatar" runat="server" CssClass="profile-avatar" AlternateText="玩家头像" />
            </div>
            <div class="profile-summary">
                <div class="hero-badge-row hub-tab-row">
                    <a class='site-badge<%= ActiveTab == "profile" ? " active" : string.Empty %>' href="PlayerHub.aspx?tab=profile">玩家档案</a>
                    <a class='site-badge soft<%= ActiveTab == "orders" ? " active" : string.Empty %>' href="PlayerHub.aspx?tab=orders">我的房间/订单</a>
                    <a class='site-badge soft<%= ActiveTab == "social" ? " active" : string.Empty %>' href="PlayerHub.aspx?tab=social">好友互动</a>
                </div>
                <p class="eyebrow">PLAYER HUB</p>
                <h1><asp:Literal ID="litDisplayName" runat="server" /></h1>
                <p class="hero-subtitle"><asp:Literal ID="litDisplayTitle" runat="server" /></p>
                <p class="hero-text"><asp:Literal ID="litMotto" runat="server" /></p>
                <%-- 摘要标签区：展示当前页面最重要的数量或状态提示。 --%>
                <div class="detail-tags">
                    <span>偏好题材 <asp:Literal ID="litFavoriteGenre" runat="server" /></span>
                    <span>声望等级 <asp:Literal ID="litReputationLevel" runat="server" /></span>
                </div>
            </div>
            <div class="hero-panel metric-grid-four">
                <div class="metric-card accent">
                    <p>礼物币余额</p>
                    <strong><asp:Literal ID="litGiftBalance" runat="server" /></strong>
                </div>
                <div class="metric-card">
                    <p>累计送礼</p>
                    <strong><asp:Literal ID="litTotalGiftSent" runat="server" /></strong>
                </div>
                <div class="metric-card">
                    <p>收到礼物</p>
                    <strong><asp:Literal ID="litTotalGiftReceived" runat="server" /></strong>
                </div>
                <div class="metric-card">
                    <p>好友数量</p>
                    <strong><asp:Literal ID="litFriendCount" runat="server" /></strong>
                </div>
            </div>
        </div>
    </section>

    <%-- 面板控件 pnlProfileTab：后台可通过 Visible/CssClass 控制整块内容是否显示以及提示样式。 --%>
    <asp:Panel ID="pnlProfileTab" runat="server" CssClass="hub-tab-panel">
        <%-- 主要内容区：承载当前页面的核心业务列表、表单或详情内容。 --%>
        <section class="section-block">
            <div class="container split-grid detail-split">
                <%-- 表单面板：承载筛选条件或业务提交输入项。 --%>
                <article class="form-panel">
                    <%-- 模块标题区：说明当前业务模块的名称和处理说明。 --%>
                    <div class="section-heading left">
                        <h2>编辑玩家档案</h2>
                        <p>修改昵称、头衔、签名、头像和偏好后，页面展示会立即同步。</p>
                    </div>
                    <%-- 面板控件 pnlProfileMessage：后台可通过 Visible/CssClass 控制整块内容是否显示以及提示样式。 --%>
                    <asp:Panel ID="pnlProfileMessage" runat="server" Visible="false" CssClass="status-message">
                        <asp:Literal ID="litProfileMessage" runat="server" />
                    </asp:Panel>
                    <%-- 表单网格：按响应式布局排列输入框、下拉框和筛选条件。 --%>
                    <div class="form-grid hub-form-grid">
                        <div class="field-group">
                            <label for="<%= txtProfileDisplayName.ClientID %>">玩家昵称</label>
                            <%-- 输入控件 txtProfileDisplayName：接收用户输入或展示后台已有备注。 --%>
                            <asp:TextBox ID="txtProfileDisplayName" runat="server" CssClass="input-control" />
                        </div>
                        <div class="field-group">
                            <label for="<%= txtProfileTitle.ClientID %>">玩家头衔</label>
                            <%-- 输入控件 txtProfileTitle：接收用户输入或展示后台已有备注。 --%>
                            <asp:TextBox ID="txtProfileTitle" runat="server" CssClass="input-control" />
                        </div>
                        <div class="field-group full">
                            <label for="<%= txtProfileMotto.ClientID %>">个性签名</label>
                            <%-- 输入控件 txtProfileMotto：接收用户输入或展示后台已有备注。 --%>
                            <asp:TextBox ID="txtProfileMotto" runat="server" CssClass="input-control" />
                        </div>
                        <div class="field-group full">
                            <label for="<%= txtProfileAvatarUrl.ClientID %>">头像地址</label>
                            <%-- 输入控件 txtProfileAvatarUrl：接收用户输入或展示后台已有备注。 --%>
                            <asp:TextBox ID="txtProfileAvatarUrl" runat="server" CssClass="input-control" />
                        </div>
                        <div class="field-group">
                            <label for="<%= ddlProfileFavoriteGenre.ClientID %>">偏好题材</label>
                            <%-- 下拉控件 ddlProfileFavoriteGenre：提供状态、分类或角色等固定选项。 --%>
                            <asp:DropDownList ID="ddlProfileFavoriteGenre" runat="server" CssClass="input-control" />
                        </div>
                    </div>
                    <%-- 操作按钮 btnSaveProfile：点击后触发后台事件处理当前业务动作。 --%>
                    <asp:Button ID="btnSaveProfile" runat="server" Text="保存玩家档案" CssClass="btn-primary wide-button" OnClick="btnSaveProfile_Click" />
                </article>

                <%-- 信息面板：承载一个独立的业务说明、列表或表单模块。 --%>
                <article class="about-panel">
                    <%-- 模块标题区：说明当前业务模块的名称和处理说明。 --%>
                    <div class="section-heading left">
                        <h2>玩家画像</h2>
                        <p>这些标签会影响房间推荐、拼车匹配和下一场剧本推荐。</p>
                    </div>
                    <div class="lobby-summary-list">
                        <div class="lobby-summary-item"><span>推荐身份</span><strong><asp:Literal ID="litRecommendedIdentity" runat="server" /></strong></div>
                        <div class="lobby-summary-item"><span>局内风格</span><strong><asp:Literal ID="litPlayStyle" runat="server" /></strong></div>
                        <div class="lobby-summary-item"><span>成长建议</span><strong><asp:Literal ID="litGrowthAdvice" runat="server" /></strong></div>
                        <div class="lobby-summary-item"><span>完成剧本</span><strong><asp:Literal ID="litCompletedScripts" runat="server" /></strong></div>
                        <div class="lobby-summary-item"><span>胜率</span><strong><asp:Literal ID="litWinRate" runat="server" /></strong></div>
                        <div class="lobby-summary-item"><span>成就数量</span><strong><asp:Literal ID="litAchievementCount" runat="server" /></strong></div>
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
                        <h2>能力值详情</h2>
                        <p>用于展示你在推理、观察、创造、协作和执行上的能力画像。</p>
                    </div>
                    <div class="ability-list">
                        <%-- 数据列表控件 rptAbilities：后台绑定集合数据后，按 ItemTemplate 循环渲染每条记录。 --%>
                        <asp:Repeater ID="rptAbilities" runat="server">
                            <%-- 列表项模板：定义 Repeater 中每一条业务记录的 HTML 结构和绑定字段。 --%>
                            <ItemTemplate>
                                <div class="ability-row">
                                    <div class="ability-head">
                                        <strong><%# Eval("Name") %></strong>
                                        <span><%# Eval("Value") %> / 100</span>
                                    </div>
                                    <div class="ability-track">
                                        <div class="ability-fill" style='width:<%# Eval("Value") %>%;'></div>
                                    </div>
                                    <p class="meta-copy"><%# Eval("Description") %></p>
                                </div>
                            </ItemTemplate>
                        </asp:Repeater>
                    </div>
                </article>

                <%-- 信息面板：承载一个独立的业务说明、列表或表单模块。 --%>
                <article class="about-panel">
                    <%-- 模块标题区：说明当前业务模块的名称和处理说明。 --%>
                    <div class="section-heading left">
                        <h2>成就徽章</h2>
                        <p>记录你最近解锁的里程碑和长期成长轨迹。</p>
                    </div>
                    <div class="achievement-grid">
                        <%-- 数据列表控件 rptAchievements：后台绑定集合数据后，按 ItemTemplate 循环渲染每条记录。 --%>
                        <asp:Repeater ID="rptAchievements" runat="server">
                            <%-- 列表项模板：定义 Repeater 中每一条业务记录的 HTML 结构和绑定字段。 --%>
                            <ItemTemplate>
                                <%-- 内容卡片：用于组织当前模块中的一组相关信息。 --%>
                                <article class="achievement-card">
                                    <span class="badge-inline"><%# Eval("RarityTag") %></span>
                                    <h3><%# Eval("Title") %></h3>
                                    <p><%# Eval("Description") %></p>
                                    <p class="meta-copy">进度 <%# Eval("ProgressValue") %> / <%# Eval("ProgressTotal") %></p>
                                    <small><%# Eval("EarnedAt", "{0:yyyy-MM-dd HH:mm}") %></small>
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
                <%-- 信息面板：承载一个独立的业务说明、列表或表单模块。 --%>
                <article class="about-panel">
                    <%-- 模块标题区：说明当前业务模块的名称和处理说明。 --%>
                    <div class="section-heading left">
                        <h2>最近战绩</h2>
                        <p>每次正式结算后的剧本局都会沉淀在这里，方便你回看角色、投票和结果。</p>
                    </div>
                    <div class="battle-record-grid">
                        <%-- 数据列表控件 rptBattleRecords：后台绑定集合数据后，按 ItemTemplate 循环渲染每条记录。 --%>
                        <asp:Repeater ID="rptBattleRecords" runat="server">
                            <%-- 列表项模板：定义 Repeater 中每一条业务记录的 HTML 结构和绑定字段。 --%>
                            <ItemTemplate>
                                <%-- 内容卡片：用于组织当前模块中的一组相关信息。 --%>
                                <article class='battle-record-card <%# Convert.ToBoolean(Eval("WasCorrect")) ? "success" : "pending" %>'>
                                    <div class="battle-record-head">
                                        <span class='badge-inline <%# Convert.ToBoolean(Eval("WasCorrect")) ? "success" : "soft" %>'><%# Eval("ResultTag") %></span>
                                        <small><%# Eval("CompletedAt", "{0:yyyy-MM-dd HH:mm}") %></small>
                                    </div>
                                    <h3><%# Eval("ScriptName") %></h3>
                                    <p class="meta-copy">房间 <%# Eval("RoomName") %> / 角色 <%# Eval("CharacterName") %></p>
                                    <p class="meta-copy">你的投票 <%# string.IsNullOrWhiteSpace(Convert.ToString(Eval("VotedCharacterName"))) ? "未提交" : Eval("VotedCharacterName") %></p>
                                    <p class="meta-copy">正确角色 <%# Eval("CorrectCharacterName") %></p>
                                    <a class="text-link strong" href='GameResult.aspx?reservationId=<%# Eval("ReservationId") %>'>查看这场复盘</a>
                                </article>
                            </ItemTemplate>
                        </asp:Repeater>
                    </div>
                </article>
            </div>
        </section>

        <%-- 次级内容区：用于承载筛选、配置、辅助列表或补充信息。 --%>
        <section class="section-block alt">
            <div class="container">
                <%-- 信息面板：承载一个独立的业务说明、列表或表单模块。 --%>
                <article class="about-panel">
                    <%-- 模块标题区：说明当前业务模块的名称和处理说明。 --%>
                    <div class="section-heading left">
                        <h2>下一场推荐</h2>
                        <p>根据你玩过的剧本、常组人数和偏好题材，给出下一场更适合的安排。</p>
                    </div>
                    <div class="metric-grid-four recommendation-metric-grid">
                        <div class="metric-card"><p>当前偏好</p><strong><asp:Literal ID="litRepurchaseGenre" runat="server" /></strong></div>
                        <div class="metric-card"><p>常组人数</p><strong><asp:Literal ID="litRepurchasePlayerCount" runat="server" /></strong></div>
                        <div class="metric-card accent"><p>推荐方向</p><strong><asp:Literal ID="litRepurchaseHint" runat="server" /></strong></div>
                        <div class="metric-card"><p>可约场次</p><strong><asp:Literal ID="litRepurchaseSessionCount" runat="server" /></strong></div>
                    </div>
                    <%-- 面板控件 pnlRepurchaseEmpty：后台可通过 Visible/CssClass 控制整块内容是否显示以及提示样式。 --%>
                    <asp:Panel ID="pnlRepurchaseEmpty" runat="server" Visible="false" CssClass="status-message">
                        <asp:Literal ID="litRepurchaseEmpty" runat="server" />
                    </asp:Panel>
                    <%-- 面板控件 pnlRepurchaseRecommendations：后台可通过 Visible/CssClass 控制整块内容是否显示以及提示样式。 --%>
                    <asp:Panel ID="pnlRepurchaseRecommendations" runat="server">
                        <%-- 列表容器：承载 Repeater 渲染出的多条业务卡片。 --%>
                        <div class="reservation-list">
                            <%-- 数据列表控件 rptRepurchaseRecommendations：后台绑定集合数据后，按 ItemTemplate 循环渲染每条记录。 --%>
                            <asp:Repeater ID="rptRepurchaseRecommendations" runat="server">
                                <%-- 列表项模板：定义 Repeater 中每一条业务记录的 HTML 结构和绑定字段。 --%>
                                <ItemTemplate>
                                    <%-- 业务卡片：展示一条预约、审核、消息或统计记录。 --%>
                                    <article class="reservation-card repurchase-card">
                                        <span class="badge-inline soft"><%# Eval("HighlightTag") %></span>
                                        <h3><%# Eval("Title") %></h3>
                                        <p><%# Eval("GenreName") %> / <%# Eval("Difficulty") %> / 评分 <%# Eval("Rating", "{0:F1}") %></p>
                                        <p class="meta-copy"><%# Eval("Summary") %></p>
                                        <p class="meta-copy recommendation-reason"><%# Eval("RecommendationReason") %></p>
                                        <p class="meta-copy"><%# GetRecommendationPlayerRange(Container.DataItem) %> / <%# GetRecommendationSessionText(Container.DataItem) %></p>
                                        <p class="meta-copy"><%# Eval("SecondaryReason") %></p>
                                        <div class="card-actions">
                                            <a class="btn-primary small" href='ScriptDetails.aspx?id=<%# Eval("Id") %>'>查看详情</a>
                                            <a class="btn-secondary small" href='<%# Eval("DestinationUrl") %>'>直接预约</a>
                                        </div>
                                    </article>
                                </ItemTemplate>
                            </asp:Repeater>
                        </div>
                    </asp:Panel>
                </article>
            </div>
        </section>
    </asp:Panel>

    <%-- 面板控件 pnlOrdersTab：后台可通过 Visible/CssClass 控制整块内容是否显示以及提示样式。 --%>
    <asp:Panel ID="pnlOrdersTab" runat="server" CssClass="hub-tab-panel">
        <%-- 主要内容区：承载当前页面的核心业务列表、表单或详情内容。 --%>
        <section class="section-block">
            <div class="container">
                <%-- 模块标题区：说明当前业务模块的名称和处理说明。 --%>
                <div class="section-heading left">
                    <h2>我的房间与订单</h2>
                    <p>继续游戏、预约确认、到店安排、改期申请和门店回复会集中展示在这里。</p>
                </div>
                <%-- 面板控件 pnlOrderMessage：后台可通过 Visible/CssClass 控制整块内容是否显示以及提示样式。 --%>
                <asp:Panel ID="pnlOrderMessage" runat="server" Visible="false" CssClass="status-message">
                    <asp:Literal ID="litOrderMessage" runat="server" />
                </asp:Panel>
            </div>
        </section>

        <%-- 次级内容区：用于承载筛选、配置、辅助列表或补充信息。 --%>
        <section class="section-block alt">
            <div class="container split-grid detail-split">
                <%-- 信息面板：承载一个独立的业务说明、列表或表单模块。 --%>
                <article class="about-panel">
                    <%-- 模块标题区：说明当前业务模块的名称和处理说明。 --%>
                    <div class="section-heading left compact">
                        <h2>预约订单</h2>
                        <p>确认预约、发送留言、进入候场和继续游戏都可以在这里处理。</p>
                    </div>
                    <%-- 列表容器：承载 Repeater 渲染出的多条业务卡片。 --%>
                    <div class="reservation-list">
                        <%-- 数据列表控件 rptHubReservations：后台绑定集合数据后，按 ItemTemplate 循环渲染每条记录。 --%>
                        <asp:Repeater ID="rptHubReservations" runat="server" OnItemCommand="rptHubReservations_ItemCommand">
                            <%-- 列表项模板：定义 Repeater 中每一条业务记录的 HTML 结构和绑定字段。 --%>
                            <ItemTemplate>
                                <%-- 业务卡片：展示一条预约、审核、消息或统计记录。 --%>
                                <article class="reservation-card service-flow-card">
                                    <h3><%# Eval("ScriptName") %> / <%# Eval("PlayerCount") %> 人</h3>
                                    <p><%# Eval("RoomName") %> / 房间号 ROOM-<%# Eval("SessionId", "{0:D4}") %> / DM <%# Eval("HostName") %></p>
                                    <p>订单 <%# Eval("Status") %> / 支付 <%# Eval("PaymentStatus") %> / ¥ <%# Eval("TotalAmount", "{0:F2}") %></p>
                                    <p>优惠 <%# Convert.ToDecimal(Eval("DiscountAmount")) > 0 ? Eval("CouponTitle") + " / 抵扣 ¥" + Eval("DiscountAmount", "{0:F2}") : "未使用优惠券" %></p>
                                    <p class="meta-copy">门店回复 <%# string.IsNullOrWhiteSpace(Convert.ToString(Eval("AdminReply"))) ? "暂无回复" : Eval("AdminReply") %></p>
                                    <p>核销码 <strong><%# Eval("CheckInCode") %></strong> <%# Eval("CheckedInAt") == null ? string.Empty : " / 已核销 " + Convert.ToDateTime(Eval("CheckedInAt")).ToString("MM-dd HH:mm") %></p>
                                    <p>我的确认 <%# string.IsNullOrWhiteSpace(Convert.ToString(Eval("ConfirmStatus"))) ? "未确认" : Eval("ConfirmStatus") %></p>
                                    <div class="service-timeline"><%# BuildReservationTimeline(Container.DataItem) %></div>
                                    <%-- 输入控件 txtReservationRescheduleRemark：接收用户输入或展示后台已有备注。 --%>
                                    <asp:TextBox ID="txtReservationRescheduleRemark" runat="server" CssClass="input-control textarea" TextMode="MultiLine" Rows="2" placeholder="如需改期，请填写希望调整的时间和原因" />
                                    <%-- 输入控件 txtReservationServiceMessage：接收用户输入或展示后台已有备注。 --%>
                                    <asp:TextBox ID="txtReservationServiceMessage" runat="server" CssClass="input-control textarea" TextMode="MultiLine" Rows="2" placeholder="给门店留言，说明订单安排或特殊需求" />
                                    <div class="card-actions">
                                        <a class="btn-primary small" href='GameRoom.aspx?reservationId=<%# Eval("Id") %>'>进入游戏房间</a>
                                        <a class="btn-secondary small" href='OrderDetails.aspx?reservationId=<%# Eval("Id") %>'>查看详情</a>
                                        <a class="btn-secondary small" href='OrderConversation.aspx?reservationId=<%# Eval("Id") %>'>订单沟通</a>
                                        <%-- 操作按钮 btnConfirmReservation：点击后触发后台事件处理当前业务动作。 --%>
                                        <asp:LinkButton ID="btnConfirmReservation" runat="server" CssClass="btn-primary small" CommandName="ConfirmReservation" CommandArgument='<%# Eval("Id") %>'>确认收到</asp:LinkButton>
                                        <%-- 操作按钮 btnReservationReschedule：点击后触发后台事件处理当前业务动作。 --%>
                                        <asp:LinkButton ID="btnReservationReschedule" runat="server" CssClass="btn-secondary small" CommandName="RequestReservationReschedule" CommandArgument='<%# Eval("Id") %>'>申请改期</asp:LinkButton>
                                        <%-- 操作按钮 btnReservationMessage：点击后触发后台事件处理当前业务动作。 --%>
                                        <asp:LinkButton ID="btnReservationMessage" runat="server" CssClass="btn-secondary small" CommandName="SendReservationMessage" CommandArgument='<%# Eval("Id") %>'>发送追问</asp:LinkButton>
                                        <a class="btn-secondary small" href='GameLobby.aspx?reservationId=<%# Eval("Id") %>'>进入候场</a>
                                        <asp:LinkButton ID="btnLeaveReservation" runat="server" CssClass="btn-secondary small danger-button" CommandName="LeaveReservation" CommandArgument='<%# Eval("Id") %>' Visible='<%# CanLeaveReservation(Container.DataItem) %>' OnClientClick="return confirm('确认退出这个游戏房间吗？退出后会取消该预约并立即释放本场名额。');">退出游戏</asp:LinkButton>
                                    </div>
                                    <small>开场 <%# Eval("SessionDateTime", "{0:yyyy-MM-dd HH:mm}") %> / 下单 <%# Eval("CreatedAt", "{0:yyyy-MM-dd HH:mm}") %></small>
                                </article>
                            </ItemTemplate>
                        </asp:Repeater>
                    </div>
                </article>

                <%-- 信息面板：承载一个独立的业务说明、列表或表单模块。 --%>
                <article class="about-panel">
                    <%-- 模块标题区：说明当前业务模块的名称和处理说明。 --%>
                    <div class="section-heading left compact">
                        <h2>到店联系单</h2>
                        <p>门店排期、房间安排和到店接待前的沟通会保留在这里。</p>
                    </div>
                    <%-- 列表容器：承载 Repeater 渲染出的多条业务卡片。 --%>
                    <div class="reservation-list">
                        <%-- 数据列表控件 rptHubStoreRequests：后台绑定集合数据后，按 ItemTemplate 循环渲染每条记录。 --%>
                        <asp:Repeater ID="rptHubStoreRequests" runat="server" OnItemCommand="rptHubStoreRequests_ItemCommand">
                            <%-- 列表项模板：定义 Repeater 中每一条业务记录的 HTML 结构和绑定字段。 --%>
                            <ItemTemplate>
                                <%-- 业务卡片：展示一条预约、审核、消息或统计记录。 --%>
                                <article class="reservation-card service-flow-card">
                                    <h3><%# Eval("ScriptName") %></h3>
                                    <p><%# Eval("ContactName") %> / <%# Eval("TeamSize") %> 人 / <%# Eval("PhoneMasked") %></p>
                                    <p>状态 <%# Eval("RequestStatus") %> / 房间 <%# string.IsNullOrWhiteSpace(Convert.ToString(Eval("AssignedRoomName"))) ? "待安排" : Eval("AssignedRoomName") %></p>
                                    <p class="meta-copy">门店回复 <%# string.IsNullOrWhiteSpace(Convert.ToString(Eval("AdminReply"))) ? "暂无回复" : Eval("AdminReply") %></p>
                                    <p>我的确认 <%# string.IsNullOrWhiteSpace(Convert.ToString(Eval("ConfirmStatus"))) ? "未确认" : Eval("ConfirmStatus") %></p>
                                    <div class="service-timeline"><%# BuildStoreTimeline(Container.DataItem) %></div>
                                    <%-- 输入控件 txtStoreRescheduleRemark：接收用户输入或展示后台已有备注。 --%>
                                    <asp:TextBox ID="txtStoreRescheduleRemark" runat="server" CssClass="input-control textarea" TextMode="MultiLine" Rows="2" placeholder="如需改期，请填写希望调整的时间和原因" />
                                    <%-- 输入控件 txtStoreServiceMessage：接收用户输入或展示后台已有备注。 --%>
                                    <asp:TextBox ID="txtStoreServiceMessage" runat="server" CssClass="input-control textarea" TextMode="MultiLine" Rows="2" placeholder="给门店留言，说明到店安排或特殊需求" />
                                    <div class="card-actions">
                                        <%-- 操作按钮 btnConfirmStore：点击后触发后台事件处理当前业务动作。 --%>
                                        <asp:LinkButton ID="btnConfirmStore" runat="server" CssClass="btn-primary small" CommandName="ConfirmStore" CommandArgument='<%# Eval("Id") %>'>确认收到</asp:LinkButton>
                                        <%-- 操作按钮 btnStoreReschedule：点击后触发后台事件处理当前业务动作。 --%>
                                        <asp:LinkButton ID="btnStoreReschedule" runat="server" CssClass="btn-secondary small" CommandName="RequestStoreReschedule" CommandArgument='<%# Eval("Id") %>'>申请改期</asp:LinkButton>
                                        <%-- 操作按钮 btnStoreMessage：点击后触发后台事件处理当前业务动作。 --%>
                                        <asp:LinkButton ID="btnStoreMessage" runat="server" CssClass="btn-secondary small" CommandName="SendStoreMessage" CommandArgument='<%# Eval("Id") %>'>发送追问</asp:LinkButton>
                                    </div>
                                    <small>预计到店 <%# Eval("PreferredArriveTime", "{0:yyyy-MM-dd HH:mm}") %> / 提交 <%# Eval("CreatedAt", "{0:yyyy-MM-dd HH:mm}") %></small>
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
                <%-- 信息面板：承载一个独立的业务说明、列表或表单模块。 --%>
                <article class="about-panel">
                    <%-- 模块标题区：说明当前业务模块的名称和处理说明。 --%>
                    <div class="section-heading left compact">
                        <h2>门店服务通知</h2>
                        <p>管理员对订单、到店联系单和售后申请的可见回复会汇总在这里。</p>
                    </div>
                    <%-- 列表容器：承载 Repeater 渲染出的多条业务卡片。 --%>
                    <div class="reservation-list">
                        <%-- 数据列表控件 rptHubReplyLogs：后台绑定集合数据后，按 ItemTemplate 循环渲染每条记录。 --%>
                        <asp:Repeater ID="rptHubReplyLogs" runat="server">
                            <%-- 列表项模板：定义 Repeater 中每一条业务记录的 HTML 结构和绑定字段。 --%>
                            <ItemTemplate>
                                <%-- 业务卡片：展示一条预约、审核、消息或统计记录。 --%>
                                <article class="reservation-card service-reply-card">
                                    <span class="badge-inline soft"><%# Eval("Category") %></span>
                                    <h3><%# Eval("Title") %></h3>
                                    <p><%# Eval("Content") %></p>
                                    <small><%# Eval("CreatedAt", "{0:yyyy-MM-dd HH:mm}") %></small>
                                    <a class="text-link strong" href='<%# Eval("TargetUrl") %>'>查看对应功能</a>
                                </article>
                            </ItemTemplate>
                        </asp:Repeater>
                    </div>
                </article>
            </div>
        </section>
    </asp:Panel>

    <%-- 面板控件 pnlSocialTab：后台可通过 Visible/CssClass 控制整块内容是否显示以及提示样式。 --%>
    <asp:Panel ID="pnlSocialTab" runat="server" CssClass="hub-tab-panel">
        <%-- 次级内容区：用于承载筛选、配置、辅助列表或补充信息。 --%>
        <section class="section-block alt" id="gift-panel">
            <div class="container split-grid detail-split">
                <%-- 表单面板：承载筛选条件或业务提交输入项。 --%>
                <article class="form-panel">
                    <%-- 模块标题区：说明当前业务模块的名称和处理说明。 --%>
                    <div class="section-heading left">
                        <h2>互动送礼</h2>
                        <p>选好对象、礼物和数量后，礼物币会立即扣除，对方会立即收到。</p>
                    </div>
                    <%-- 面板控件 pnlGiftMessage：后台可通过 Visible/CssClass 控制整块内容是否显示以及提示样式。 --%>
                    <asp:Panel ID="pnlGiftMessage" runat="server" Visible="false" CssClass="status-message">
                        <asp:Literal ID="litGiftMessage" runat="server" />
                    </asp:Panel>
                    <%-- 表单网格：按响应式布局排列输入框、下拉框和筛选条件。 --%>
                    <div class="form-grid hub-form-grid">
                        <div class="field-group">
                            <label for="<%= ddlGiftReceiver.ClientID %>">收礼玩家</label>
                            <%-- 下拉控件 ddlGiftReceiver：提供状态、分类或角色等固定选项。 --%>
                            <asp:DropDownList ID="ddlGiftReceiver" runat="server" CssClass="input-control" />
                        </div>
                        <div class="field-group">
                            <label for="<%= ddlGiftCatalog.ClientID %>">礼物类型</label>
                            <%-- 下拉控件 ddlGiftCatalog：提供状态、分类或角色等固定选项。 --%>
                            <asp:DropDownList ID="ddlGiftCatalog" runat="server" CssClass="input-control" />
                        </div>
                        <div class="field-group">
                            <label for="<%= txtGiftQuantity.ClientID %>">赠送数量</label>
                            <%-- 输入控件 txtGiftQuantity：接收用户输入或展示后台已有备注。 --%>
                            <asp:TextBox ID="txtGiftQuantity" runat="server" CssClass="input-control" Text="1" />
                        </div>
                    </div>
                    <%-- 操作按钮 btnSendGift：点击后触发后台事件处理当前业务动作。 --%>
                    <asp:Button ID="btnSendGift" runat="server" Text="立即送礼" CssClass="btn-primary wide-button" OnClick="btnSendGift_Click" />

                    <%-- 模块标题区：说明当前业务模块的名称和处理说明。 --%>
                    <div class="section-heading compact">
                        <h2>最近送出</h2>
                    </div>
                    <%-- 列表容器：承载 Repeater 渲染出的多条业务卡片。 --%>
                    <div class="reservation-list">
                        <%-- 数据列表控件 rptGiftSentRecords：后台绑定集合数据后，按 ItemTemplate 循环渲染每条记录。 --%>
                        <asp:Repeater ID="rptGiftSentRecords" runat="server">
                            <%-- 列表项模板：定义 Repeater 中每一条业务记录的 HTML 结构和绑定字段。 --%>
                            <ItemTemplate>
                                <%-- 业务卡片：展示一条预约、审核、消息或统计记录。 --%>
                                <article class="reservation-card">
                                    <h3><%# Eval("GiftIconText") %> <%# Eval("GiftName") %> x <%# Eval("Quantity") %></h3>
                                    <p>送给 <%# Eval("ReceiverDisplayName") %></p>
                                    <p>消耗 <%# Eval("TotalCoins") %></p>
                                    <small><%# Eval("CreatedAt", "{0:yyyy-MM-dd HH:mm}") %></small>
                                </article>
                            </ItemTemplate>
                        </asp:Repeater>
                    </div>
                </article>

                <%-- 信息面板：承载一个独立的业务说明、列表或表单模块。 --%>
                <article class="about-panel">
                    <%-- 模块标题区：说明当前业务模块的名称和处理说明。 --%>
                    <div class="section-heading left">
                        <h2>最近收到</h2>
                    </div>
                    <%-- 列表容器：承载 Repeater 渲染出的多条业务卡片。 --%>
                    <div class="reservation-list">
                        <%-- 数据列表控件 rptGiftReceivedRecords：后台绑定集合数据后，按 ItemTemplate 循环渲染每条记录。 --%>
                        <asp:Repeater ID="rptGiftReceivedRecords" runat="server">
                            <%-- 列表项模板：定义 Repeater 中每一条业务记录的 HTML 结构和绑定字段。 --%>
                            <ItemTemplate>
                                <%-- 业务卡片：展示一条预约、审核、消息或统计记录。 --%>
                                <article class="reservation-card">
                                    <h3><%# Eval("GiftIconText") %> <%# Eval("GiftName") %> x <%# Eval("Quantity") %></h3>
                                    <p>来自 <%# Eval("SenderDisplayName") %></p>
                                    <p>价值 <%# Eval("TotalCoins") %></p>
                                    <small><%# Eval("CreatedAt", "{0:yyyy-MM-dd HH:mm}") %></small>
                                </article>
                            </ItemTemplate>
                        </asp:Repeater>
                    </div>
                </article>
            </div>
        </section>

        <%-- 主要内容区：承载当前页面的核心业务列表、表单或详情内容。 --%>
        <section class="section-block">
            <div class="container split-grid detail-split">
                <%-- 表单面板：承载筛选条件或业务提交输入项。 --%>
                <article class="form-panel">
                    <%-- 模块标题区：说明当前业务模块的名称和处理说明。 --%>
                    <div class="section-heading left">
                        <h2>添加好友</h2>
                        <p>发送好友申请后，对方通过即可进入好友列表。</p>
                    </div>
                    <%-- 面板控件 pnlFriendMessage：后台可通过 Visible/CssClass 控制整块内容是否显示以及提示样式。 --%>
                    <asp:Panel ID="pnlFriendMessage" runat="server" Visible="false" CssClass="status-message">
                        <asp:Literal ID="litFriendMessage" runat="server" />
                    </asp:Panel>
                    <%-- 表单网格：按响应式布局排列输入框、下拉框和筛选条件。 --%>
                    <div class="form-grid hub-form-grid">
                        <div class="field-group">
                            <label for="<%= ddlFriendCandidate.ClientID %>">推荐玩家</label>
                            <%-- 下拉控件 ddlFriendCandidate：提供状态、分类或角色等固定选项。 --%>
                            <asp:DropDownList ID="ddlFriendCandidate" runat="server" CssClass="input-control" />
                        </div>
                        <div class="field-group full">
                            <label for="<%= txtFriendRequestMessage.ClientID %>">申请说明</label>
                            <%-- 输入控件 txtFriendRequestMessage：接收用户输入或展示后台已有备注。 --%>
                            <asp:TextBox ID="txtFriendRequestMessage" runat="server" CssClass="input-control" />
                        </div>
                    </div>
                    <%-- 操作按钮 btnSendFriendRequest：点击后触发后台事件处理当前业务动作。 --%>
                    <asp:Button ID="btnSendFriendRequest" runat="server" Text="发送好友申请" CssClass="btn-primary wide-button" OnClick="btnSendFriendRequest_Click" />

                    <%-- 模块标题区：说明当前业务模块的名称和处理说明。 --%>
                    <div class="section-heading compact">
                        <h2>收到的好友申请</h2>
                    </div>
                    <%-- 列表容器：承载 Repeater 渲染出的多条业务卡片。 --%>
                    <div class="reservation-list">
                        <%-- 数据列表控件 rptIncomingFriendRequests：后台绑定集合数据后，按 ItemTemplate 循环渲染每条记录。 --%>
                        <asp:Repeater ID="rptIncomingFriendRequests" runat="server" OnItemCommand="rptIncomingFriendRequests_ItemCommand">
                            <%-- 列表项模板：定义 Repeater 中每一条业务记录的 HTML 结构和绑定字段。 --%>
                            <ItemTemplate>
                                <%-- 业务卡片：展示一条预约、审核、消息或统计记录。 --%>
                                <article class="reservation-card">
                                    <h3><%# Eval("SenderDisplayName") %></h3>
                                    <p><%# string.IsNullOrWhiteSpace(Convert.ToString(Eval("RequestMessage"))) ? "对方没有填写附言" : Eval("RequestMessage") %></p>
                                    <small><%# Eval("CreatedAt", "{0:yyyy-MM-dd HH:mm}") %></small>
                                    <%-- 操作按钮区：集中放置提交、重置、跳转或审核动作。 --%>
                                    <div class="hero-actions">
                                        <%-- 操作按钮 btnAcceptFriend：点击后触发后台事件处理当前业务动作。 --%>
                                        <asp:LinkButton ID="btnAcceptFriend" runat="server" CssClass="btn-primary small" CommandName="Accept" CommandArgument='<%# Eval("Id") %>'>通过</asp:LinkButton>
                                        <%-- 操作按钮 btnRejectFriend：点击后触发后台事件处理当前业务动作。 --%>
                                        <asp:LinkButton ID="btnRejectFriend" runat="server" CssClass="btn-secondary small" CommandName="Reject" CommandArgument='<%# Eval("Id") %>'>拒绝</asp:LinkButton>
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
                        <h2>我的好友</h2>
                    </div>
                    <div class="mini-card-grid">
                        <%-- 数据列表控件 rptFriends：后台绑定集合数据后，按 ItemTemplate 循环渲染每条记录。 --%>
                        <asp:Repeater ID="rptFriends" runat="server">
                            <%-- 列表项模板：定义 Repeater 中每一条业务记录的 HTML 结构和绑定字段。 --%>
                            <ItemTemplate>
                                <%-- 内容卡片：用于组织当前模块中的一组相关信息。 --%>
                                <article class="compact-card">
                                    <img src='<%# string.IsNullOrWhiteSpace(Convert.ToString(Eval("AvatarUrl"))) ? "https://images.unsplash.com/photo-1500648767791-00dcc994a43e?auto=format&fit=crop&w=600&q=80" : Eval("AvatarUrl") %>' alt='<%# Eval("DisplayName") %>' />
                                    <div class="compact-card-body">
                                        <span class="badge-inline"><%# Eval("ReputationLevel") %></span>
                                        <h3><%# Eval("DisplayName") %></h3>
                                        <p><%# Eval("FavoriteGenre") %></p>
                                        <p class="meta-copy">成为好友 <%# Eval("CreatedAt", "{0:yyyy-MM-dd}") %></p>
                                    </div>
                                </article>
                            </ItemTemplate>
                        </asp:Repeater>
                    </div>

                    <%-- 模块标题区：说明当前业务模块的名称和处理说明。 --%>
                    <div class="section-heading compact">
                        <h2>已发出的申请</h2>
                    </div>
                    <%-- 列表容器：承载 Repeater 渲染出的多条业务卡片。 --%>
                    <div class="reservation-list">
                        <%-- 数据列表控件 rptOutgoingFriendRequests：后台绑定集合数据后，按 ItemTemplate 循环渲染每条记录。 --%>
                        <asp:Repeater ID="rptOutgoingFriendRequests" runat="server">
                            <%-- 列表项模板：定义 Repeater 中每一条业务记录的 HTML 结构和绑定字段。 --%>
                            <ItemTemplate>
                                <%-- 业务卡片：展示一条预约、审核、消息或统计记录。 --%>
                                <article class="reservation-card">
                                    <h3>发给 <%# Eval("ReceiverDisplayName") %></h3>
                                    <p>状态 <%# Eval("Status") %></p>
                                    <p><%# string.IsNullOrWhiteSpace(Convert.ToString(Eval("RequestMessage"))) ? "未填写附言" : Eval("RequestMessage") %></p>
                                    <small><%# Eval("CreatedAt", "{0:yyyy-MM-dd HH:mm}") %></small>
                                </article>
                            </ItemTemplate>
                        </asp:Repeater>
                    </div>
                </article>
            </div>
        </section>
    </asp:Panel>
</asp:Content>
