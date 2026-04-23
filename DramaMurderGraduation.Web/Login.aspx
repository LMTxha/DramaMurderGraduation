<%@ Page Title="用户登录 | 剧本杀系统" Language="C#" MasterPageFile="~/Site.Master" AutoEventWireup="true" CodeBehind="Login.aspx.cs" Inherits="DramaMurderGraduation.Web.LoginPage" %>
<asp:Content ID="Content1" ContentPlaceHolderID="TitleContent" runat="server">
    用户登录 | 剧本杀系统
</asp:Content>
<asp:Content ID="Content2" ContentPlaceHolderID="MainContent" runat="server">
    <section class="section-block auth-login-section">
        <div class="container narrow-shell">
            <article class="form-panel login-panel">
                <div class="section-heading left">
                    <p class="eyebrow">Account Sign In</p>
                    <h2>登录系统</h2>
                    <p>请输入账号密码进入系统。默认管理员账号：<code>admin</code>，密码：<code>admin123456</code>。</p>
                </div>
                <asp:Panel ID="pnlMessage" runat="server" Visible="false" CssClass="status-message">
                    <asp:Literal ID="litMessage" runat="server" />
                </asp:Panel>
                <div class="form-grid single-form">
                    <div class="field-group">
                        <label for="<%= txtUsername.ClientID %>">用户名</label>
                        <asp:TextBox ID="txtUsername" runat="server" CssClass="input-control" />
                    </div>
                    <div class="field-group">
                        <label for="<%= txtPassword.ClientID %>">密码</label>
                        <asp:TextBox ID="txtPassword" runat="server" CssClass="input-control" TextMode="Password" />
                    </div>
                </div>
                <asp:Button ID="btnLogin" runat="server" Text="立即登录" CssClass="btn-primary wide-button" OnClick="btnLogin_Click" CausesValidation="false" UseSubmitBehavior="true" />
            </article>
        </div>
    </section>
</asp:Content>
