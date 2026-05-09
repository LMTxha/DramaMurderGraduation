<%@ Page Title="安全中心 | 剧本杀系统" Language="C#" MasterPageFile="~/Site.Master" AutoEventWireup="true" CodeBehind="SecurityCenter.aspx.cs" Inherits="DramaMurderGraduation.Web.SecurityCenterPage" %>
<%-- 页面用途：SecurityCenter 页面负责承载对应功能的 Web Forms 标记、服务端控件和前端布局。 --%>
<asp:Content ID="SecurityTitle" ContentPlaceHolderID="TitleContent" runat="server">
    安全中心 | 剧本杀系统
</asp:Content>
<asp:Content ID="SecurityMain" ContentPlaceHolderID="MainContent" runat="server">
    <%-- 主要内容区：承载当前页面的核心业务列表、表单或详情内容。 --%>
    <section class="section-block">
        <div class="container split-grid detail-split">
            <%-- 信息面板：承载一个独立的业务说明、列表或表单模块。 --%>
            <article class="about-panel">
                <%-- 模块标题区：说明当前业务模块的名称和处理说明。 --%>
                <div class="section-heading left">
                    <h2>账号安全</h2>
                    <p>查看最近登录痕迹、资料变更记录，并从这里进入密码找回流程。</p>
                </div>
                <%-- 统计网格：集中展示多个关键业务指标。 --%>
                <div class="wallet-summary-grid">
                    <%-- 统计卡片：展示一个后台指标或运营数据。 --%>
                    <article class="wallet-summary-card accent">
                        <span>当前角色</span>
                        <strong><asp:Literal ID="litRoleName" runat="server" /></strong>
                        <small>仅展示当前账号可见的安全记录</small>
                    </article>
                    <%-- 统计卡片：展示一个后台指标或运营数据。 --%>
                    <article class="wallet-summary-card">
                        <span>最近登录结果</span>
                        <strong><asp:Literal ID="litLatestLoginResult" runat="server" /></strong>
                        <small><asp:Literal ID="litLatestLoginTime" runat="server" /></small>
                    </article>
                </div>
                <%-- 操作按钮区：集中放置提交、重置、跳转或审核动作。 --%>
                <div class="hero-actions top-gap">
                    <a class="btn-primary" href="ForgotPassword.aspx">找回密码</a>
                    <a class="btn-secondary" href="Settings.aspx">返回设置</a>
                </div>
            </article>

            <%-- 信息面板：承载一个独立的业务说明、列表或表单模块。 --%>
            <article class="about-panel">
                <%-- 模块标题区：说明当前业务模块的名称和处理说明。 --%>
                <div class="section-heading left">
                    <h2>最近登录日志</h2>
                    <p>记录登录结果、来源 IP 和浏览器信息，方便排查账号异常。</p>
                </div>
                <%-- 列表容器：承载 Repeater 渲染出的多条业务卡片。 --%>
                <div class="reservation-list">
                    <%-- 数据列表控件 rptLoginLogs：后台绑定集合数据后，按 ItemTemplate 循环渲染每条记录。 --%>
                    <asp:Repeater ID="rptLoginLogs" runat="server">
                        <%-- 列表项模板：定义 Repeater 中每一条业务记录的 HTML 结构和绑定字段。 --%>
                        <ItemTemplate>
                            <%-- 业务卡片：展示一条预约、审核、消息或统计记录。 --%>
                            <article class="reservation-card">
                                <h3><%# Eval("ResultType") %></h3>
                                <p>IP：<%# Eval("IpAddress") %></p>
                                <p>说明：<%# Eval("Detail") %></p>
                                <small><%# Eval("CreatedAt", "{0:yyyy-MM-dd HH:mm}") %></small>
                            </article>
                        </ItemTemplate>
                    </asp:Repeater>
                </div>
            </article>
        </div>
    </section>

    <%-- 次级内容区：用于承载筛选、配置、辅助列表或补充信息。 --%>
    <section class="section-block alt">
        <div class="container">
            <%-- 模块标题区：说明当前业务模块的名称和处理说明。 --%>
            <div class="section-heading left">
                <h2>资料变更历史</h2>
                <p>保存昵称、手机号、头像和签名等资料的最近变更结果。</p>
            </div>
            <%-- 列表容器：承载 Repeater 渲染出的多条业务卡片。 --%>
            <div class="reservation-list">
                <%-- 数据列表控件 rptProfileChangeLogs：后台绑定集合数据后，按 ItemTemplate 循环渲染每条记录。 --%>
                <asp:Repeater ID="rptProfileChangeLogs" runat="server">
                    <%-- 列表项模板：定义 Repeater 中每一条业务记录的 HTML 结构和绑定字段。 --%>
                    <ItemTemplate>
                        <%-- 业务卡片：展示一条预约、审核、消息或统计记录。 --%>
                        <article class="reservation-card">
                            <h3><%# Eval("FieldName") %> · <%# Eval("ChangedAt", "{0:yyyy-MM-dd HH:mm}") %></h3>
                            <p>变更前：<%# Eval("BeforeValue") %></p>
                            <p>变更后：<%# Eval("AfterValue") %></p>
                        </article>
                    </ItemTemplate>
                </asp:Repeater>
            </div>
        </div>
    </section>
</asp:Content>
