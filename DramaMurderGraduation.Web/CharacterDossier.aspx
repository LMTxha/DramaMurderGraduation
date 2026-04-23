<%@ Page Title="角色本 | 剧本杀系统" Language="C#" MasterPageFile="~/Site.Master" AutoEventWireup="true" CodeBehind="CharacterDossier.aspx.cs" Inherits="DramaMurderGraduation.Web.CharacterDossierPage" %>
<asp:Content ID="Content1" ContentPlaceHolderID="TitleContent" runat="server">
    角色本 | 剧本杀系统
</asp:Content>
<asp:Content ID="Content2" ContentPlaceHolderID="MainContent" runat="server">
    <asp:Panel ID="pnlNotFound" runat="server" Visible="false" CssClass="section-block">
        <div class="container empty-state">
            <h1>未找到角色本</h1>
            <p>请先进入有效房间，并确认当前预约已经分配角色。</p>
            <a class="btn-primary" href="Booking.aspx">返回预约页面</a>
        </div>
    </asp:Panel>

    <asp:Panel ID="pnlDossier" runat="server" Visible="false">
        <section class="detail-hero">
            <div class="container detail-grid">
                <article class="detail-copy">
                    <p class="eyebrow">Private Dossier</p>
                    <h1>我的角色本</h1>
                    <p class="hero-subtitle">这是当前玩家的私有视角，用于查看角色设定、原始角色 PDF、已解锁线索和最近行动记录。</p>
                    <div class="detail-tags">
                        <span>剧本：<asp:Literal ID="litScriptName" runat="server" /></span>
                        <span>角色：<asp:Literal ID="litCharacterName" runat="server" /></span>
                        <span>房间：<asp:Literal ID="litRoomName" runat="server" /></span>
                    </div>
                    <div class="hero-actions">
                        <asp:HyperLink ID="lnkBackRoom" runat="server" CssClass="btn-primary">返回游戏房间</asp:HyperLink>
                        <asp:HyperLink ID="lnkResult" runat="server" CssClass="btn-secondary">查看结案归档</asp:HyperLink>
                    </div>
                </article>

                <article class="about-panel">
                    <div class="section-heading left">
                        <h2>当前阶段任务</h2>
                        <p>系统会根据房间所处阶段提示你当前更适合关注的调查方向。</p>
                    </div>
                    <div class="ending-summary dossier-guide">
                        <span class="stage-badge"><asp:Literal ID="litStageName" runat="server" /></span>
                        <h3><asp:Literal ID="litGuideTitle" runat="server" /></h3>
                        <p class="about-text"><asp:Literal ID="litGuideSummary" runat="server" /></p>
                    </div>
                </article>
            </div>
        </section>

        <section class="section-block">
            <div class="container gameplay-grid">
                <article class="about-panel gameplay-panel">
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
                                <asp:HyperLink ID="lnkRolePdf" runat="server" CssClass="btn-primary" Target="_blank">打开我的角色本</asp:HyperLink>
                            </div>
                        </asp:PlaceHolder>
                    </div>
                </article>

                <article class="about-panel gameplay-panel">
                    <div class="section-heading left">
                        <h2>已解锁线索</h2>
                        <p>这里显示当前玩家视角下可以查看的公共线索和私密线索。</p>
                    </div>
                    <div class="clue-board">
                        <asp:Repeater ID="rptClues" runat="server">
                            <ItemTemplate>
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

        <section class="section-block alt">
            <div class="container gameplay-grid">
                <article class="about-panel gameplay-panel">
                    <div class="section-heading left">
                        <h2>最近行动记录</h2>
                        <p>用于回顾当前对局中的调查动作、阶段推进和主持人发放的关键信息。</p>
                    </div>
                    <div class="chat-feed action-feed">
                        <asp:Repeater ID="rptActionLogs" runat="server">
                            <ItemTemplate>
                                <article class="chat-bubble">
                                    <strong><%# Eval("PlayerName") %> / <%# Eval("ActionTitle") %></strong>
                                    <span><%# Eval("CreatedAt", "{0:HH:mm:ss}") %> / <%# Eval("ActionType") %></span>
                                    <p><%# Eval("ActionContent") %></p>
                                </article>
                            </ItemTemplate>
                        </asp:Repeater>
                    </div>
                </article>

                <article class="about-panel gameplay-panel">
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
