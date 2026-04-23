<%@ Page Title="剧本详情 | 剧本杀系统" Language="C#" MasterPageFile="~/Site.Master" AutoEventWireup="true" CodeBehind="ScriptDetails.aspx.cs" Inherits="DramaMurderGraduation.Web.ScriptDetailsPage" %>
<asp:Content ID="Content1" ContentPlaceHolderID="TitleContent" runat="server">
    剧本详情 | 剧本杀系统
</asp:Content>
<asp:Content ID="Content2" ContentPlaceHolderID="MainContent" runat="server">
    <asp:Panel ID="pnlNotFound" runat="server" Visible="false" CssClass="section-block">
        <div class="container empty-state">
            <h1>未找到对应剧本</h1>
            <p>请从剧本库重新选择一个有效的剧本条目。</p>
            <a class="btn-primary" href="ScriptsList.aspx">返回剧本库</a>
        </div>
    </asp:Panel>

    <asp:Panel ID="pnlContent" runat="server">
        <section class="detail-hero">
            <div class="container detail-grid">
                <asp:Image ID="imgCover" runat="server" CssClass="detail-cover" />
                <div class="detail-copy">
                    <p class="eyebrow"><asp:Literal ID="litGenre" runat="server" /></p>
                    <h1><asp:Literal ID="litName" runat="server" /></h1>
                    <p class="hero-subtitle"><asp:Literal ID="litSlogan" runat="server" /></p>
                    <div class="detail-tags">
                        <span><asp:Literal ID="litDuration" runat="server" /></span>
                        <span><asp:Literal ID="litPlayers" runat="server" /></span>
                        <span><asp:Literal ID="litDifficulty" runat="server" /></span>
                        <span>作者：<asp:Literal ID="litAuthor" runat="server" /></span>
                    </div>
                    <div class="detail-prices">
                        <strong>￥<asp:Literal ID="litPrice" runat="server" /></strong>
                        <span>评分 <asp:Literal ID="litAverageRating" runat="server" /> / 5</span>
                        <span><asp:Literal ID="litReviewCount" runat="server" /> 条点评</span>
                    </div>
                    <div class="hero-actions">
                        <a class="btn-primary" href='Booking.aspx?scriptId=<%= Request.QueryString["id"] %>'>预约这个剧本</a>
                        <a class="btn-secondary" href="ScriptsList.aspx">返回剧本库</a>
                    </div>
                </div>
            </div>
        </section>

        <section class="section-block">
            <div class="container split-grid detail-split">
                <article class="about-panel">
                    <div class="section-heading left">
                        <h2>故事背景</h2>
                        <p>这里会先带你了解故事底色、开场气氛和这个本最抓人的那一层情绪。</p>
                    </div>
                    <p class="about-text"><asp:Literal ID="litStoryBackground" runat="server" /></p>
                </article>
                <article>
                    <div class="section-heading left">
                        <h2>角色阵容</h2>
                        <p>角色信息来自 `ScriptCharacters` 表。</p>
                    </div>
                    <div class="character-list">
                        <asp:Repeater ID="rptCharacters" runat="server">
                            <ItemTemplate>
                                <article class="character-card">
                                    <h3><%# Eval("Name") %></h3>
                                    <p class="character-meta"><%# Eval("Gender") %> · <%# Eval("AgeRange") %> 岁 · <%# Eval("Profession") %></p>
                                    <p><%# Eval("Description") %></p>
                                    <small>性格：<%# Eval("Personality") %> · 暗线：<%# Eval("SecretLine") %></small>
                                </article>
                            </ItemTemplate>
                        </asp:Repeater>
                    </div>
                </article>
            </div>
        </section>

        <asp:PlaceHolder ID="phFullScriptContent" runat="server" Visible="false">
            <section class="section-block">
                <div class="container">
                    <article class="about-panel">
                        <div class="section-heading left">
                            <h2>完整剧本内容</h2>
                            <p>如果作者已经开放完整内容，你可以在这里直接查看主持流程、线索节奏和完整文本。</p>
                        </div>
                        <div class="script-manuscript">
                            <asp:Literal ID="litFullScriptContent" runat="server" />
                        </div>
                    </article>
                </div>
            </section>
        </asp:PlaceHolder>

        <asp:PlaceHolder ID="phScriptAssets" runat="server" Visible="false">
            <section class="section-block">
                <div class="container">
                    <article class="about-panel">
                        <div class="section-heading left">
                            <h2>原始剧本资料包</h2>
                            <p>这里展示从现实剧本资料包原封不动导入的文件索引，PDF、图片、音频和视频都保留原文件。</p>
                        </div>
                        <div class="script-asset-list">
                            <asp:Repeater ID="rptScriptAssets" runat="server">
                                <ItemTemplate>
                                    <a class="script-asset-card" href='<%# Eval("PublicUrl") %>' target="_blank" rel="noopener">
                                        <div class="script-asset-main">
                                            <strong><%# Eval("Title") %></strong>
                                            <p><%# TranslateAssetType(Eval("AssetType")) %> / <%# Eval("FileExtension") %> / <%# Eval("RelativePath") %></p>
                                        </div>
                                        <div class="script-asset-side">
                                            <span><%# Eval("FileName") %></span>
                                        </div>
                                    </a>
                                </ItemTemplate>
                            </asp:Repeater>
                        </div>
                    </article>
                </div>
            </section>
        </asp:PlaceHolder>

        <section class="section-block alt">
            <div class="container split-grid detail-split">
                <article>
                    <div class="section-heading left">
                        <h2>可预约场次</h2>
                        <p>场次动态统计剩余人数，点击后可直接跳转到预约页。</p>
                    </div>
                    <asp:Repeater ID="rptSessions" runat="server">
                        <ItemTemplate>
                            <article class="session-card">
                                <div>
                                    <h3><%# Eval("RoomName") %></h3>
                                    <p><%# Eval("HostName") %> · ￥<%# Eval("BasePrice", "{0:F0}") %> / 人</p>
                                    <small><%# Eval("SessionDateTime", "{0:yyyy-MM-dd HH:mm}") %></small>
                                </div>
                                <div class="session-side">
                                    <strong>剩余 <%# Eval("RemainingSeats") %> 位</strong>
                                    <a class="text-link" href='Booking.aspx?scriptId=<%# Eval("ScriptId") %>&sessionId=<%# Eval("Id") %>'>立即预约</a>
                                </div>
                            </article>
                        </ItemTemplate>
                    </asp:Repeater>
                </article>
                <article>
                    <div class="section-heading left">
                        <h2>真实点评</h2>
                        <p>点评信息来自 `Reviews` 表。</p>
                    </div>
                    <div class="review-grid single-column">
                        <asp:Repeater ID="rptReviews" runat="server">
                            <ItemTemplate>
                                <article class="review-card">
                                    <span class="review-tag"><%# Eval("HighlightTag") %></span>
                                    <h3><%# Eval("ReviewerName") %></h3>
                                    <p class="review-rating">评分 <%# Eval("Rating") %>.0 / 5</p>
                                    <p><%# Eval("Content") %></p>
                                    <small><%# Eval("ReviewDate", "{0:yyyy-MM-dd}") %></small>
                                </article>
                            </ItemTemplate>
                        </asp:Repeater>
                    </div>
                </article>
            </div>
        </section>
    </asp:Panel>
</asp:Content>
