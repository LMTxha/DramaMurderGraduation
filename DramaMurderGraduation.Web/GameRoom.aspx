<%@ Page Title="游戏房间 | 剧本杀系统" Language="C#" MasterPageFile="~/Site.Master" AutoEventWireup="true" CodeBehind="GameRoom.aspx.cs" Inherits="DramaMurderGraduation.Web.GameRoomPage" %>
<%-- 页面用途：GameRoom 页面负责承载对应功能的 Web Forms 标记、服务端控件和前端布局。 --%>
<asp:Content ID="Content1" ContentPlaceHolderID="TitleContent" runat="server">
    游戏房间 | 剧本杀系统
</asp:Content>
<asp:Content ID="Content2" ContentPlaceHolderID="MainContent" runat="server">
    <%-- 面板控件 pnlNotFound：后台可通过 Visible/CssClass 控制整块内容是否显示以及提示样式。 --%>
    <asp:Panel ID="pnlNotFound" runat="server" Visible="false" CssClass="section-block">
        <div class="container empty-state">
            <h1>未找到对应的游戏房间</h1>
            <p>请先完成预约，或从房间大厅重新进入正式游戏房间。</p>
            <a class="btn-primary" href="Booking.aspx">返回预约页面</a>
        </div>
    </asp:Panel>

    <%-- 面板控件 pnlRoom：后台可通过 Visible/CssClass 控制整块内容是否显示以及提示样式。 --%>
    <asp:Panel ID="pnlRoom" runat="server" Visible="false">
        <%-- 页面头图区：展示当前功能的标题、说明和关键入口。 --%>
        <section class="detail-hero">
            <div class="container detail-grid">
                <%-- 说明卡片：展示页面主标题、摘要和关键标签。 --%>
                <article class="detail-copy" data-game-room data-room-endpoint="GameRoom.aspx" data-reservation-id='<%= Request.QueryString["reservationId"] %>'>
                    <p class="eyebrow">Game Room</p>
                    <h1>多人游戏房间</h1>
                    <p class="hero-subtitle">这里会同步同房玩家、角色分配、阶段进度、线索板、终局投票和 DM 控场操作。</p>
                    <%-- 摘要标签区：展示当前页面最重要的数量或状态提示。 --%>
                    <div class="detail-tags">
                        <span>房间号：<asp:Literal ID="litRoomCode" runat="server" /></span>
                        <span>剧本：<asp:Literal ID="litScriptName" runat="server" /></span>
                        <span>DM：<asp:Literal ID="litHostName" runat="server" /></span>
                    </div>
                    <div class="detail-prices">
                        <strong>¥<asp:Literal ID="litTotalAmount" runat="server" /></strong>
                        <span><asp:Literal ID="litPlayerCount" runat="server" /> 人入场</span>
                        <span><asp:Literal ID="litPaymentStatus" runat="server" /></span>
                    </div>
                    <div class="room-status-bar">
                        <span>房间：<asp:Literal ID="litRoomName" runat="server" /></span>
                        <span>开场：<asp:Literal ID="litSessionTime" runat="server" /></span>
                        <span>联系人：<asp:Literal ID="litContactName" runat="server" /></span>
                    </div>
                    <%-- 操作按钮区：集中放置提交、重置、跳转或审核动作。 --%>
                    <div class="hero-actions">
                        <a class="btn-secondary" href='<%= "GameLobby.aspx?reservationId=" + Request.QueryString["reservationId"] %>'>返回房间大厅</a>
                        <a class="btn-secondary" href='<%= "CharacterDossier.aspx?reservationId=" + Request.QueryString["reservationId"] %>'>我的角色本</a>
                        <a class="btn-secondary" href='<%= "GameResult.aspx?reservationId=" + Request.QueryString["reservationId"] %>'>查看结案归档</a>
                        <a class="btn-secondary" href='<%= "RoomGroupChat.aspx?reservationId=" + Request.QueryString["reservationId"] %>'>房间公聊</a>
                        <a class="btn-secondary" href="PlayerHub.aspx?tab=orders">我的订单房间</a>
                        <asp:LinkButton ID="btnLeaveGame" runat="server" CssClass="btn-secondary danger-button" OnClick="btnLeaveGame_Click" OnClientClick="return confirm('确认退出这个游戏房间吗？退出后会取消该预约并立即释放本场名额。');">退出游戏</asp:LinkButton>
                        <a class="btn-secondary" href="ScriptsList.aspx">查看剧本库</a>
                    </div>
                </article>

                <%-- 信息面板：承载一个独立的业务说明、列表或表单模块。 --%>
                <article class="about-panel">
                    <%-- 模块标题区：说明当前业务模块的名称和处理说明。 --%>
                    <div class="section-heading left">
                        <h2>房间说明</h2>
                        <p>玩家在这里推进游戏，管理员或 DM 可以在控制台切换阶段、发公告、发线索并完成结案。</p>
                    </div>
                    <p class="about-text">预约编号：<asp:Literal ID="litReservationId" runat="server" /></p>
                    <p class="about-text">当前状态：<asp:Literal ID="litReservationStatus" runat="server" /></p>
                    <p class="about-text">主持人：<asp:Literal ID="litHostNameAside" runat="server" /></p>
                    <p class="about-text">玩家可进入自己的角色本查看私密信息；DM 可看到控场面板和结案设置。</p>
                </article>
            </div>
        </section>

        <nav class="game-room-side-rail" data-room-side-rail>
            <a class='<%= ModuleNavClass("stage") %>' href='<%= RoomFeatureUrl("stage") %>' data-room-nav-link>剧情阶段</a>
            <a href='<%= RoomFeatureUrl("character") %>' data-room-nav-link>角色卡</a>
            <a class='<%= ModuleNavClass("clue") %>' href='<%= RoomFeatureUrl("clue") %>' data-room-nav-link>线索板</a>
            <a class='<%= ModuleNavClass("action") %>' href='<%= RoomFeatureUrl("action") %>' data-room-nav-link>行动记录</a>
            <a class='<%= ModuleNavClass("vote") %>' href='<%= RoomFeatureUrl("vote") %>' data-room-nav-link>终局投票</a>
            <a href='<%= RoomFeatureUrl("ending") %>' data-room-nav-link>结案复盘</a>
            <a class='<%= ModuleNavClass("participants") %>' href='<%= RoomFeatureUrl("participants") %>' data-room-nav-link>同房玩家</a>
            <a class='<%= ModuleNavClass("media") %>' href='<%= RoomFeatureUrl("media") %>' data-room-nav-link>视频语音</a>
            <a href='<%= RoomFeatureUrl("chat") %>' data-room-nav-link>房间公聊</a>
            <a class='<%= ModuleNavClass("host") %>' href='<%= RoomFeatureUrl("host") %>' data-room-nav-link data-side-dm-link hidden>DM 控制台</a>
            <div class="room-side-stats">
                <a href='<%= RoomFeatureUrl("stage") %>' data-room-nav-link data-side-stage>阶段同步中</a>
                <a href='<%= RoomFeatureUrl("participants") %>' data-room-nav-link data-side-ready>就位 0/0</a>
                <a href='<%= RoomFeatureUrl("vote-status") %>' data-room-nav-link data-side-vote>投票 0/0</a>
            </div>
            <button type="button" class="btn-secondary small" data-side-ready-toggle>就位</button>
            <button type="button" class="btn-secondary small" data-side-refresh>同步</button>
            <button type="button" class="btn-secondary small" data-collapse-room-modules>收起模块</button>
            <button type="button" class="btn-secondary small" data-expand-room-modules>展开模块</button>
        </nav>

        <%-- 次级内容区：用于承载筛选、配置、辅助列表或补充信息。 --%>
        <section class="section-block alt<%= ModuleSectionClass("host") %>">
            <div class="container">
                <%-- 信息面板：承载一个独立的业务说明、列表或表单模块。 --%>
                <article class="about-panel host-console-panel<%= ModuleItemClass("host") %>" id="room-host-panel" data-host-panel hidden>
                    <%-- 模块标题区：说明当前业务模块的名称和处理说明。 --%>
                    <div class="section-heading left">
                        <h2>DM 控制台</h2>
                        <p>主持人可在房间内发布公告、定向发放线索、切换阶段、设置真凶、保存备注并开启计时。</p>
                    </div>
                    <div class="host-console-grid host-console-grid-wide">
                        <div class="host-console-card">
                            <h3>房间生命周期</h3>
                            <div class="host-lifecycle-grid" data-host-lifecycle></div>
                            <%-- 操作按钮区：集中放置提交、重置、跳转或审核动作。 --%>
                            <div class="hero-actions">
                                <button type="button" class="btn-primary" data-host-start-game>正式开局</button>
                                <button type="button" class="btn-secondary" data-host-open-vote>开启终局投票</button>
                                <button type="button" class="btn-secondary" data-advance-stage>推进下一阶段</button>
                                <button type="button" class="btn-secondary" data-host-finish-game>完成结算</button>
                            </div>
                        </div>
                        <div class="host-console-card">
                            <h3>房间公告</h3>
                            <div class="field-group full">
                                <label for="hostNoticeInput">公告内容</label>
                                <textarea id="hostNoticeInput" class="input-control textarea" rows="4" data-host-notice placeholder="例如：第一轮搜证开始，请先从时间线和关键物品入手。"></textarea>
                            </div>
                            <%-- 操作按钮区：集中放置提交、重置、跳转或审核动作。 --%>
                            <div class="hero-actions">
                                <button type="button" class="btn-primary" data-host-broadcast>发布公告</button>
                            </div>
                        </div>
                        <div class="host-console-card">
                            <h3>线索发放</h3>
                            <div class="field-group">
                                <label for="hostClueSelect">剧本线索</label>
                                <select id="hostClueSelect" class="input-control" data-host-clue></select>
                            </div>
                            <div class="field-group">
                                <label for="hostClueSearchInput">线索搜索</label>
                                <input id="hostClueSearchInput" type="text" class="input-control" data-host-clue-search placeholder="按标题、类型或文件名搜索" />
                            </div>
                            <div class="host-clue-preview" data-host-clue-preview>
                                <p class="inline-note">请选择一条待发线索。</p>
                            </div>
                            <div class="field-group">
                                <label for="hostTargetSelect">目标玩家</label>
                                <select id="hostTargetSelect" class="input-control" data-host-target></select>
                            </div>
                            <%-- 操作按钮区：集中放置提交、重置、跳转或审核动作。 --%>
                            <div class="hero-actions">
                                <button type="button" class="btn-primary" data-host-reveal>发放线索</button>
                                <a class="btn-secondary" data-result-link href='<%= "GameResult.aspx?reservationId=" + Request.QueryString["reservationId"] %>'>打开结案页</a>
                            </div>
                        </div>
                        <div class="host-console-card">
                            <h3>阶段控制</h3>
                            <div class="field-group">
                                <label for="hostStageSelect">切换到指定阶段</label>
                                <select id="hostStageSelect" class="input-control" data-host-stage></select>
                            </div>
                            <%-- 操作按钮区：集中放置提交、重置、跳转或审核动作。 --%>
                            <div class="hero-actions">
                                <button type="button" class="btn-primary" data-host-set-stage>应用阶段</button>
                            </div>
                        </div>
                        <div class="host-console-card">
                            <h3>结案设置</h3>
                            <div class="field-group">
                                <label for="hostTruthCharacterSelect">真凶角色</label>
                                <select id="hostTruthCharacterSelect" class="input-control" data-host-truth-character></select>
                            </div>
                            <div class="field-group full">
                                <label for="hostTruthSummaryInput">真相摘要</label>
                                <textarea id="hostTruthSummaryInput" class="input-control textarea" rows="4" data-host-truth-summary placeholder="填写最终复盘时要展示的真相、动机和关键手法。"></textarea>
                            </div>
                            <%-- 操作按钮区：集中放置提交、重置、跳转或审核动作。 --%>
                            <div class="hero-actions">
                                <button type="button" class="btn-primary" data-host-save-truth>保存结案信息</button>
                            </div>
                        </div>
                        <div class="host-console-card">
                            <h3>计时与备注</h3>
                            <div class="field-group">
                                <label for="hostTimerMinutes">阶段计时（分钟）</label>
                                <input id="hostTimerMinutes" type="number" min="1" max="240" value="20" class="input-control" data-host-timer-minutes />
                            </div>
                            <div class="field-group full">
                                <label for="hostDmNotes">DM 私有备注</label>
                                <textarea id="hostDmNotes" class="input-control textarea" rows="4" data-host-dm-notes placeholder="记录玩家进度、临场提醒、下一步旁白和控场策略。"></textarea>
                            </div>
                            <%-- 操作按钮区：集中放置提交、重置、跳转或审核动作。 --%>
                            <div class="hero-actions">
                                <button type="button" class="btn-primary" data-host-start-timer>开始计时</button>
                                <button type="button" class="btn-secondary" data-host-save-notes>保存备注</button>
                            </div>
                        </div>
                    </div>
                    <p class="inline-note" data-host-feedback>DM 的操作会同步到当前房间。</p>
                </article>
            </div>
        </section>

        <%-- 主要内容区：承载当前页面的核心业务列表、表单或详情内容。 --%>
        <section class="section-block<%= ModuleSectionClass("stage", "character") %>">
            <div class="container gameplay-grid">
                <%-- 信息面板：承载一个独立的业务说明、列表或表单模块。 --%>
                <article class="about-panel gameplay-panel<%= ModuleItemClass("stage") %>" id="room-stage-panel">
                    <%-- 模块标题区：说明当前业务模块的名称和处理说明。 --%>
                    <div class="section-heading left">
                        <h2>剧情阶段</h2>
                        <p>当前阶段会实时更新，所有人能看到现在应当开场、搜证、推理还是投票。</p>
                    </div>
                    <div class="stage-highlight" data-current-stage-card>
                        <span class="stage-badge" data-current-stage-order>阶段加载中</span>
                        <h3 data-current-stage-name>正在同步当前剧情阶段...</h3>
                        <p class="about-text" data-current-stage-description>系统会根据当前房间状态读取阶段。</p>
                        <p class="inline-note" data-current-stage-updated></p>
                    </div>
                    <div class="room-live-sync-card">
                        <div class="room-live-sync-head">
                            <div>
                                <span class="stage-badge">自动同步</span>
                                <h3>房间实时动态</h3>
                                <p class="about-text" data-live-sync-status>正在连接房间状态...</p>
                            </div>
                        </div>
                        <div class="room-live-sync-feed" data-live-updates>
                            <p class="inline-note">阶段推进、线索解锁、投票变化和房间消息会在这里提示。</p>
                        </div>
                    </div>
                    <div class="room-lifecycle-grid" data-lifecycle-summary></div>
                    <p class="inline-note" data-resume-summary>房间会在你重进后恢复到最新阶段。</p>
                    <%-- 操作按钮区：集中放置提交、重置、跳转或审核动作。 --%>
                    <div class="hero-actions">
                        <button type="button" class="btn-primary" data-toggle-ready>标记我已就位</button>
                    </div>
                    <p class="inline-note" data-game-feedback>角色状态、线索解锁和行动记录会自动刷新。</p>
                    <div class="timeline-list" data-stage-timeline></div>
                </article>

                <%-- 信息面板：承载一个独立的业务说明、列表或表单模块。 --%>
                <article class="about-panel gameplay-panel<%= ModuleItemClass("character") %>" id="room-character-panel">
                    <%-- 模块标题区：说明当前业务模块的名称和处理说明。 --%>
                    <div class="section-heading left">
                        <h2>我的角色卡</h2>
                        <p>你的角色卡展示身份、性格和个人秘密。</p>
                    </div>
                    <%-- 操作按钮区：集中放置提交、重置、跳转或审核动作。 --%>
                    <div class="hero-actions">
                        <a class="btn-secondary" href='<%= "CharacterDossier.aspx?reservationId=" + Request.QueryString["reservationId"] %>'>打开玩家私有角色本</a>
                    </div>
                    <div class="character-sheet" data-current-assignment></div>
                    <%-- 模块标题区：说明当前业务模块的名称和处理说明。 --%>
                    <div class="section-heading compact">
                        <h3>全员角色分配</h3>
                        <p>同一场次中的玩家会分配到不同角色。</p>
                    </div>
                    <div class="roster-grid" data-character-roster></div>
                </article>
            </div>
        </section>

        <%-- 次级内容区：用于承载筛选、配置、辅助列表或补充信息。 --%>
        <section class="section-block alt<%= ModuleSectionClass("clue", "action") %>">
            <div class="container gameplay-grid">
                <%-- 信息面板：承载一个独立的业务说明、列表或表单模块。 --%>
                <article class="about-panel gameplay-panel<%= ModuleItemClass("clue") %>" id="room-clue-panel">
                    <%-- 模块标题区：说明当前业务模块的名称和处理说明。 --%>
                    <div class="section-heading left">
                        <h2>线索板</h2>
                        <p>公共线索随阶段推进解锁，私密线索由 DM 定向发放或玩家行动触发。</p>
                    </div>
                    <div class="clue-board" data-clue-board></div>
                </article>

                <%-- 信息面板：承载一个独立的业务说明、列表或表单模块。 --%>
                <article class="about-panel gameplay-panel<%= ModuleItemClass("action") %>" id="room-action-panel">
                    <%-- 模块标题区：说明当前业务模块的名称和处理说明。 --%>
                    <div class="section-heading left">
                        <h2>行动记录</h2>
                        <p>每次调查和关键推理都会留下记录。</p>
                    </div>
                    <div class="chat-feed action-feed" data-action-logs></div>
                    <%-- 表单网格：按响应式布局排列输入框、下拉框和筛选条件。 --%>
                    <div class="form-grid single-form">
                        <div class="field-group">
                            <label for="gameActionTitle">行动标题</label>
                            <input id="gameActionTitle" type="text" class="input-control" maxlength="40" data-action-title placeholder="请输入本轮行动标题" />
                        </div>
                        <div class="field-group full">
                            <label for="gameActionContent">行动描述</label>
                            <textarea id="gameActionContent" class="input-control textarea" rows="4" data-action-content placeholder="请输入本轮调查内容或推理记录"></textarea>
                        </div>
                    </div>
                    <%-- 操作按钮区：集中放置提交、重置、跳转或审核动作。 --%>
                    <div class="hero-actions">
                        <button type="button" class="btn-primary" data-submit-action>提交行动并尝试解锁线索</button>
                    </div>
                </article>
            </div>
        </section>

        <%-- 主要内容区：承载当前页面的核心业务列表、表单或详情内容。 --%>
        <section class="section-block<%= ModuleSectionClass("vote", "ending") %>">
            <div class="container gameplay-grid">
                <%-- 信息面板：承载一个独立的业务说明、列表或表单模块。 --%>
                <article class="about-panel gameplay-panel<%= ModuleItemClass("vote") %>" id="room-vote-panel">
                    <%-- 模块标题区：说明当前业务模块的名称和处理说明。 --%>
                    <div class="section-heading left">
                        <h2>终局投票</h2>
                        <p>进入终局复盘阶段后，玩家可以选择自己认定的真凶并提交理由。</p>
                    </div>
                    <div class="vote-panel">
                        <div class="field-group">
                            <label for="voteSuspectSelect">投票对象</label>
                            <select id="voteSuspectSelect" class="input-control" data-vote-select>
                                <option value="">请先进入终局阶段</option>
                            </select>
                        </div>
                        <div class="field-group full">
                            <label for="voteCommentInput">投票理由</label>
                            <textarea id="voteCommentInput" class="input-control textarea" rows="4" data-vote-comment placeholder="写下你的推理依据。"></textarea>
                        </div>
                    </div>
                    <%-- 操作按钮区：集中放置提交、重置、跳转或审核动作。 --%>
                    <div class="hero-actions">
                        <button type="button" class="btn-primary" data-submit-vote>提交终局投票</button>
                    </div>
                    <p class="inline-note" data-vote-feedback>系统会在提交后同步最新票型。</p>
                    <div class="vote-summary-grid" data-vote-summary></div>
                </article>

                <%-- 信息面板：承载一个独立的业务说明、列表或表单模块。 --%>
                <article class="about-panel gameplay-panel<%= ModuleItemClass("ending") %>" id="room-ending-panel">
                    <%-- 模块标题区：说明当前业务模块的名称和处理说明。 --%>
                    <div class="section-heading left">
                        <h2>结案复盘</h2>
                        <p>DM 或结算后的玩家可以看到真凶角色和真相摘要。</p>
                    </div>
                    <div class="ending-summary" data-ending-summary>
                        <p class="inline-note">终局结算前隐藏真相，避免提前剧透。</p>
                    </div>
                </article>
            </div>
        </section>

        <%-- 次级内容区：用于承载筛选、配置、辅助列表或补充信息。 --%>
        <section class="section-block alt<%= ModuleSectionClass("participants", "media") %>">
            <div class="container room-grid">
                <%-- 信息面板：承载一个独立的业务说明、列表或表单模块。 --%>
                <article class="about-panel<%= ModuleItemClass("participants") %>" id="room-participant-panel">
                    <%-- 模块标题区：说明当前业务模块的名称和处理说明。 --%>
                    <div class="section-heading left">
                        <h2>同房玩家</h2>
                        <p>展示同场玩家和媒体状态。</p>
                    </div>
                    <div class="participant-grid" data-room-participants></div>
                </article>

                <%-- 信息面板：承载一个独立的业务说明、列表或表单模块。 --%>
                <article class="about-panel<%= ModuleItemClass("media") %>" id="room-media-panel">
                    <%-- 模块标题区：说明当前业务模块的名称和处理说明。 --%>
                    <div class="section-heading left">
                        <h2>视频与语音</h2>
                        <p>启用摄像头后可同步画面快照，语音留言会留在房间里。</p>
                    </div>
                    <div class="media-panel">
                        <video class="room-video" data-local-video autoplay muted playsinline></video>
                        <div class="room-video-placeholder" data-video-placeholder>等待启用摄像头</div>
                    </div>
                    <p class="inline-note" data-media-status>当前尚未同步摄像头与麦克风状态。</p>
                    <%-- 操作按钮区：集中放置提交、重置、跳转或审核动作。 --%>
                    <div class="hero-actions">
                        <button type="button" class="btn-primary" data-enable-media>启用视频和麦克风</button>
                        <button type="button" class="btn-secondary" data-sync-snapshot>同步我的画面</button>
                        <button type="button" class="btn-secondary" data-record-voice>开始录音</button>
                        <button type="button" class="btn-secondary" data-stop-voice disabled>停止录音</button>
                    </div>
                    <div class="voice-feed" data-voice-messages></div>
                </article>
            </div>
        </section>
    </asp:Panel>
</asp:Content>
