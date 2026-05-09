<%@ Page Title="玩家点评 | 剧本杀系统" Language="C#" MasterPageFile="~/Site.Master" AutoEventWireup="true" CodeBehind="Reviews.aspx.cs" Inherits="DramaMurderGraduation.Web.ReviewsPage" %>
<%-- 页面用途：Reviews 页面负责承载对应功能的 Web Forms 标记、服务端控件和前端布局。 --%>
<asp:Content ID="Content1" ContentPlaceHolderID="TitleContent" runat="server">
    玩家点评 | 剧本杀系统
</asp:Content>
<asp:Content ID="Content2" ContentPlaceHolderID="MainContent" runat="server">
    <%-- 页面分区：把当前页面内容按业务模块拆分展示。 --%>
    <section class="inner-hero">
        <div class="container">
            <p class="eyebrow">Player Reviews</p>
            <h1>玩家点评中心</h1>
            <p>按剧本筛选真实玩家反馈，快速看看哪一本更适合你们今晚的口味。</p>
        </div>
    </section>

    <%-- 主要内容区：承载当前页面的核心业务列表、表单或详情内容。 --%>
    <section class="section-block">
        <div class="container">
            <div class="filter-bar compact">
                <div class="field-group">
                    <label for="<%= ddlScripts.ClientID %>">选择剧本</label>
                    <%-- 下拉控件 ddlScripts：提供状态、分类或角色等固定选项。 --%>
                    <asp:DropDownList ID="ddlScripts" runat="server" CssClass="input-control" />
                </div>
                <div class="field-group action">
                    <%-- 操作按钮 btnFilter：点击后触发后台事件处理当前业务动作。 --%>
                    <asp:Button ID="btnFilter" runat="server" Text="筛选点评" CssClass="btn-primary" OnClick="btnFilter_Click" />
                </div>
            </div>

            <%-- 面板控件 pnlReviewMessage：后台可通过 Visible/CssClass 控制整块内容是否显示以及提示样式。 --%>
            <asp:Panel ID="pnlReviewMessage" runat="server" Visible="false" CssClass="status-message">
                <asp:Literal ID="litReviewMessage" runat="server" />
            </asp:Panel>

            <%-- 面板控件 pnlSubmitReview：后台可通过 Visible/CssClass 控制整块内容是否显示以及提示样式。 --%>
            <asp:Panel ID="pnlSubmitReview" runat="server" CssClass="form-panel review-submit-panel">
                <%-- 模块标题区：说明当前业务模块的名称和处理说明。 --%>
                <div class="section-heading left compact">
                    <h2>提交消费后评价</h2>
                    <p>选择自己的预约订单提交评价，系统会自动绑定剧本、玩家和订单，避免虚假点评。</p>
                </div>
                <%-- 表单网格：按响应式布局排列输入框、下拉框和筛选条件。 --%>
                <div class="form-grid">
                    <div class="field-group full">
                        <label for="<%= ddlReviewReservation.ClientID %>">选择预约订单</label>
                        <%-- 下拉控件 ddlReviewReservation：提供状态、分类或角色等固定选项。 --%>
                        <asp:DropDownList ID="ddlReviewReservation" runat="server" CssClass="input-control" />
                    </div>
                    <div class="field-group">
                        <label for="<%= ddlReviewRating.ClientID %>">评分</label>
                        <%-- 下拉控件 ddlReviewRating：提供状态、分类或角色等固定选项。 --%>
                        <asp:DropDownList ID="ddlReviewRating" runat="server" CssClass="input-control">
                            <asp:ListItem Value="5">5 分</asp:ListItem>
                            <asp:ListItem Value="4">4 分</asp:ListItem>
                            <asp:ListItem Value="3">3 分</asp:ListItem>
                            <asp:ListItem Value="2">2 分</asp:ListItem>
                            <asp:ListItem Value="1">1 分</asp:ListItem>
                        </asp:DropDownList>
                    </div>
                    <div class="field-group">
                        <label for="<%= txtReviewTag.ClientID %>">体验标签</label>
                        <%-- 输入控件 txtReviewTag：接收用户输入或展示后台已有备注。 --%>
                        <asp:TextBox ID="txtReviewTag" runat="server" CssClass="input-control" placeholder="例如：高还原、氛围沉浸" />
                    </div>
                    <div class="field-group full">
                        <label for="<%= cblReviewTags.ClientID %>">快捷标签</label>
                        <asp:CheckBoxList ID="cblReviewTags" runat="server" CssClass="tag-checklist review-tag-checklist" RepeatDirection="Horizontal" RepeatColumns="4" />
                    </div>
                    <div class="field-group full">
                        <label for="<%= txtReviewContent.ClientID %>">评价内容</label>
                        <%-- 输入控件 txtReviewContent：接收用户输入或展示后台已有备注。 --%>
                        <asp:TextBox ID="txtReviewContent" runat="server" CssClass="input-control textarea" TextMode="MultiLine" Rows="4" placeholder="写下剧本、DM、房间氛围、服务履约等真实体验" />
                    </div>
                </div>
                <%-- 操作按钮 btnSubmitReview：点击后触发后台事件处理当前业务动作。 --%>
                <asp:Button ID="btnSubmitReview" runat="server" Text="提交评价" CssClass="btn-primary wide-button" OnClick="btnSubmitReview_Click" />
            </asp:Panel>

            <div class="stats-row">
                <div class="metric-card">
                    <p>点评总数</p>
                    <strong><asp:Literal ID="litReviewTotal" runat="server" /></strong>
                </div>
                <div class="metric-card accent">
                    <p>平均评分</p>
                    <strong><asp:Literal ID="litAverageScore" runat="server" /></strong>
                </div>
                <div class="metric-card">
                    <p>5 分好评</p>
                    <strong><asp:Literal ID="litFiveStarCount" runat="server" /></strong>
                </div>
                <div class="metric-card">
                    <p>优质率</p>
                    <strong><asp:Literal ID="litGoodRate" runat="server" /></strong>
                </div>
                <div class="metric-card">
                    <p>待关注差评</p>
                    <strong><asp:Literal ID="litLowScoreCount" runat="server" /></strong>
                </div>
                <div class="metric-card">
                    <p>热门标签</p>
                    <strong><asp:Literal ID="litTopTags" runat="server" /></strong>
                </div>
            </div>

            <div class="review-grid" id="reviews">
                <%-- 数据列表控件 rptReviews：后台绑定集合数据后，按 ItemTemplate 循环渲染每条记录。 --%>
                <asp:Repeater ID="rptReviews" runat="server">
                    <%-- 列表项模板：定义 Repeater 中每一条业务记录的 HTML 结构和绑定字段。 --%>
                    <ItemTemplate>
                        <%-- 内容卡片：用于组织当前模块中的一组相关信息。 --%>
                        <article class="review-card">
                            <span class="review-tag"><%# GetPrimaryTag(Eval("HighlightTag")) %></span>
                            <h3><%# Eval("ScriptName") %></h3>
                            <p class="review-rating"><%# Eval("ReviewerName") %> · 评分 <%# Eval("Rating") %>.0 / 5</p>
                            <p class="about-text"><%# GetReservationBindingText(Container.DataItem) %></p>
                            <p class="about-text"><%# RenderReviewTags(Eval("HighlightTag")) %></p>
                            <p><%# Eval("Content") %></p>
                            <p class="about-text"><%# string.IsNullOrWhiteSpace(Convert.ToString(Eval("AdminReply"))) ? string.Empty : "门店回复：" + Eval("AdminReply") %></p>
                            <small><%# Eval("ReviewDate", "{0:yyyy-MM-dd}") %></small>
                        </article>
                    </ItemTemplate>
                </asp:Repeater>
            </div>
        </div>
    </section>
</asp:Content>
