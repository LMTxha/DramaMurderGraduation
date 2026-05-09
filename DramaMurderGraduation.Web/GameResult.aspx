<%@ Page Title="结案归档 | 剧本杀系统" Language="C#" MasterPageFile="~/Site.Master" AutoEventWireup="true" CodeBehind="GameResult.aspx.cs" Inherits="DramaMurderGraduation.Web.GameResultPage" %>
<%-- 页面用途：GameResult 页面负责承载对应功能的 Web Forms 标记、服务端控件和前端布局。 --%>
<asp:Content ID="Content1" ContentPlaceHolderID="TitleContent" runat="server">
    结案归档 | 剧本杀系统
</asp:Content>
<asp:Content ID="Content2" ContentPlaceHolderID="MainContent" runat="server">
    <%-- 面板控件 pnlNotFound：后台可通过 Visible/CssClass 控制整块内容是否显示以及提示样式。 --%>
    <asp:Panel ID="pnlNotFound" runat="server" Visible="false" CssClass="section-block">
        <div class="container empty-state">
            <h1>未找到对应的结案归档</h1>
            <p>请先完成预约并进入有效房间后，再查看本场剧本的结案记录。</p>
            <a class="btn-primary" href="Booking.aspx">返回预约页面</a>
        </div>
    </asp:Panel>

    <%-- 面板控件 pnlResult：后台可通过 Visible/CssClass 控制整块内容是否显示以及提示样式。 --%>
    <asp:Panel ID="pnlResult" runat="server" Visible="false" CssClass="game-room-module-page game-room-module-ending">
        <nav class="game-room-side-rail" data-room-side-rail>
            <a href='<%= ResultFeatureUrl("stage") %>' data-room-nav-link>剧情阶段</a>
            <a href='<%= ResultFeatureUrl("character") %>' data-room-nav-link>角色卡</a>
            <a href='<%= ResultFeatureUrl("clue") %>' data-room-nav-link>线索板</a>
            <a href='<%= ResultFeatureUrl("action") %>' data-room-nav-link>行动记录</a>
            <a href='<%= ResultFeatureUrl("vote") %>' data-room-nav-link>终局投票</a>
            <a class="is-active" href='<%= ResultFeatureUrl("ending") %>' data-room-nav-link>结案复盘</a>
            <a href='<%= ResultFeatureUrl("participants") %>' data-room-nav-link>同房玩家</a>
            <a href='<%= ResultFeatureUrl("media") %>' data-room-nav-link>视频语音</a>
            <a href='<%= ResultFeatureUrl("chat") %>' data-room-nav-link>房间公聊</a>
            <asp:PlaceHolder ID="phResultDmLink" runat="server" Visible="false">
                <a href='<%= ResultFeatureUrl("host") %>' data-room-nav-link>DM 控制台</a>
            </asp:PlaceHolder>
            <div class="room-side-stats">
                <a href='<%= ResultFeatureUrl("stage") %>' data-room-nav-link><asp:Literal ID="litResultSideStage" runat="server" /></a>
                <a href='<%= ResultFeatureUrl("participants") %>' data-room-nav-link><asp:Literal ID="litResultSideReady" runat="server" /></a>
                <a href='<%= ResultFeatureUrl("vote-status") %>' data-room-nav-link><asp:Literal ID="litResultSideVote" runat="server" /></a>
            </div>
        </nav>
        <%-- 页面头图区：展示当前功能的标题、说明和关键入口。 --%>
        <section class="detail-hero">
            <div class="container detail-grid">
                <%-- 说明卡片：展示页面主标题、摘要和关键标签。 --%>
                <article class="detail-copy">
                    <p class="eyebrow">Case Archive</p>
                    <h1>本场结案归档</h1>
                    <p class="hero-subtitle">这里集中展示当前房间的剧本信息、终局票型、真相摘要和关键推进记录。</p>
                    <%-- 摘要标签区：展示当前页面最重要的数量或状态提示。 --%>
                    <div class="detail-tags">
                        <span>剧本：<asp:Literal ID="litScriptName" runat="server" /></span>
                        <span>房间：<asp:Literal ID="litRoomName" runat="server" /></span>
                        <span>DM：<asp:Literal ID="litHostName" runat="server" /></span>
                    </div>
                    <div class="detail-prices">
                        <strong data-result-stage><asp:Literal ID="litCurrentStage" runat="server" /></strong>
                        <span>预约编号：<asp:Literal ID="litReservationId" runat="server" /></span>
                        <span>房间号：<asp:Literal ID="litRoomCode" runat="server" /></span>
                    </div>
                    <%-- 操作按钮区：集中放置提交、重置、跳转或审核动作。 --%>
                    <div class="hero-actions">
                        <%-- 跳转链接控件：根据绑定数据生成详情页、沟通页或外部页面入口。 --%>
                        <asp:HyperLink ID="lnkBackToRoom" runat="server" CssClass="btn-primary">返回游戏房间</asp:HyperLink>
                        <%-- 跳转链接控件：根据绑定数据生成详情页、沟通页或外部页面入口。 --%>
                        <asp:HyperLink ID="lnkBackToLobby" runat="server" CssClass="btn-secondary">返回房间大厅</asp:HyperLink>
                    </div>
                </article>

                <%-- 信息面板：承载一个独立的业务说明、列表或表单模块。 --%>
                <article class="about-panel">
                    <%-- 模块标题区：说明当前业务模块的名称和处理说明。 --%>
                    <div class="section-heading left">
                        <h2>真相摘要</h2>
                        <p>DM 可在游戏房间的结案设置中为每一场独立保存真凶和真相摘要。</p>
                    </div>
                    <div class="ending-summary">
                        <span class="stage-badge"><asp:Literal ID="litResultBadge" runat="server" /></span>
                        <h3>真凶角色：<asp:Literal ID="litCorrectCharacterName" runat="server" /></h3>
                        <p class="about-text"><asp:Literal ID="litTruthSummary" runat="server" /></p>
                    </div>
                </article>
            </div>
        </section>

        <%-- 主要内容区：承载当前页面的核心业务列表、表单或详情内容。 --%>
        <section class="section-block">
            <div class="container gameplay-grid">
                <%-- 信息面板：承载一个独立的业务说明、列表或表单模块。 --%>
                <article class="about-panel gameplay-panel">
                    <%-- 模块标题区：说明当前业务模块的名称和处理说明。 --%>
                    <div class="section-heading left">
                        <h2>终局票型</h2>
                        <p>展示当前房间所有角色的得票结果。</p>
                    </div>
                    <div class="vote-summary-grid">
                        <%-- 数据列表控件 rptVotes：后台绑定集合数据后，按 ItemTemplate 循环渲染每条记录。 --%>
                        <asp:Repeater ID="rptVotes" runat="server">
                            <%-- 列表项模板：定义 Repeater 中每一条业务记录的 HTML 结构和绑定字段。 --%>
                            <ItemTemplate>
                                <%-- 内容卡片：用于组织当前模块中的一组相关信息。 --%>
                                <article class='vote-card<%# Convert.ToBoolean(Eval("IsCorrect")) ? " correct" : string.Empty %>'>
                                    <span class="vote-count"><%# Eval("VoteCount") %> 票</span>
                                    <h3><%# Eval("SuspectCharacterName") %></h3>
                                    <p><%# Convert.ToBoolean(Eval("IsCorrect")) ? "系统设定真凶" : "可被指认角色" %></p>
                                </article>
                            </ItemTemplate>
                        </asp:Repeater>
                    </div>
                </article>

                <%-- 信息面板：承载一个独立的业务说明、列表或表单模块。 --%>
                <article class="about-panel gameplay-panel">
                    <%-- 模块标题区：说明当前业务模块的名称和处理说明。 --%>
                    <div class="section-heading left">
                        <h2>剧情阶段时间线</h2>
                        <p>记录本场对局当前所处阶段以及所有流程节点。</p>
                    </div>
                    <div class="timeline-list">
                        <%-- 数据列表控件 rptStages：后台绑定集合数据后，按 ItemTemplate 循环渲染每条记录。 --%>
                        <asp:Repeater ID="rptStages" runat="server">
                            <%-- 列表项模板：定义 Repeater 中每一条业务记录的 HTML 结构和绑定字段。 --%>
                            <ItemTemplate>
                                <%-- 内容卡片：用于组织当前模块中的一组相关信息。 --%>
                                <article class='timeline-card<%# Convert.ToBoolean(Eval("IsCurrent")) ? " current" : string.Empty %>'>
                                    <span class="timeline-tag"><%# Eval("StatusText") %></span>
                                    <h3><%# Eval("StageName") %></h3>
                                    <p><%# Eval("StageDescription") %></p>
                                    <p class="about-text">建议时长：<%# Eval("DurationMinutes") %> 分钟</p>
                                </article>
                            </ItemTemplate>
                        </asp:Repeater>
                    </div>
                </article>
            </div>
        </section>

        <%-- 次级内容区：用于承载筛选、配置、辅助列表或补充信息。 --%>
        <section class="section-block alt">
            <div class="container gameplay-grid">
                <%-- 信息面板：承载一个独立的业务说明、列表或表单模块。 --%>
                <article class="about-panel gameplay-panel">
                    <%-- 模块标题区：说明当前业务模块的名称和处理说明。 --%>
                    <div class="section-heading left">
                        <h2>关键行动日志</h2>
                        <p>从调查到投票的关键动作会在这里留下记录。</p>
                    </div>
                    <div class="chat-feed action-feed">
                        <%-- 数据列表控件 rptActionLogs：后台绑定集合数据后，按 ItemTemplate 循环渲染每条记录。 --%>
                        <asp:Repeater ID="rptActionLogs" runat="server">
                            <%-- 列表项模板：定义 Repeater 中每一条业务记录的 HTML 结构和绑定字段。 --%>
                            <ItemTemplate>
                                <%-- 内容卡片：用于组织当前模块中的一组相关信息。 --%>
                                <article class="chat-bubble">
                                    <strong><%# Eval("PlayerName") %> / <%# Eval("ActionTitle") %></strong>
                                    <span><%# Eval("CreatedAt", "{0:HH:mm:ss}") %> / <%# Eval("ActionType") %></span>
                                    <p><%# Eval("ActionContent") %></p>
                                </article>
                            </ItemTemplate>
                        </asp:Repeater>
                    </div>
                </article>

                <%-- 信息面板：承载一个独立的业务说明、列表或表单模块。 --%>
                <article class="about-panel gameplay-panel">
                    <%-- 模块标题区：说明当前业务模块的名称和处理说明。 --%>
                    <div class="section-heading left">
                        <h2>玩家角色分配</h2>
                        <p>用于回顾本场房间中每位玩家绑定到哪个角色。</p>
                    </div>
                    <div class="roster-grid">
                        <%-- 数据列表控件 rptAssignments：后台绑定集合数据后，按 ItemTemplate 循环渲染每条记录。 --%>
                        <asp:Repeater ID="rptAssignments" runat="server">
                            <%-- 列表项模板：定义 Repeater 中每一条业务记录的 HTML 结构和绑定字段。 --%>
                            <ItemTemplate>
                                <%-- 内容卡片：用于组织当前模块中的一组相关信息。 --%>
                                <article class='roster-card<%# Convert.ToBoolean(Eval("IsReady")) ? " ready" : string.Empty %>'>
                                    <span class="stage-badge"><%# Convert.ToBoolean(Eval("IsReady")) ? "已就位" : "未就位" %></span>
                                    <h3><%# Eval("CharacterName") %></h3>
                                    <p><%# Eval("PlayerName") %></p>
                                    <p class="about-text"><%# Eval("Profession") %> / <%# Eval("Personality") %></p>
                                </article>
                            </ItemTemplate>
                        </asp:Repeater>
                    </div>
                </article>
            </div>
        </section>
    </asp:Panel>
</asp:Content>
