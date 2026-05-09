<%@ Page Title="好友主页 | 雾城剧本研究所" Language="C#" MasterPageFile="~/Site.Master" AutoEventWireup="true" CodeBehind="FriendProfile.aspx.cs" Inherits="DramaMurderGraduation.Web.FriendProfilePage" %>
<%-- 页面用途：FriendProfile 页面负责承载对应功能的 Web Forms 标记、服务端控件和前端布局。 --%>
<asp:Content ID="Content1" ContentPlaceHolderID="TitleContent" runat="server">
    好友主页 | 雾城剧本研究所
</asp:Content>
<asp:Content ID="Content2" ContentPlaceHolderID="MainContent" runat="server">
    <%-- 页面分区：把当前页面内容按业务模块拆分展示。 --%>
    <section class="hero-section">
        <div class="container detail-grid">
            <%-- 说明卡片：展示页面主标题、摘要和关键标签。 --%>
            <article class="detail-copy">
                <div class="hero-badge-row">
                    <span class="site-badge">好友主页</span>
                    <span class="site-badge soft"><asp:Literal ID="litFriendshipStatus" runat="server" /></span>
                </div>
                <p class="eyebrow">PROFILE</p>
                <h1><asp:Literal ID="litDisplayName" runat="server" /></h1>
                <p class="hero-subtitle"><asp:Literal ID="litMotto" runat="server" /></p>
                <%-- 摘要标签区：展示当前页面最重要的数量或状态提示。 --%>
                <div class="detail-tags">
                    <span>头衔 <asp:Literal ID="litTitle" runat="server" /></span>
                    <span>偏好 <asp:Literal ID="litFavoriteGenre" runat="server" /></span>
                    <span>等级 <asp:Literal ID="litReputation" runat="server" /></span>
                </div>
                <%-- 操作按钮区：集中放置提交、重置、跳转或审核动作。 --%>
                <div class="hero-actions">
                    <a class="btn-secondary" href="Friends.aspx">返回好友互动</a>
                    <a id="lnkOpenChat" runat="server" class="btn-primary" href="Friends.aspx">打开私聊</a>
                </div>
            </article>

            <%-- 内容卡片：用于组织当前模块中的一组相关信息。 --%>
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

    <%-- 主要内容区：承载当前页面的核心业务列表、表单或详情内容。 --%>
    <section class="section-block">
        <div class="container split-grid detail-split">
            <%-- 表单面板：承载筛选条件或业务提交输入项。 --%>
            <article class="form-panel">
                <%-- 模块标题区：说明当前业务模块的名称和处理说明。 --%>
                <div class="section-heading left">
                    <h2>邀请一起开本</h2>
                    <p>选一个剧本，把邀请直接发到你们的好友会话里。</p>
                </div>
                <%-- 面板控件 pnlInviteMessage：后台可通过 Visible/CssClass 控制整块内容是否显示以及提示样式。 --%>
                <asp:Panel ID="pnlInviteMessage" runat="server" Visible="false" CssClass="status-message">
                    <asp:Literal ID="litInviteMessage" runat="server" />
                </asp:Panel>
                <%-- 表单网格：按响应式布局排列输入框、下拉框和筛选条件。 --%>
                <div class="form-grid single-form">
                    <div class="field-group">
                        <label for="<%= ddlInviteScript.ClientID %>">邀请剧本</label>
                        <%-- 下拉控件 ddlInviteScript：提供状态、分类或角色等固定选项。 --%>
                        <asp:DropDownList ID="ddlInviteScript" runat="server" CssClass="input-control" />
                    </div>
                </div>
                <%-- 操作按钮 btnInviteFriend：点击后触发后台事件处理当前业务动作。 --%>
                <asp:Button ID="btnInviteFriend" runat="server" Text="发送开本邀请" CssClass="btn-primary wide-button" OnClick="btnInviteFriend_Click" />
            </article>

            <%-- 信息面板：承载一个独立的业务说明、列表或表单模块。 --%>
            <article class="about-panel">
                <%-- 模块标题区：说明当前业务模块的名称和处理说明。 --%>
                <div class="section-heading left">
                    <h2>最近动态</h2>
                    <p>这里展示这位好友最近分享的朋友圈内容。</p>
                </div>
                <div class="moment-list">
                    <%-- 数据列表控件 rptRecentMoments：后台绑定集合数据后，按 ItemTemplate 循环渲染每条记录。 --%>
                    <asp:Repeater ID="rptRecentMoments" runat="server">
                        <%-- 列表项模板：定义 Repeater 中每一条业务记录的 HTML 结构和绑定字段。 --%>
                        <ItemTemplate>
                            <%-- 内容卡片：用于组织当前模块中的一组相关信息。 --%>
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
