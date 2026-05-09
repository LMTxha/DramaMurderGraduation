<%@ Page Title="剧本库 | 剧本杀系统" Language="C#" MasterPageFile="~/Site.Master" AutoEventWireup="true" CodeBehind="ScriptsList.aspx.cs" Inherits="DramaMurderGraduation.Web.ScriptsListPage" %>
<%-- 页面用途：ScriptsList 页面负责承载对应功能的 Web Forms 标记、服务端控件和前端布局。 --%>
<asp:Content ID="Content1" ContentPlaceHolderID="TitleContent" runat="server">
    剧本库 | 剧本杀系统
</asp:Content>
<asp:Content ID="Content2" ContentPlaceHolderID="MainContent" runat="server">
    <%-- 页面分区：把当前页面内容按业务模块拆分展示。 --%>
    <section class="inner-hero">
        <div class="container">
            <p class="eyebrow">Script Library</p>
            <h1>剧本库检索</h1>
            <p>按关键词和题材筛选剧本，快速找到适合你们这车人数、时长和氛围的故事。</p>
        </div>
    </section>

    <%-- 主要内容区：承载当前页面的核心业务列表、表单或详情内容。 --%>
    <section class="section-block">
        <div class="container">
            <div class="filter-bar">
                <div class="field-group">
                    <label for="<%= txtKeyword.ClientID %>">关键词</label>
                    <%-- 输入控件 txtKeyword：接收用户输入或展示后台已有备注。 --%>
                    <asp:TextBox ID="txtKeyword" runat="server" CssClass="input-control" placeholder="输入剧本名或一句话卖点" />
                </div>
                <div class="field-group">
                    <label for="<%= ddlGenres.ClientID %>">题材分类</label>
                    <%-- 下拉控件 ddlGenres：提供状态、分类或角色等固定选项。 --%>
                    <asp:DropDownList ID="ddlGenres" runat="server" CssClass="input-control" />
                </div>
                <div class="field-group action">
                    <%-- 操作按钮 btnSearch：点击后触发后台事件处理当前业务动作。 --%>
                    <asp:Button ID="btnSearch" runat="server" Text="查询剧本" CssClass="btn-primary" OnClick="btnSearch_Click" />
                </div>
            </div>

            <%-- 模块标题区：说明当前业务模块的名称和处理说明。 --%>
            <div class="section-heading left compact">
                <h2>查询结果</h2>
                <p>共找到 <asp:Literal ID="litResultCount" runat="server" /> 个剧本。</p>
            </div>

            <div class="card-grid">
                <%-- 数据列表控件 rptScripts：后台绑定集合数据后，按 ItemTemplate 循环渲染每条记录。 --%>
                <asp:Repeater ID="rptScripts" runat="server">
                    <%-- 列表项模板：定义 Repeater 中每一条业务记录的 HTML 结构和绑定字段。 --%>
                    <ItemTemplate>
                        <%-- 内容卡片：用于组织当前模块中的一组相关信息。 --%>
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
