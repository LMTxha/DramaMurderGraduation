<%@ Page Title="好友主页 | 雾城剧本研究所" Language="C#" MasterPageFile="~/Site.Master" AutoEventWireup="true" CodeBehind="FriendProfile.aspx.cs" Inherits="DramaMurderGraduation.Web.FriendProfilePage" %>
<asp:Content ID="Content1" ContentPlaceHolderID="TitleContent" runat="server">
    好友主页 | 雾城剧本研究所
</asp:Content>
<asp:Content ID="Content2" ContentPlaceHolderID="MainContent" runat="server">
    <section class="hero-section">
        <div class="container detail-grid">
            <article class="detail-copy">
                <div class="hero-badge-row">
                    <span class="site-badge">好友主页</span>
                    <span class="site-badge soft"><asp:Literal ID="litFriendshipStatus" runat="server" /></span>
                </div>
                <p class="eyebrow">PROFILE</p>
                <h1><asp:Literal ID="litDisplayName" runat="server" /></h1>
                <p class="hero-subtitle"><asp:Literal ID="litMotto" runat="server" /></p>
                <div class="detail-tags">
                    <span>头衔 <asp:Literal ID="litTitle" runat="server" /></span>
                    <span>偏好 <asp:Literal ID="litFavoriteGenre" runat="server" /></span>
                    <span>等级 <asp:Literal ID="litReputation" runat="server" /></span>
                </div>
                <div class="hero-actions">
                    <a class="btn-secondary" href="Friends.aspx">返回好友互动</a>
                    <a id="lnkOpenChat" runat="server" class="btn-primary" href="Friends.aspx">打开私聊</a>
                </div>
            </article>

            <article class="hero-panel metric-grid-four">
                <div class="metric-card accent">
                    <p>完成剧本</p>
                    <strong><asp:Literal ID="litCompletedScripts" runat="server" /></strong>
                </div>
                <div class="metric-card">
                    <p>胜率</p>
                    <strong><asp:Literal ID="litWinRate" runat="server" /></strong>
                </div>
                <div class="metric-card">
                    <p>加入天数</p>
                    <strong><asp:Literal ID="litJoinDays" runat="server" /></strong>
                </div>
                <div class="metric-card">
                    <img id="imgAvatar" runat="server" class="profile-avatar-inline" alt="好友头像" />
                </div>
            </article>
        </div>
    </section>

    <section class="section-block">
        <div class="container split-grid detail-split">
            <article class="form-panel">
                <div class="section-heading left">
                    <h2>邀请一起开本</h2>
                    <p>选一个剧本，把邀请直接发到你们的好友会话里。</p>
                </div>
                <asp:Panel ID="pnlInviteMessage" runat="server" Visible="false" CssClass="status-message">
                    <asp:Literal ID="litInviteMessage" runat="server" />
                </asp:Panel>
                <div class="form-grid single-form">
                    <div class="field-group">
                        <label for="<%= ddlInviteScript.ClientID %>">邀请剧本</label>
                        <asp:DropDownList ID="ddlInviteScript" runat="server" CssClass="input-control" />
                    </div>
                </div>
                <asp:Button ID="btnInviteFriend" runat="server" Text="发送开本邀请" CssClass="btn-primary wide-button" OnClick="btnInviteFriend_Click" />
            </article>

            <article class="about-panel">
                <div class="section-heading left">
                    <h2>最近动态</h2>
                    <p>这里展示这位好友最近分享的朋友圈内容。</p>
                </div>
                <div class="moment-list">
                    <asp:Repeater ID="rptRecentMoments" runat="server">
                        <ItemTemplate>
                            <article class="moment-card">
                                <div class="moment-head">
                                    <img src='<%# GetAvatarUrl(Eval("AvatarUrl")) %>' alt='<%# Eval("DisplayName") %>' />
                                    <div>
                                        <strong><%# Eval("DisplayName") %></strong>
                                        <small><%# Eval("CreatedAt", "{0:yyyy-MM-dd HH:mm}") %></small>
                                    </div>
                                </div>
                                <p><%# Eval("Content") %></p>
                                <%# RenderMomentImage(Eval("ImageUrl")) %>
                                <%# RenderMomentLocation(Eval("LocationText")) %>
                            </article>
                        </ItemTemplate>
                    </asp:Repeater>
                </div>
            </article>
        </div>
    </section>
</asp:Content>
