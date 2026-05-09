<%@ Page Title="用户登录 | 剧本杀系统" Language="C#" MasterPageFile="~/Site.Master" AutoEventWireup="true" CodeBehind="Login.aspx.cs" Inherits="DramaMurderGraduation.Web.LoginPage" %>
<%-- 页面用途：Login 页面负责承载对应功能的 Web Forms 标记、服务端控件和前端布局。 --%>
<asp:Content ID="LoginTitle" ContentPlaceHolderID="TitleContent" runat="server">
    用户登录 | 剧本杀系统
</asp:Content>
<asp:Content ID="LoginMain" ContentPlaceHolderID="MainContent" runat="server">
    <%-- 主要内容区：承载当前页面的核心业务列表、表单或详情内容。 --%>
    <section class="section-block auth-login-section">
        <div class="container narrow-shell">
            <%-- 表单面板：承载筛选条件或业务提交输入项。 --%>
            <article class="form-panel login-panel">
                <%-- 模块标题区：说明当前业务模块的名称和处理说明。 --%>
                <div class="section-heading left">
                    <p class="eyebrow">Account Sign In</p>
                    <h2>登录系统</h2>
                    <p>输入账号密码进入系统。管理员演示账号为 <code>admin / admin123456</code>，主持演示账号可使用已分配的 DM 账号。</p>
                </div>
                <%-- 面板控件 pnlMessage：后台可通过 Visible/CssClass 控制整块内容是否显示以及提示样式。 --%>
                <asp:Panel ID="pnlMessage" runat="server" Visible="false" CssClass="status-message">
                    <asp:Literal ID="litMessage" runat="server" />
                </asp:Panel>
                <%-- 表单网格：按响应式布局排列输入框、下拉框和筛选条件。 --%>
                <div class="form-grid single-form">
                    <div class="field-group">
                        <label for="<%= txtUsername.ClientID %>">用户名</label>
                        <%-- 输入控件 txtUsername：接收用户输入或展示后台已有备注。 --%>
                        <asp:TextBox ID="txtUsername" runat="server" CssClass="input-control" />
                    </div>
                    <div class="field-group">
                        <label for="<%= txtPassword.ClientID %>">密码</label>
                        <%-- 输入控件 txtPassword：接收用户输入或展示后台已有备注。 --%>
                        <asp:TextBox ID="txtPassword" runat="server" CssClass="input-control" TextMode="Password" />
                    </div>
                </div>
                <%-- 操作按钮区：集中放置提交、重置、跳转或审核动作。 --%>
                <div class="hero-actions">
                    <%-- 操作按钮 btnLogin：点击后触发后台事件处理当前业务动作。 --%>
                    <asp:Button ID="btnLogin" runat="server" Text="立即登录" CssClass="btn-primary wide-button" OnClick="btnLogin_Click" CausesValidation="false" UseSubmitBehavior="true" />
                    <a class="btn-secondary" href="ForgotPassword.aspx">找回密码</a>
                    <a class="btn-secondary" href="Register.aspx">注册新账号</a>
                </div>
            </article>
        </div>
    </section>
</asp:Content>
