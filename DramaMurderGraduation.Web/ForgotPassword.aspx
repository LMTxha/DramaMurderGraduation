<%@ Page Title="找回密码 | 剧本杀系统" Language="C#" MasterPageFile="~/Site.Master" AutoEventWireup="true" CodeBehind="ForgotPassword.aspx.cs" Inherits="DramaMurderGraduation.Web.ForgotPasswordPage" %>
<asp:Content ID="ForgotPasswordTitle" ContentPlaceHolderID="TitleContent" runat="server">
    找回密码 | 剧本杀系统
</asp:Content>
<asp:Content ID="ForgotPasswordMain" ContentPlaceHolderID="MainContent" runat="server">
    <section class="section-block auth-login-section">
        <div class="container narrow-shell">
            <article class="form-panel login-panel">
                <div class="section-heading left">
                    <p class="eyebrow">Password Reset</p>
                    <h2>找回密码</h2>
                    <p>通过用户名和已绑定手机号生成一次性校验码，再用校验码重置登录密码。</p>
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
                        <label for="<%= txtPhone.ClientID %>">绑定手机号</label>
                        <asp:TextBox ID="txtPhone" runat="server" CssClass="input-control" />
                    </div>
                    <div class="field-group">
                        <label for="<%= txtTicketCode.ClientID %>">校验码</label>
                        <asp:TextBox ID="txtTicketCode" runat="server" CssClass="input-control" />
                    </div>
                    <div class="field-group">
                        <label for="<%= txtNewPassword.ClientID %>">新密码</label>
                        <asp:TextBox ID="txtNewPassword" runat="server" CssClass="input-control" TextMode="Password" />
                    </div>
                    <div class="field-group">
                        <label for="<%= txtConfirmPassword.ClientID %>">确认新密码</label>
                        <asp:TextBox ID="txtConfirmPassword" runat="server" CssClass="input-control" TextMode="Password" />
                    </div>
                    <div class="field-group full">
                        <label>演示说明</label>
                        <p class="inline-note">当前版本没有接入短信服务，系统会直接显示本次生成的校验码，便于本地演示找回密码流程。</p>
                    </div>
                </div>

                <div class="hero-actions">
                    <asp:Button ID="btnRequestTicket" runat="server" Text="生成校验码" CssClass="btn-secondary" OnClick="btnRequestTicket_Click" />
                    <asp:Button ID="btnResetPassword" runat="server" Text="重置密码" CssClass="btn-primary" OnClick="btnResetPassword_Click" />
                    <a class="btn-secondary" href="Login.aspx">返回登录</a>
                </div>
            </article>
        </div>
    </section>
</asp:Content>
