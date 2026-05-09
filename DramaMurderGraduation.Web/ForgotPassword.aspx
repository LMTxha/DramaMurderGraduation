<%@ Page Title="找回密码 | 剧本杀系统" Language="C#" MasterPageFile="~/Site.Master" AutoEventWireup="true" CodeBehind="ForgotPassword.aspx.cs" Inherits="DramaMurderGraduation.Web.ForgotPasswordPage" %>
<%-- 页面用途：ForgotPassword 页面负责承载对应功能的 Web Forms 标记、服务端控件和前端布局。 --%>
<asp:Content ID="ForgotPasswordTitle" ContentPlaceHolderID="TitleContent" runat="server">
    找回密码 | 剧本杀系统
</asp:Content>
<asp:Content ID="ForgotPasswordMain" ContentPlaceHolderID="MainContent" runat="server">
    <%-- 主要内容区：承载当前页面的核心业务列表、表单或详情内容。 --%>
    <section class="section-block auth-login-section">
        <div class="container narrow-shell">
            <%-- 表单面板：承载筛选条件或业务提交输入项。 --%>
            <article class="form-panel login-panel">
                <%-- 模块标题区：说明当前业务模块的名称和处理说明。 --%>
                <div class="section-heading left">
                    <p class="eyebrow">Password Reset</p>
                    <h2>找回密码</h2>
                    <p>通过用户名和已绑定手机号生成一次性校验码，再用校验码重置登录密码。</p>
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
                        <label for="<%= txtPhone.ClientID %>">绑定手机号</label>
                        <%-- 输入控件 txtPhone：接收用户输入或展示后台已有备注。 --%>
                        <asp:TextBox ID="txtPhone" runat="server" CssClass="input-control" />
                    </div>
                    <div class="field-group">
                        <label for="<%= txtTicketCode.ClientID %>">校验码</label>
                        <%-- 输入控件 txtTicketCode：接收用户输入或展示后台已有备注。 --%>
                        <asp:TextBox ID="txtTicketCode" runat="server" CssClass="input-control" />
                    </div>
                    <div class="field-group">
                        <label for="<%= txtNewPassword.ClientID %>">新密码</label>
                        <%-- 输入控件 txtNewPassword：接收用户输入或展示后台已有备注。 --%>
                        <asp:TextBox ID="txtNewPassword" runat="server" CssClass="input-control" TextMode="Password" />
                    </div>
                    <div class="field-group">
                        <label for="<%= txtConfirmPassword.ClientID %>">确认新密码</label>
                        <%-- 输入控件 txtConfirmPassword：接收用户输入或展示后台已有备注。 --%>
                        <asp:TextBox ID="txtConfirmPassword" runat="server" CssClass="input-control" TextMode="Password" />
                    </div>
                    <div class="field-group full">
                        <label>演示说明</label>
                        <p class="inline-note">当前版本没有接入短信服务，系统会直接显示本次生成的校验码，便于本地演示找回密码流程。</p>
                    </div>
                </div>

                <%-- 操作按钮区：集中放置提交、重置、跳转或审核动作。 --%>
                <div class="hero-actions">
                    <%-- 操作按钮 btnRequestTicket：点击后触发后台事件处理当前业务动作。 --%>
                    <asp:Button ID="btnRequestTicket" runat="server" Text="生成校验码" CssClass="btn-secondary" OnClick="btnRequestTicket_Click" />
                    <%-- 操作按钮 btnResetPassword：点击后触发后台事件处理当前业务动作。 --%>
                    <asp:Button ID="btnResetPassword" runat="server" Text="重置密码" CssClass="btn-primary" OnClick="btnResetPassword_Click" />
                    <a class="btn-secondary" href="Login.aspx">返回登录</a>
                </div>
            </article>
        </div>
    </section>
</asp:Content>
