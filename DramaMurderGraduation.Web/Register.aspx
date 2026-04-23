<%@ Page Title="用户注册 | 剧本杀系统" Language="C#" MasterPageFile="~/Site.Master" AutoEventWireup="true" CodeBehind="Register.aspx.cs" Inherits="DramaMurderGraduation.Web.RegisterPage" %>
<asp:Content ID="Content1" ContentPlaceHolderID="TitleContent" runat="server">
    用户注册 | 剧本杀系统
</asp:Content>
<asp:Content ID="Content2" ContentPlaceHolderID="MainContent" runat="server">
    <section class="inner-hero">
        <div class="container">
            <p class="eyebrow">Register Account</p>
            <h1>用户注册</h1>
            <p>新用户注册后需要管理员审核，通过后才能登录并进行剧本投稿。</p>
        </div>
    </section>

    <section class="section-block">
        <div class="container narrow-shell">
            <article class="form-panel">
                <div class="section-heading left">
                    <h2>填写注册信息</h2>
            <p>注册后就能预约场次、进入房间互动，也能在玩家中心维护自己的资料。</p>
                </div>
                <asp:Panel ID="pnlMessage" runat="server" Visible="false" CssClass="status-message">
                    <asp:Literal ID="litMessage" runat="server" />
                </asp:Panel>
                <div class="form-grid">
                    <div class="field-group">
                        <label for="<%= txtUsername.ClientID %>">用户名</label>
                        <asp:TextBox ID="txtUsername" runat="server" CssClass="input-control" />
                    </div>
                    <div class="field-group">
                        <label for="<%= txtDisplayName.ClientID %>">昵称</label>
                        <asp:TextBox ID="txtDisplayName" runat="server" CssClass="input-control" />
                    </div>
                    <div class="field-group">
                        <label for="<%= txtPhone.ClientID %>">手机号</label>
                        <asp:TextBox ID="txtPhone" runat="server" CssClass="input-control" />
                    </div>
                    <div class="field-group">
                        <label for="<%= txtEmail.ClientID %>">邮箱</label>
                        <asp:TextBox ID="txtEmail" runat="server" CssClass="input-control" />
                    </div>
                    <div class="field-group">
                        <label for="<%= txtPassword.ClientID %>">密码</label>
                        <asp:TextBox ID="txtPassword" runat="server" CssClass="input-control" TextMode="Password" />
                    </div>
                    <div class="field-group">
                        <label for="<%= txtConfirmPassword.ClientID %>">确认密码</label>
                        <asp:TextBox ID="txtConfirmPassword" runat="server" CssClass="input-control" TextMode="Password" />
                    </div>
                </div>
                <asp:Button ID="btnRegister" runat="server" Text="提交注册" CssClass="btn-primary wide-button" OnClick="btnRegister_Click" />
            </article>
        </div>
    </section>
</asp:Content>
