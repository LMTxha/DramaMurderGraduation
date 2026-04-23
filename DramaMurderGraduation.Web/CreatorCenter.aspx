<%@ Page Title="剧本创作 | 剧本杀系统" Language="C#" MasterPageFile="~/Site.Master" AutoEventWireup="true" CodeBehind="CreatorCenter.aspx.cs" Inherits="DramaMurderGraduation.Web.CreatorCenterPage" %>
<asp:Content ID="Content1" ContentPlaceHolderID="TitleContent" runat="server">
    剧本创作 | 剧本杀系统
</asp:Content>
<asp:Content ID="Content2" ContentPlaceHolderID="MainContent" runat="server">
    <section class="inner-hero creator-hero">
        <div class="container creator-hero-grid">
            <article class="hero-copy creator-hero-copy">
                <p class="eyebrow">Creator Workspace</p>
                <h1>剧本创作中心</h1>
                <p>这里是创作者的专属工作台。你可以整理剧本基础信息、补充故事背景、提交审核，并在右侧随时查看投稿状态。</p>
                <div class="detail-tags creator-meta-row">
                    <span>在线投稿</span>
                    <span>审核入库</span>
                    <span>动态展示</span>
                </div>
            </article>

            <aside class="hero-panel creator-focus-panel">
                <a class="metric-card accent click-card interactive-card" href="#creator-form">
                    <p>创作建议</p>
                    <strong>先写卖点</strong>
                    <small>一句话卖点会直接影响剧本详情页转化</small>
                </a>
                <a class="metric-card click-card interactive-card" href="#creator-form">
                    <p>审核流程</p>
                    <strong>提交后入库</strong>
                    <small>管理员审核通过后自动公开展示</small>
                </a>
                <a class="metric-card click-card interactive-card" href="#creator-form">
                    <p>字段重点</p>
                    <strong>人数与时长</strong>
                    <small>这是玩家筛选剧本时最常用的信息</small>
                </a>
                <a class="metric-card click-card interactive-card" href="#creator-submissions">
                    <p>答辩展示</p>
                    <strong>动态投稿页</strong>
                    <small>能明显体现系统不是静态网页</small>
                </a>
            </aside>
        </div>
    </section>

    <section class="section-block">
        <div class="container creator-layout">
            <article class="form-panel creator-form-panel" id="creator-form">
                <div class="section-heading left">
                    <h2>提交新剧本</h2>
                    <p>投稿数据会写入 <code>Scripts</code> 表，初始状态为待审核。建议先填写标题、卖点和人数配置，再补故事背景。</p>
                </div>

                <asp:Panel ID="pnlMessage" runat="server" Visible="false" CssClass="status-message">
                    <asp:Literal ID="litMessage" runat="server" />
                </asp:Panel>

                <div class="form-grid creator-form-grid">
                    <div class="field-group">
                        <label for="<%= ddlGenres.ClientID %>">题材分类</label>
                        <asp:DropDownList ID="ddlGenres" runat="server" CssClass="input-control" />
                    </div>

                    <div class="field-group">
                        <label for="<%= txtAuthorName.ClientID %>">署名作者</label>
                        <asp:TextBox ID="txtAuthorName" runat="server" CssClass="input-control" />
                    </div>

                    <div class="field-group full">
                        <label for="<%= txtScriptName.ClientID %>">剧本名称</label>
                        <asp:TextBox ID="txtScriptName" runat="server" CssClass="input-control" />
                    </div>

                    <div class="field-group full">
                        <label for="<%= txtSlogan.ClientID %>">一句话卖点</label>
                        <asp:TextBox ID="txtSlogan" runat="server" CssClass="input-control" />
                    </div>

                    <div class="field-group wide">
                        <label for="<%= txtCoverImage.ClientID %>">封面图片 URL</label>
                        <asp:TextBox ID="txtCoverImage" runat="server" CssClass="input-control" />
                    </div>

                    <div class="field-group">
                        <label for="<%= ddlDifficulty.ClientID %>">难度</label>
                        <asp:DropDownList ID="ddlDifficulty" runat="server" CssClass="input-control">
                            <asp:ListItem Text="入门" Value="入门" />
                            <asp:ListItem Text="进阶" Value="进阶" />
                            <asp:ListItem Text="沉浸" Value="沉浸" />
                            <asp:ListItem Text="硬核" Value="硬核" />
                            <asp:ListItem Text="高压" Value="高压" />
                            <asp:ListItem Text="机制" Value="机制" />
                        </asp:DropDownList>
                    </div>

                    <div class="field-group">
                        <label for="<%= txtDuration.ClientID %>">时长（分钟）</label>
                        <asp:TextBox ID="txtDuration" runat="server" CssClass="input-control" Text="240" />
                    </div>

                    <div class="field-group">
                        <label for="<%= txtPrice.ClientID %>">建议价格</label>
                        <asp:TextBox ID="txtPrice" runat="server" CssClass="input-control" Text="198" />
                    </div>

                    <div class="field-group">
                        <label for="<%= txtPlayerMin.ClientID %>">最少人数</label>
                        <asp:TextBox ID="txtPlayerMin" runat="server" CssClass="input-control" Text="6" />
                    </div>

                    <div class="field-group">
                        <label for="<%= txtPlayerMax.ClientID %>">最多人数</label>
                        <asp:TextBox ID="txtPlayerMax" runat="server" CssClass="input-control" Text="7" />
                    </div>

                    <div class="field-group full">
                        <label for="<%= txtStoryBackground.ClientID %>">故事背景</label>
                        <asp:TextBox ID="txtStoryBackground" runat="server" CssClass="input-control textarea creator-story-input" TextMode="MultiLine" Rows="10" />
                    </div>
                </div>

                <asp:Button ID="btnSubmitScript" runat="server" Text="提交剧本审核" CssClass="btn-primary wide-button" OnClick="btnSubmitScript_Click" />
            </article>

            <aside class="creator-sidebar">
                <article class="about-panel creator-note-panel">
                    <div class="section-heading left">
                        <h2>投稿提示</h2>
                        <p>把创作规范放在右侧，页面会更像真实后台工作台，而不是只有一个表单。</p>
                    </div>
                    <div class="creator-checklist">
                        <div class="creator-check-item">
                            <strong>先让标题抓人</strong>
                            <p>剧本名和一句话卖点会直接影响剧本库点击率。</p>
                        </div>
                        <div class="creator-check-item">
                            <strong>配置必须完整</strong>
                            <p>人数、时长、价格和难度需要互相匹配，便于前台筛选。</p>
                        </div>
                        <div class="creator-check-item">
                            <strong>背景分段更清晰</strong>
                            <p>建议按设定、冲突、悬念三段来写，后续也便于扩展完整剧本。</p>
                        </div>
                    </div>
                </article>

                <article class="about-panel creator-submissions-panel" id="creator-submissions">
                    <div class="section-heading left">
                        <h2>我的投稿</h2>
                        <p>可以查看自己的投稿审核状态与管理员意见。</p>
                    </div>

                    <div class="creator-list creator-submission-list">
                        <asp:Repeater ID="rptMyScripts" runat="server">
                            <ItemTemplate>
                                <article class="reservation-card creator-submission-card">
                                    <div class="creator-submission-head">
                                        <h3><%# Eval("Name") %></h3>
                                        <span class="badge-inline"><%# TranslateAuditStatus(Eval("AuditStatus")) %></span>
                                    </div>
                                    <p><%# Eval("GenreName") %> · <%# Eval("Difficulty") %> · <%# Eval("PlayerMin") %>-<%# Eval("PlayerMax") %> 人</p>
                                    <p>审核意见：<%# string.IsNullOrWhiteSpace(Convert.ToString(Eval("AuditComment"))) ? "暂无" : Eval("AuditComment") %></p>
                                    <small>提交时间：<%# Eval("SubmittedAt", "{0:yyyy-MM-dd HH:mm}") %></small>
                                </article>
                            </ItemTemplate>
                        </asp:Repeater>
                    </div>
                </article>
            </aside>
        </div>
    </section>
</asp:Content>
