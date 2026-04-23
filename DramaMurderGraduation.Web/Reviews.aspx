<%@ Page Title="玩家点评 | 剧本杀系统" Language="C#" MasterPageFile="~/Site.Master" AutoEventWireup="true" CodeBehind="Reviews.aspx.cs" Inherits="DramaMurderGraduation.Web.ReviewsPage" %>
<asp:Content ID="Content1" ContentPlaceHolderID="TitleContent" runat="server">
    玩家点评 | 剧本杀系统
</asp:Content>
<asp:Content ID="Content2" ContentPlaceHolderID="MainContent" runat="server">
    <section class="inner-hero">
        <div class="container">
            <p class="eyebrow">Player Reviews</p>
            <h1>玩家点评中心</h1>
            <p>按剧本筛选真实玩家反馈，快速看看哪一本更适合你们今晚的口味。</p>
        </div>
    </section>

    <section class="section-block">
        <div class="container">
            <div class="filter-bar compact">
                <div class="field-group">
                    <label for="<%= ddlScripts.ClientID %>">选择剧本</label>
                    <asp:DropDownList ID="ddlScripts" runat="server" CssClass="input-control" />
                </div>
                <div class="field-group action">
                    <asp:Button ID="btnFilter" runat="server" Text="筛选点评" CssClass="btn-primary" OnClick="btnFilter_Click" />
                </div>
            </div>

            <div class="stats-row">
                <div class="metric-card">
                    <p>点评总数</p>
                    <strong><asp:Literal ID="litReviewTotal" runat="server" /></strong>
                </div>
                <div class="metric-card accent">
                    <p>平均评分</p>
                    <strong><asp:Literal ID="litAverageScore" runat="server" /></strong>
                </div>
            </div>

            <div class="review-grid">
                <asp:Repeater ID="rptReviews" runat="server">
                    <ItemTemplate>
                        <article class="review-card">
                            <span class="review-tag"><%# Eval("HighlightTag") %></span>
                            <h3><%# Eval("ScriptName") %></h3>
                            <p class="review-rating"><%# Eval("ReviewerName") %> · 评分 <%# Eval("Rating") %>.0 / 5</p>
                            <p><%# Eval("Content") %></p>
                            <small><%# Eval("ReviewDate", "{0:yyyy-MM-dd}") %></small>
                        </article>
                    </ItemTemplate>
                </asp:Repeater>
            </div>
        </div>
    </section>
</asp:Content>
