<%@ Page Title="游戏房间 | 剧本杀系统" Language="C#" MasterPageFile="~/Site.Master" AutoEventWireup="true" CodeBehind="GameRoom.aspx.cs" Inherits="DramaMurderGraduation.Web.GameRoomPage" %>
<asp:Content ID="Content1" ContentPlaceHolderID="TitleContent" runat="server">
    游戏房间 | 剧本杀系统
</asp:Content>
<asp:Content ID="Content2" ContentPlaceHolderID="MainContent" runat="server">
    <asp:Panel ID="pnlNotFound" runat="server" Visible="false" CssClass="section-block">
        <div class="container empty-state">
            <h1>未找到对应的游戏房间</h1>
            <p>请先完成预约，或从房间大厅重新进入正式游戏房间。</p>
            <a class="btn-primary" href="Booking.aspx">返回预约页面</a>
        </div>
    </asp:Panel>

    <asp:Panel ID="pnlRoom" runat="server" Visible="false">
        <section class="detail-hero">
            <div class="container detail-grid">
                <article class="detail-copy" data-game-room data-room-endpoint="GameRoom.aspx" data-reservation-id='<%= Request.QueryString["reservationId"] %>'>
                    <p class="eyebrow">Game Room</p>
                    <h1>多人游戏房间</h1>
                    <p class="hero-subtitle">这里会同步同房玩家、角色分配、阶段进度、线索板、终局投票和 DM 控场操作。</p>
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
                    <div class="hero-actions">
                        <a class="btn-secondary" href='<%= "GameLobby.aspx?reservationId=" + Request.QueryString["reservationId"] %>'>返回房间大厅</a>
                        <a class="btn-secondary" href='<%= "CharacterDossier.aspx?reservationId=" + Request.QueryString["reservationId"] %>'>我的角色本</a>
                        <a class="btn-secondary" href='<%= "GameResult.aspx?reservationId=" + Request.QueryString["reservationId"] %>'>查看结案归档</a>
                        <a class="btn-secondary" href="ScriptsList.aspx">查看剧本库</a>
                    </div>
                </article>

                <article class="about-panel">
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

        <section class="section-block alt">
            <div class="container">
                <article class="about-panel host-console-panel" data-host-panel hidden>
                    <div class="section-heading left">
                        <h2>DM 控制台</h2>
                        <p>主持人可在房间内发布公告、定向发放线索、切换阶段、设置真凶、保存备注并开启计时。</p>
                    </div>
                    <div class="host-console-grid host-console-grid-wide">
                        <div class="host-console-card">
                            <h3>房间生命周期</h3>
                            <div class="host-lifecycle-grid" data-host-lifecycle></div>
                            <div class="hero-actions">
                                <button type="button" class="btn-primary" data-host-start-game>正式开局</button>
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
                            <div class="hero-actions">
                                <button type="button" class="btn-primary" data-host-broadcast>发布公告</button>
                            </div>
                        </div>
                        <div class="host-console-card">
                            <h3>线索发放</h3>
                            <div class="field-group">
                                <label for="hostClueSelect">待发线索</label>
                                <select id="hostClueSelect" class="input-control" data-host-clue></select>
                            </div>
                            <div class="field-group">
                                <label for="hostTargetSelect">目标玩家</label>
                                <select id="hostTargetSelect" class="input-control" data-host-target></select>
                            </div>
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

        <section class="section-block">
            <div class="container gameplay-grid">
                <article class="about-panel gameplay-panel">
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
                    <div class="room-lifecycle-grid" data-lifecycle-summary></div>
                    <p class="inline-note" data-resume-summary>房间会在你重进后恢复到最新阶段。</p>
                    <div class="hero-actions">
                        <button type="button" class="btn-primary" data-toggle-ready>标记我已就位</button>
                    </div>
                    <p class="inline-note" data-game-feedback>角色状态、线索解锁和行动记录会自动刷新。</p>
                    <div class="timeline-list" data-stage-timeline></div>
                </article>

                <article class="about-panel gameplay-panel">
                    <div class="section-heading left">
                        <h2>我的角色卡</h2>
                        <p>你的角色卡展示身份、性格和个人秘密。</p>
                    </div>
                    <div class="hero-actions">
                        <a class="btn-secondary" href='<%= "CharacterDossier.aspx?reservationId=" + Request.QueryString["reservationId"] %>'>打开玩家私有角色本</a>
                    </div>
                    <div class="character-sheet" data-current-assignment></div>
                    <div class="section-heading compact">
                        <h3>全员角色分配</h3>
                        <p>同一场次中的玩家会分配到不同角色。</p>
                    </div>
                    <div class="roster-grid" data-character-roster></div>
                </article>
            </div>
        </section>

        <section class="section-block alt">
            <div class="container gameplay-grid">
                <article class="about-panel gameplay-panel">
                    <div class="section-heading left">
                        <h2>线索板</h2>
                        <p>公共线索随阶段推进解锁，私密线索由 DM 定向发放或玩家行动触发。</p>
                    </div>
                    <div class="clue-board" data-clue-board></div>
                </article>

                <article class="about-panel gameplay-panel">
                    <div class="section-heading left">
                        <h2>行动记录</h2>
                        <p>每次调查和关键推理都会留下记录。</p>
                    </div>
                    <div class="chat-feed action-feed" data-action-logs></div>
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
                    <div class="hero-actions">
                        <button type="button" class="btn-primary" data-submit-action>提交行动并尝试解锁线索</button>
                    </div>
                </article>
            </div>
        </section>

        <section class="section-block">
            <div class="container gameplay-grid">
                <article class="about-panel gameplay-panel">
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
                    <div class="hero-actions">
                        <button type="button" class="btn-primary" data-submit-vote>提交终局投票</button>
                    </div>
                    <p class="inline-note" data-vote-feedback>系统会在提交后同步最新票型。</p>
                    <div class="vote-summary-grid" data-vote-summary></div>
                </article>

                <article class="about-panel gameplay-panel">
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

        <section class="section-block alt">
            <div class="container room-grid">
                <article class="about-panel">
                    <div class="section-heading left">
                        <h2>同房玩家</h2>
                        <p>展示同场玩家和媒体状态。</p>
                    </div>
                    <div class="participant-grid" data-room-participants></div>
                </article>

                <article class="about-panel">
                    <div class="section-heading left">
                        <h2>视频与语音</h2>
                        <p>启用摄像头后可同步画面快照，语音留言会留在房间里。</p>
                    </div>
                    <div class="media-panel">
                        <video class="room-video" data-local-video autoplay muted playsinline></video>
                        <div class="room-video-placeholder" data-video-placeholder>等待启用摄像头</div>
                    </div>
                    <p class="inline-note" data-media-status>当前尚未同步摄像头与麦克风状态。</p>
                    <div class="hero-actions">
                        <button type="button" class="btn-primary" data-enable-media>启用视频和麦克风</button>
                        <button type="button" class="btn-secondary" data-sync-snapshot>同步我的画面</button>
                        <button type="button" class="btn-secondary" data-record-voice>开始录音</button>
                        <button type="button" class="btn-secondary" data-stop-voice disabled>停止录音</button>
                    </div>
                    <div class="voice-feed" data-voice-messages></div>
                </article>

                <article class="about-panel room-chat-panel">
                    <div class="section-heading left">
                        <h2>房间公聊</h2>
                        <p>文字消息会同步到当前房间。</p>
                    </div>
                    <div class="chat-feed" data-room-messages></div>
                    <div class="form-grid single-form">
                        <div class="field-group full">
                            <label for="roomChatInput">发送文字消息</label>
                            <textarea id="roomChatInput" class="input-control textarea" rows="4" data-room-input placeholder="写下你要发给同房玩家或 DM 的信息。"></textarea>
                        </div>
                    </div>
                    <div class="hero-actions">
                        <button type="button" class="btn-primary" data-send-message>发送消息</button>
                        <button type="button" class="btn-secondary" data-refresh-room>刷新房间动态</button>
                    </div>
                    <p class="inline-note" data-room-feedback>房间动态会自动刷新。</p>
                </article>
            </div>
        </section>
    </asp:Panel>
</asp:Content>
