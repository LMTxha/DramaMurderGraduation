<%@ Page Title="角色本 | 剧本杀系统" Language="C#" MasterPageFile="~/Site.Master" AutoEventWireup="true" CodeBehind="CharacterDossier.aspx.cs" Inherits="DramaMurderGraduation.Web.CharacterDossierPage" %>
<%-- 页面用途：CharacterDossier 页面负责承载对应功能的 Web Forms 标记、服务端控件和前端布局。 --%>
<asp:Content ID="Content1" ContentPlaceHolderID="TitleContent" runat="server">
    角色本 | 剧本杀系统
</asp:Content>
<asp:Content ID="Content2" ContentPlaceHolderID="MainContent" runat="server">
    <%-- 面板控件 pnlNotFound：后台可通过 Visible/CssClass 控制整块内容是否显示以及提示样式。 --%>
    <asp:Panel ID="pnlNotFound" runat="server" Visible="false" CssClass="section-block">
        <div class="container empty-state">
            <h1>未找到角色本</h1>
            <p>请先进入有效房间，并确认当前预约已经分配角色。</p>
            <a class="btn-primary" href="Booking.aspx">返回预约页面</a>
        </div>
    </asp:Panel>

    <%-- 面板控件 pnlDossier：后台可通过 Visible/CssClass 控制整块内容是否显示以及提示样式。 --%>
    <asp:Panel ID="pnlDossier" runat="server" Visible="false" CssClass="game-room-module-page game-room-module-character">
        <nav class="game-room-side-rail" data-room-side-rail>
            <a href='<%= DossierFeatureUrl("stage") %>' data-room-nav-link>剧情阶段</a>
            <a class="is-active" href='<%= DossierFeatureUrl("character") %>' data-room-nav-link>角色卡</a>
            <a href='<%= DossierFeatureUrl("clue") %>' data-room-nav-link>线索板</a>
            <a href='<%= DossierFeatureUrl("action") %>' data-room-nav-link>行动记录</a>
            <a href='<%= DossierFeatureUrl("vote") %>' data-room-nav-link>终局投票</a>
            <a href='<%= DossierFeatureUrl("ending") %>' data-room-nav-link>结案复盘</a>
            <a href='<%= DossierFeatureUrl("participants") %>' data-room-nav-link>同房玩家</a>
            <a href='<%= DossierFeatureUrl("media") %>' data-room-nav-link>视频语音</a>
            <a href='<%= DossierFeatureUrl("chat") %>' data-room-nav-link>房间公聊</a>
            <asp:PlaceHolder ID="phDossierDmLink" runat="server" Visible="false">
                <a href='<%= DossierFeatureUrl("host") %>' data-room-nav-link>DM 控制台</a>
            </asp:PlaceHolder>
            <div class="room-side-stats">
                <a href='<%= DossierFeatureUrl("stage") %>' data-room-nav-link><asp:Literal ID="litDossierSideStage" runat="server" /></a>
                <a href='<%= DossierFeatureUrl("participants") %>' data-room-nav-link><asp:Literal ID="litDossierSideReady" runat="server" /></a>
                <a href='<%= DossierFeatureUrl("vote-status") %>' data-room-nav-link><asp:Literal ID="litDossierSideVote" runat="server" /></a>
            </div>
        </nav>
        <%-- 页面头图区：展示当前功能的标题、说明和关键入口。 --%>
        <section class="detail-hero">
            <div class="container detail-grid">
                <%-- 说明卡片：展示页面主标题、摘要和关键标签。 --%>
                <article class="detail-copy">
                    <p class="eyebrow">Private Dossier</p>
                    <h1>我的角色本</h1>
                    <p class="hero-subtitle">这是当前玩家的私有视角，用于查看角色设定、原始角色 PDF、已解锁线索和最近行动记录。</p>
                    <%-- 摘要标签区：展示当前页面最重要的数量或状态提示。 --%>
                    <div class="detail-tags">
                        <span>剧本：<asp:Literal ID="litScriptName" runat="server" /></span>
                        <span>角色：<asp:Literal ID="litCharacterName" runat="server" /></span>
                        <span>房间：<asp:Literal ID="litRoomName" runat="server" /></span>
                    </div>
                    <%-- 操作按钮区：集中放置提交、重置、跳转或审核动作。 --%>
                    <div class="hero-actions">
                        <%-- 跳转链接控件：根据绑定数据生成详情页、沟通页或外部页面入口。 --%>
                        <asp:HyperLink ID="lnkBackRoom" runat="server" CssClass="btn-primary">返回游戏房间</asp:HyperLink>
                        <%-- 跳转链接控件：根据绑定数据生成详情页、沟通页或外部页面入口。 --%>
                        <asp:HyperLink ID="lnkResult" runat="server" CssClass="btn-secondary">查看结案归档</asp:HyperLink>
                    </div>
                </article>

                <%-- 信息面板：承载一个独立的业务说明、列表或表单模块。 --%>
                <article class="about-panel">
                    <%-- 模块标题区：说明当前业务模块的名称和处理说明。 --%>
                    <div class="section-heading left">
                        <h2>当前阶段任务</h2>
                        <p>系统会根据房间所处阶段提示你当前更适合关注的调查方向。</p>
                    </div>
                    <div class="ending-summary dossier-guide">
                        <span class="stage-badge"><asp:Literal ID="litStageName" runat="server" /></span>
                        <h3><asp:Literal ID="litGuideTitle" runat="server" /></h3>
                        <p class="about-text"><asp:Literal ID="litGuideSummary" runat="server" /></p>
                        <div class="dossier-task-stats">
                            <span><asp:Literal ID="litGuideClueCount" runat="server" /></span>
                            <span><asp:Literal ID="litGuideActionCount" runat="server" /></span>
                        </div>
                        <div class="card-actions dossier-guide-actions">
                            <asp:HyperLink ID="lnkGuidePrimary" runat="server" CssClass="btn-primary small">查看相关线索</asp:HyperLink>
                            <asp:HyperLink ID="lnkGuideSecondary" runat="server" CssClass="btn-secondary small">回到游戏房间</asp:HyperLink>
                        </div>
                    </div>
                </article>
            </div>
        </section>

        <%-- 主要内容区：承载当前页面的核心业务列表、表单或详情内容。 --%>
        <section class="section-block">
            <div class="container gameplay-grid">
                <%-- 信息面板：承载一个独立的业务说明、列表或表单模块。 --%>
                <article id="dossier-character" class="about-panel gameplay-panel">
                    <%-- 模块标题区：说明当前业务模块的名称和处理说明。 --%>
                    <div class="section-heading left">
                        <h2>角色设定</h2>
                        <p>这些内容只面向当前玩家展示。</p>
                    </div>
                    <div class="character-sheet">
                        <span class="stage-badge"><asp:Literal ID="litReadyStatus" runat="server" /></span>
                        <h3><asp:Literal ID="litRoleName" runat="server" /></h3>
                        <p class="about-text"><asp:Literal ID="litCharacterDescription" runat="server" /></p>
                        <div class="sheet-grid">
                            <span>玩家：<asp:Literal ID="litPlayerName" runat="server" /></span>
                            <span>人数：<asp:Literal ID="litPlayerCount" runat="server" /> 人</span>
                            <span>性别：<asp:Literal ID="litGender" runat="server" /></span>
                            <span>年龄：<asp:Literal ID="litAgeRange" runat="server" /></span>
                            <span>职业：<asp:Literal ID="litProfession" runat="server" /></span>
                            <span>性格：<asp:Literal ID="litPersonality" runat="server" /></span>
                        </div>
                        <div class="sheet-secret">
                            <strong>私密信息</strong>
                            <p><asp:Literal ID="litSecretLine" runat="server" /></p>
                        </div>
                        <asp:PlaceHolder ID="phRolePdf" runat="server" Visible="false">
                            <div class="sheet-secret">
                                <strong>角色原始 PDF</strong>
                                <p><asp:Literal ID="litRolePdfName" runat="server" /></p>
                                <%-- 跳转链接控件：根据绑定数据生成详情页、沟通页或外部页面入口。 --%>
                                <asp:HyperLink ID="lnkRolePdf" runat="server" CssClass="btn-primary" Target="_blank">打开我的角色本</asp:HyperLink>
                            </div>
                        </asp:PlaceHolder>
                    </div>
                </article>

                <%-- 信息面板：承载一个独立的业务说明、列表或表单模块。 --%>
                <article id="dossier-clues" class="about-panel gameplay-panel">
                    <%-- 模块标题区：说明当前业务模块的名称和处理说明。 --%>
                    <div class="section-heading left">
                        <h2>已解锁线索</h2>
                        <p>这里显示当前玩家视角下可以查看的公共线索和私密线索。</p>
                    </div>
                    <div class="clue-board">
                        <%-- 数据列表控件 rptClues：后台绑定集合数据后，按 ItemTemplate 循环渲染每条记录。 --%>
                        <asp:Repeater ID="rptClues" runat="server">
                            <%-- 列表项模板：定义 Repeater 中每一条业务记录的 HTML 结构和绑定字段。 --%>
                            <ItemTemplate>
                                <%-- 内容卡片：用于组织当前模块中的一组相关信息。 --%>
                                <article class='clue-card <%# Convert.ToBoolean(Eval("IsPublic")) ? "public" : "private" %>'>
                                    <span class="clue-badge"><%# Convert.ToBoolean(Eval("IsPublic")) ? "公共线索" : "私密线索" %></span>
                                    <h3><%# Eval("Title") %></h3>
                                    <p><%# Eval("Summary") %></p>
                                    <p class="about-text"><%# Eval("Detail") %></p>
                                    <div class="clue-meta">
                                        <span><%# Eval("StageName") %></span>
                                        <span><%# Eval("ClueType") %></span>
                                        <span><%# Eval("RevealMethod") %></span>
                                        <span><%# Eval("RevealedAt", "{0:MM-dd HH:mm}") %></span>
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
            <div class="container gameplay-grid">
                <%-- 信息面板：承载一个独立的业务说明、列表或表单模块。 --%>
                <article id="dossier-actions" class="about-panel gameplay-panel">
                    <%-- 模块标题区：说明当前业务模块的名称和处理说明。 --%>
                    <div class="section-heading left">
                        <h2>最近行动记录</h2>
                        <p>用于回顾当前对局中的调查动作、阶段推进和主持人发放的关键信息。</p>
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
                        <h2>房间摘要</h2>
                        <p>快速回顾当前房间、DM 和预约基础信息。</p>
                    </div>
                    <div class="sheet-grid">
                        <span>房间号：<asp:Literal ID="litRoomCode" runat="server" /></span>
                        <span>DM：<asp:Literal ID="litHostName" runat="server" /></span>
                        <span>预约编号：<asp:Literal ID="litReservationId" runat="server" /></span>
                        <span>开场时间：<asp:Literal ID="litSessionTime" runat="server" /></span>
                    </div>
                </article>
            </div>
        </section>
    </asp:Panel>
</asp:Content>
