<%@ Page Title="玩家中心 | 剧本杀系统" Language="C#" MasterPageFile="~/Site.Master" AutoEventWireup="true" CodeBehind="PlayerHub.aspx.cs" Inherits="DramaMurderGraduation.Web.PlayerHubPage" %>
<asp:Content ID="Content1" ContentPlaceHolderID="TitleContent" runat="server">
    玩家中心 | 剧本杀系统
</asp:Content>
<asp:Content ID="Content2" ContentPlaceHolderID="MainContent" runat="server">
    <section class="hero-section">
        <div class="container profile-banner">
            <div class="profile-avatar-shell">
                <asp:Image ID="imgAvatar" runat="server" CssClass="profile-avatar" AlternateText="玩家头像" />
            </div>
            <div class="profile-summary">
                <div class="hero-badge-row hub-tab-row">
                    <a class='site-badge<%= ActiveTab == "profile" ? " active" : string.Empty %>' href="PlayerHub.aspx?tab=profile">玩家档案</a>
                    <a class='site-badge soft<%= ActiveTab == "social" ? " active" : string.Empty %>' href="PlayerHub.aspx?tab=social">好友与礼物互动</a>
                </div>
                <p class="eyebrow">PLAYER HUB</p>
                <h1><asp:Literal ID="litDisplayName" runat="server" /></h1>
                <p class="hero-subtitle"><asp:Literal ID="litDisplayTitle" runat="server" /></p>
                <p class="hero-text"><asp:Literal ID="litMotto" runat="server" /></p>
                <div class="detail-tags">
                    <span>偏好类型 <asp:Literal ID="litFavoriteGenre" runat="server" /></span>
                    <span>声望等级 <asp:Literal ID="litReputationLevel" runat="server" /></span>
                </div>
            </div>
            <div class="hero-panel metric-grid-four">
                <a class="metric-card accent click-card interactive-card" href="Friends.aspx#gift-panel">
                    <p>礼物币余额</p>
                    <strong><asp:Literal ID="litGiftBalance" runat="server" /></strong>
                </a>
                <a class="metric-card click-card interactive-card" href="Friends.aspx#gift-panel">
                    <p>累计送礼</p>
                    <strong><asp:Literal ID="litTotalGiftSent" runat="server" /></strong>
                </a>
                <a class="metric-card click-card interactive-card" href="Friends.aspx#moments-panel">
                    <p>礼物收入</p>
                    <strong><asp:Literal ID="litTotalGiftReceived" runat="server" /></strong>
                </a>
                <a class="metric-card click-card interactive-card" href="Friends.aspx#friend-rail">
                    <p>好友数量</p>
                    <strong><asp:Literal ID="litFriendCount" runat="server" /></strong>
                </a>
            </div>
        </div>
    </section>

    <asp:Panel ID="pnlProfileTab" runat="server" CssClass="hub-tab-panel">
        <section class="section-block">
            <div class="container split-grid detail-split">
                <article class="form-panel">
                    <div class="section-heading left">
                        <h2>编辑玩家档案</h2>
                        <p>这里可以真正维护你的玩家名片。改完昵称、头衔、签名、头像和偏好后，顶部资料会马上同步更新。</p>
                    </div>
                    <asp:Panel ID="pnlProfileMessage" runat="server" Visible="false" CssClass="status-message">
                        <asp:Literal ID="litProfileMessage" runat="server" />
                    </asp:Panel>
                    <div class="form-grid hub-form-grid">
                        <div class="field-group">
                            <label for="<%= txtProfileDisplayName.ClientID %>">玩家昵称</label>
                            <asp:TextBox ID="txtProfileDisplayName" runat="server" CssClass="input-control" />
                        </div>
                        <div class="field-group">
                            <label for="<%= txtProfileTitle.ClientID %>">玩家头衔</label>
                            <asp:TextBox ID="txtProfileTitle" runat="server" CssClass="input-control" />
                        </div>
                        <div class="field-group full">
                            <label for="<%= txtProfileMotto.ClientID %>">个性签名</label>
                            <asp:TextBox ID="txtProfileMotto" runat="server" CssClass="input-control" />
                        </div>
                        <div class="field-group full">
                            <label for="<%= txtProfileAvatarUrl.ClientID %>">头像图片 URL</label>
                            <asp:TextBox ID="txtProfileAvatarUrl" runat="server" CssClass="input-control" />
                        </div>
                        <div class="field-group">
                            <label for="<%= ddlProfileFavoriteGenre.ClientID %>">偏好题材</label>
                            <asp:DropDownList ID="ddlProfileFavoriteGenre" runat="server" CssClass="input-control" />
                        </div>
                    </div>
                    <asp:Button ID="btnSaveProfile" runat="server" Text="保存玩家档案" CssClass="btn-primary wide-button" OnClick="btnSaveProfile_Click" />
                </article>

                <article class="about-panel">
                    <div class="section-heading left">
                        <h2>玩家画像</h2>
                        <p>这些能力维度会用来展示你的推理风格、互动习惯和更适合加入哪种车队。</p>
                    </div>
                    <div class="lobby-summary-list">
                        <div class="lobby-summary-item">
                            <span>推荐身份</span>
                            <strong><asp:Literal ID="litRecommendedIdentity" runat="server" /></strong>
                        </div>
                        <div class="lobby-summary-item">
                            <span>局内风格</span>
                            <strong><asp:Literal ID="litPlayStyle" runat="server" /></strong>
                        </div>
                        <div class="lobby-summary-item">
                            <span>成长建议</span>
                            <strong><asp:Literal ID="litGrowthAdvice" runat="server" /></strong>
                        </div>
                        <div class="lobby-summary-item">
                            <span>完成剧本</span>
                            <strong><asp:Literal ID="litCompletedScripts" runat="server" /></strong>
                        </div>
                        <div class="lobby-summary-item">
                            <span>胜率</span>
                            <strong><asp:Literal ID="litWinRate" runat="server" /></strong>
                        </div>
                        <div class="lobby-summary-item">
                            <span>成就数量</span>
                            <strong><asp:Literal ID="litAchievementCount" runat="server" /></strong>
                        </div>
                    </div>
                </article>
            </div>
        </section>

        <section class="section-block alt">
            <div class="container split-grid detail-split">
                <article class="about-panel">
                    <div class="section-heading left">
                        <h2>能力值详情</h2>
                        <p>这是玩家在推理、观察、创造、协作和执行上的能力画像。</p>
                    </div>
                    <div class="ability-list">
                        <asp:Repeater ID="rptAbilities" runat="server">
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

                <article class="about-panel">
                    <div class="section-heading left">
                        <h2>成就勋章墙</h2>
                        <p>保留原来的成长展示内容，但现在玩家档案和社交互动已经和这页真正联动。</p>
                    </div>
                    <div class="achievement-grid">
                        <asp:Repeater ID="rptAchievements" runat="server">
                            <ItemTemplate>
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

        <section class="section-block">
            <div class="container">
                <article class="about-panel">
                    <div class="section-heading left">
                        <h2>最近战绩</h2>
                        <p>每次正式结算后的剧本局都会自动沉淀到这里，方便你回看扮演角色、投票选择和推理结果。</p>
                    </div>
                    <div class="battle-record-grid">
                        <asp:Repeater ID="rptBattleRecords" runat="server">
                            <ItemTemplate>
                                <article class='battle-record-card <%# Convert.ToBoolean(Eval("WasCorrect")) ? "success" : "pending" %>'>
                                    <div class="battle-record-head">
                                        <span class='badge-inline <%# Convert.ToBoolean(Eval("WasCorrect")) ? "success" : "soft" %>'><%# Eval("ResultTag") %></span>
                                        <small><%# Eval("CompletedAt", "{0:yyyy-MM-dd HH:mm}") %></small>
                                    </div>
                                    <h3><%# Eval("ScriptName") %></h3>
                                    <p class="meta-copy">房间：<%# Eval("RoomName") %> · 扮演角色：<%# Eval("CharacterName") %></p>
                                    <p class="meta-copy">你的投票：<%# string.IsNullOrWhiteSpace(Convert.ToString(Eval("VotedCharacterName"))) ? "未提交终局投票" : Eval("VotedCharacterName") %></p>
                                    <p class="meta-copy">系统真凶：<%# Eval("CorrectCharacterName") %></p>
                                    <a class="text-link strong" href='GameResult.aspx?reservationId=<%# Eval("ReservationId") %>'>查看这场结案复盘</a>
                                </article>
                            </ItemTemplate>
                        </asp:Repeater>
                    </div>
                </article>
            </div>
        </section>
    </asp:Panel>

    <asp:Panel ID="pnlSocialTab" runat="server" CssClass="hub-tab-panel">
        <section class="section-block alt" id="gift-panel">
            <div class="container split-grid detail-split">
                <article class="form-panel">
                    <div class="section-heading left">
                        <h2>互动送礼</h2>
                        <p>这里可以真正给其他玩家送礼。选好对象、礼物和数量后，礼物币会立刻扣除，对方也会马上收到。</p>
                    </div>
                    <asp:Panel ID="pnlGiftMessage" runat="server" Visible="false" CssClass="status-message">
                        <asp:Literal ID="litGiftMessage" runat="server" />
                    </asp:Panel>
                    <div class="form-grid hub-form-grid">
                        <div class="field-group">
                            <label for="<%= ddlGiftReceiver.ClientID %>">收礼玩家</label>
                            <asp:DropDownList ID="ddlGiftReceiver" runat="server" CssClass="input-control" />
                        </div>
                        <div class="field-group">
                            <label for="<%= ddlGiftCatalog.ClientID %>">礼物类型</label>
                            <asp:DropDownList ID="ddlGiftCatalog" runat="server" CssClass="input-control" />
                        </div>
                        <div class="field-group">
                            <label for="<%= txtGiftQuantity.ClientID %>">赠送数量</label>
                            <asp:TextBox ID="txtGiftQuantity" runat="server" CssClass="input-control" Text="1" />
                        </div>
                        <div class="field-group full">
                            <label>送礼说明</label>
                            <p class="inline-note">如果礼物币不够，可以先去 <a href="Wallet.aspx" class="text-link strong">钱包中心</a> 兑换。送礼记录、收礼记录和礼物币余额都会同步变化。</p>
                        </div>
                    </div>
                    <asp:Button ID="btnSendGift" runat="server" Text="立即送礼" CssClass="btn-primary wide-button" OnClick="btnSendGift_Click" />

                    <div class="section-heading compact" id="gift-sent">
                        <h2>最近送出</h2>
                        <p>这里展示你最近送给其他玩家的礼物。</p>
                    </div>
                    <div class="reservation-list">
                        <asp:Repeater ID="rptGiftSentRecords" runat="server">
                            <ItemTemplate>
                                <article class="reservation-card">
                                    <h3><%# Eval("GiftIconText") %> <%# Eval("GiftName") %> × <%# Eval("Quantity") %></h3>
                                    <p>送给：<%# Eval("ReceiverDisplayName") %></p>
                                    <p>花费礼物币：<%# Eval("TotalCoins") %></p>
                                    <small><%# Eval("CreatedAt", "{0:yyyy-MM-dd HH:mm}") %></small>
                                </article>
                            </ItemTemplate>
                        </asp:Repeater>
                    </div>
                </article>

                <article class="about-panel" id="gift-received">
                    <div class="section-heading left">
                        <h2>最近收到</h2>
                        <p>这是你收到的礼物记录，方便你查看互动热度。</p>
                    </div>
                    <div class="reservation-list">
                        <asp:Repeater ID="rptGiftReceivedRecords" runat="server">
                            <ItemTemplate>
                                <article class="reservation-card">
                                    <h3><%# Eval("GiftIconText") %> <%# Eval("GiftName") %> × <%# Eval("Quantity") %></h3>
                                    <p>来自：<%# Eval("SenderDisplayName") %></p>
                                    <p>礼物价值：<%# Eval("TotalCoins") %></p>
                                    <small><%# Eval("CreatedAt", "{0:yyyy-MM-dd HH:mm}") %></small>
                                </article>
                            </ItemTemplate>
                        </asp:Repeater>
                    </div>
                </article>
            </div>
        </section>

        <section class="section-block">
            <div class="container split-grid detail-split">
                <article class="form-panel">
                    <div class="section-heading left">
                        <h2>添加好友</h2>
                        <p>这里可以真正发起好友申请。提交后，对方会在自己的玩家中心里看到并决定通过或拒绝。</p>
                    </div>
                    <asp:Panel ID="pnlFriendMessage" runat="server" Visible="false" CssClass="status-message">
                        <asp:Literal ID="litFriendMessage" runat="server" />
                    </asp:Panel>
                    <div class="form-grid hub-form-grid">
                        <div class="field-group">
                            <label for="<%= ddlFriendCandidate.ClientID %>">选择玩家</label>
                            <asp:DropDownList ID="ddlFriendCandidate" runat="server" CssClass="input-control" />
                        </div>
                        <div class="field-group full">
                            <label for="<%= txtFriendRequestMessage.ClientID %>">申请留言</label>
                            <asp:TextBox ID="txtFriendRequestMessage" runat="server" CssClass="input-control" />
                        </div>
                    </div>
                    <asp:Button ID="btnSendFriendRequest" runat="server" Text="发送好友申请" CssClass="btn-primary wide-button" OnClick="btnSendFriendRequest_Click" />

                    <div class="section-heading compact">
                        <h2>收到的申请</h2>
                        <p>你可以在这里通过或拒绝其他玩家的好友申请。</p>
                    </div>
                    <div class="reservation-list">
                        <asp:Repeater ID="rptIncomingFriendRequests" runat="server" OnItemCommand="rptIncomingFriendRequests_ItemCommand">
                            <ItemTemplate>
                                <article class="reservation-card">
                                    <h3><%# Eval("SenderDisplayName") %></h3>
                                    <p><%# string.IsNullOrWhiteSpace(Convert.ToString(Eval("RequestMessage"))) ? "对方没有填写留言。" : Eval("RequestMessage") %></p>
                                    <small><%# Eval("CreatedAt", "{0:yyyy-MM-dd HH:mm}") %></small>
                                    <div class="hero-actions">
                                        <asp:LinkButton ID="btnAcceptFriend" runat="server" CssClass="btn-primary small" CommandName="Accept" CommandArgument='<%# Eval("Id") %>'>通过</asp:LinkButton>
                                        <asp:LinkButton ID="btnRejectFriend" runat="server" CssClass="btn-secondary small" CommandName="Reject" CommandArgument='<%# Eval("Id") %>'>拒绝</asp:LinkButton>
                                    </div>
                                </article>
                            </ItemTemplate>
                        </asp:Repeater>
                    </div>
                </article>

                <article class="about-panel" id="friend-list">
                    <div class="section-heading left">
                        <h2>我的好友</h2>
                        <p>这里会持续展示你当前的好友列表，以及还在等待处理的申请状态。</p>
                    </div>
                    <div class="mini-card-grid">
                        <asp:Repeater ID="rptFriends" runat="server">
                            <ItemTemplate>
                                <article class="compact-card">
                                    <img src='<%# string.IsNullOrWhiteSpace(Convert.ToString(Eval("AvatarUrl"))) ? "https://images.unsplash.com/photo-1500648767791-00dcc994a43e?auto=format&fit=crop&w=600&q=80" : Eval("AvatarUrl") %>' alt='<%# Eval("DisplayName") %>' />
                                    <div class="compact-card-body">
                                        <span class="badge-inline"><%# Eval("ReputationLevel") %></span>
                                        <h3><%# Eval("DisplayName") %></h3>
                                        <p><%# Eval("FavoriteGenre") %></p>
                                        <p class="meta-copy">成为好友时间：<%# Eval("CreatedAt", "{0:yyyy-MM-dd}") %></p>
                                    </div>
                                </article>
                            </ItemTemplate>
                        </asp:Repeater>
                    </div>

                    <div class="section-heading compact">
                        <h2>我发出的申请</h2>
                        <p>这里展示还在等待处理的好友申请。</p>
                    </div>
                    <div class="reservation-list">
                        <asp:Repeater ID="rptOutgoingFriendRequests" runat="server">
                            <ItemTemplate>
                                <article class="reservation-card">
                                    <h3>发给：<%# Eval("ReceiverDisplayName") %></h3>
                                    <p>状态：<%# Eval("Status") %></p>
                                    <p><%# string.IsNullOrWhiteSpace(Convert.ToString(Eval("RequestMessage"))) ? "未填写留言" : Eval("RequestMessage") %></p>
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
