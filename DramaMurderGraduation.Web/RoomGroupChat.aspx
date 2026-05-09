<%@ Page Title="房间群聊 | 剧本杀系统" Language="C#" MasterPageFile="~/Site.Master" AutoEventWireup="true" CodeBehind="RoomGroupChat.aspx.cs" Inherits="DramaMurderGraduation.Web.RoomGroupChatPage" %>
<%-- 房间群聊页：同一场次玩家和主持人之间的实时沟通入口。 --%>
<asp:Content ID="Content1" ContentPlaceHolderID="TitleContent" runat="server">
    房间群聊 | 剧本杀系统
</asp:Content>
<asp:Content ID="Content2" ContentPlaceHolderID="MainContent" runat="server">
    <section class="room-group-chat-page">
        <div class="container">
            <asp:Panel ID="pnlNotFound" runat="server" Visible="false" CssClass="empty-state">
                <h1>未找到可进入的房间群聊</h1>
                <p>请从自己的预约订单或游戏房间进入群聊。</p>
                <a class="btn-primary" href="PlayerHub.aspx?tab=orders">返回我的订单</a>
            </asp:Panel>

            <asp:Panel ID="pnlChat" runat="server" Visible="false" CssClass="room-group-chat-shell">
                <div class="room-group-chat-topbar">
                    <div>
                        <p class="eyebrow">Room Chat</p>
                        <h1>房间公共群聊</h1>
                    </div>
                    <div class="room-group-chat-actions">
                        <asp:HyperLink ID="lnkBackRoom" runat="server" CssClass="btn-secondary" Text="返回游戏房间" />
                        <asp:HyperLink ID="lnkBackLobby" runat="server" CssClass="btn-secondary" Text="返回房间大厅" />
                        <button type="button" class="btn-secondary" data-room-chat-collapse>收起群聊</button>
                    </div>
                </div>

                <div class="room-group-chat-card" data-room-chat-card>
                    <aside class="room-group-chat-meta">
                        <div class="detail-tags">
                            <span>房间：<asp:Literal ID="litRoomName" runat="server" /></span>
                            <span>剧本：<asp:Literal ID="litScriptName" runat="server" /></span>
                            <span>场次：<asp:Literal ID="litSessionTime" runat="server" /></span>
                        </div>
                        <details class="room-group-participants">
                            <summary>查看同房成员</summary>
                            <div class="timeline-list compact">
                                <asp:Repeater ID="rptParticipants" runat="server">
                                    <ItemTemplate>
                                        <article class="mini-card">
                                            <strong><%# Encode(Eval("DisplayName")) %></strong>
                                            <span><%# Encode(Eval("Status")) %> / <%# Eval("PlayerCount") %> 人</span>
                                        </article>
                                    </ItemTemplate>
                                    <FooterTemplate>
                                        <asp:PlaceHolder ID="phEmptyParticipants" runat="server" Visible='<%# rptParticipants.Items.Count == 0 %>'>
                                            <p class="inline-note">暂无同房成员。</p>
                                        </asp:PlaceHolder>
                                    </FooterTemplate>
                                </asp:Repeater>
                            </div>
                        </details>
                    </aside>

                    <article class="room-group-chat-main">
                        <div class="section-heading left compact">
                            <h2>公共对话</h2>
                            <p>玩家、DM 和管理员的消息会同步到当前房间。</p>
                        </div>
                        <asp:Panel ID="pnlFeedback" runat="server" Visible="false" CssClass="form-message">
                            <asp:Literal ID="litFeedback" runat="server" />
                        </asp:Panel>
                        <div class="chat-feed room-group-chat-feed">
                            <asp:Repeater ID="rptMessages" runat="server">
                                <ItemTemplate>
                                    <article class="chat-bubble">
                                        <strong><%# Encode(Eval("SenderName")) %></strong>
                                        <span><%# FormatSentAt(Eval("SentAt")) %></span>
                                        <asp:PlaceHolder runat="server" Visible='<%# IsVoiceMessage(Eval("MessageType")) %>'>
                                            <p><%# Encode(Eval("Content")) %></p>
                                            <audio controls preload="none" src='<%# GetAudioSource(Eval("MediaData")) %>'></audio>
                                        </asp:PlaceHolder>
                                        <asp:PlaceHolder runat="server" Visible='<%# IsAssetMessage(Eval("MessageType")) %>'>
                                            <p><%# Encode(Eval("Content")) %></p>
                                            <asp:HyperLink runat="server" CssClass="btn-secondary small" Target="_blank" NavigateUrl='<%# GetMediaSource(Eval("MediaData")) %>' Visible='<%# IsPdfAsset(Eval("MediaData")) %>' Text="打开 PDF 线索" />
                                            <audio runat="server" controls preload="none" src='<%# GetMediaSource(Eval("MediaData")) %>' visible='<%# IsAudioAsset(Eval("MediaData")) %>'></audio>
                                            <video runat="server" class="asset-clue-video" controls preload="metadata" src='<%# GetMediaSource(Eval("MediaData")) %>' visible='<%# IsVideoAsset(Eval("MediaData")) %>'></video>
                                        </asp:PlaceHolder>
                                        <asp:PlaceHolder runat="server" Visible='<%# !IsVoiceMessage(Eval("MessageType")) && !IsAssetMessage(Eval("MessageType")) %>'>
                                            <p><%# Encode(Eval("Content")) %></p>
                                        </asp:PlaceHolder>
                                    </article>
                                </ItemTemplate>
                                <FooterTemplate>
                                    <asp:PlaceHolder ID="phEmptyMessages" runat="server" Visible='<%# rptMessages.Items.Count == 0 %>'>
                                        <p class="inline-note">暂无房间消息。</p>
                                    </asp:PlaceHolder>
                                </FooterTemplate>
                            </asp:Repeater>
                        </div>
                        <div class="room-group-composer">
                            <label for="<%= txtMessage.ClientID %>">发送文字消息</label>
                            <asp:TextBox ID="txtMessage" runat="server" CssClass="input-control textarea" TextMode="MultiLine" Rows="3" MaxLength="300" placeholder="写下你要发给同房玩家、DM 或管理员的信息。" />
                            <div class="hero-actions">
                                <asp:Button ID="btnSend" runat="server" CssClass="btn-primary" Text="发送消息" OnClick="btnSend_Click" />
                                <asp:Button ID="btnRefresh" runat="server" CssClass="btn-secondary" Text="刷新群聊" CausesValidation="false" OnClick="btnRefresh_Click" />
                            </div>
                        </div>
                    </article>
                </div>

                <button type="button" class="room-group-chat-restore" data-room-chat-restore hidden>展开房间群聊</button>
            </asp:Panel>
        </div>
    </section>
    <script>
        (function () {
            var shell = document.querySelector(".room-group-chat-shell");
            if (!shell) {
                return;
            }

            var collapse = shell.querySelector("[data-room-chat-collapse]");
            var restore = shell.querySelector("[data-room-chat-restore]");

            if (collapse) {
                collapse.addEventListener("click", function () {
                    shell.classList.add("is-collapsed");
                    if (restore) {
                        restore.hidden = false;
                    }
                });
            }

            if (restore) {
                restore.addEventListener("click", function () {
                    shell.classList.remove("is-collapsed");
                    restore.hidden = true;
                });
            }
        }());
    </script>
</asp:Content>
