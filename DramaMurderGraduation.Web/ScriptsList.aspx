<%@ Page Title="剧本库 | 剧本杀系统" Language="C#" MasterPageFile="~/Site.Master" AutoEventWireup="true" CodeBehind="ScriptsList.aspx.cs" Inherits="DramaMurderGraduation.Web.ScriptsListPage" %>
<asp:Content ID="Content1" ContentPlaceHolderID="TitleContent" runat="server">
    剧本库 | 剧本杀系统
</asp:Content>
<asp:Content ID="Content2" ContentPlaceHolderID="MainContent" runat="server">
    <section class="inner-hero">
        <div class="container">
            <p class="eyebrow">Script Library</p>
            <h1>剧本库检索</h1>
            <p>按关键词和题材筛选剧本，快速找到适合你们这车人数、时长和氛围的故事。</p>
        </div>
    </section>

    <section class="section-block">
        <div class="container">
            <div class="filter-bar">
                <div class="field-group">
                    <label for="<%= txtKeyword.ClientID %>">关键词</label>
                    <asp:TextBox ID="txtKeyword" runat="server" CssClass="input-control" placeholder="输入剧本名或一句话卖点" />
                </div>
                <div class="field-group">
                    <label for="<%= ddlGenres.ClientID %>">题材分类</label>
                    <asp:DropDownList ID="ddlGenres" runat="server" CssClass="input-control" />
                </div>
                <div class="field-group action">
                    <asp:Button ID="btnSearch" runat="server" Text="查询剧本" CssClass="btn-primary" OnClick="btnSearch_Click" />
                </div>
            </div>

            <div class="section-heading left compact">
                <h2>查询结果</h2>
                <p>共找到 <asp:Literal ID="litResultCount" runat="server" /> 个剧本。</p>
            </div>

            <div class="card-grid">
                <asp:Repeater ID="rptScripts" runat="server">
                    <ItemTemplate>
                        <article class="script-card large">
                            <img src='<%# Eval("CoverImage") %>' alt='<%# Eval("Name") %>' />
                            <div class="card-body">
                                <div class="card-meta">
                                    <span><%# Eval("GenreName") %></span>
                                    <span><%# Eval("Difficulty") %></span>
                                    <span>评分 <%# Eval("AverageRating", "{0:F1}") %></span>
                                </div>
                                <h3><%# Eval("Name") %></h3>
                                <p><%# Eval("Slogan") %></p>
                                <div class="card-stats">
                                    <span><%# Eval("PlayerMin") %>-<%# Eval("PlayerMax") %> 人</span>
                                    <span><%# Eval("DurationMinutes") %> 分钟</span>
                                    <span>开放场次 <%# Eval("UpcomingSessionCount") %></span>
                                </div>
                                <div class="card-actions">
                                    <a class="btn-secondary" href='ScriptDetails.aspx?id=<%# Eval("Id") %>'>详情</a>
                                    <a class="text-link" href='Booking.aspx?scriptId=<%# Eval("Id") %>'>去预约</a>
                                </div>
                            </div>
                        </article>
                    </ItemTemplate>
                </asp:Repeater>
            </div>
        </div>
    </section>
</asp:Content>
