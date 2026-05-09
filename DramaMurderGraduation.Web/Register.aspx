<%@ Page Title="用户注册 | 剧本杀系统" Language="C#" MasterPageFile="~/Site.Master" AutoEventWireup="true" CodeBehind="Register.aspx.cs" Inherits="DramaMurderGraduation.Web.RegisterPage" %>
<%-- 页面用途：Register 页面负责承载对应功能的 Web Forms 标记、服务端控件和前端布局。 --%>
<asp:Content ID="Content1" ContentPlaceHolderID="TitleContent" runat="server">
    用户注册 | 剧本杀系统
</asp:Content>
<asp:Content ID="Content2" ContentPlaceHolderID="MainContent" runat="server">
    <%-- 页面分区：把当前页面内容按业务模块拆分展示。 --%>
    <section class="inner-hero">
        <div class="container">
            <p class="eyebrow">Register Account</p>
            <h1>用户注册</h1>
            <p>新用户注册后需要管理员审核，通过后才能登录并进行剧本投稿。</p>
        </div>
    </section>

    <%-- 主要内容区：承载当前页面的核心业务列表、表单或详情内容。 --%>
    <section class="section-block">
        <div class="container narrow-shell">
            <%-- 表单面板：承载筛选条件或业务提交输入项。 --%>
            <article class="form-panel">
                <%-- 模块标题区：说明当前业务模块的名称和处理说明。 --%>
                <div class="section-heading left">
                    <h2>填写注册信息</h2>
            <p>注册后就能预约场次、进入房间互动，也能在玩家中心维护自己的资料。</p>
                </div>
                <%-- 面板控件 pnlMessage：后台可通过 Visible/CssClass 控制整块内容是否显示以及提示样式。 --%>
                <asp:Panel ID="pnlMessage" runat="server" Visible="false" CssClass="status-message">
                    <asp:Literal ID="litMessage" runat="server" />
                </asp:Panel>
                <%-- 表单网格：按响应式布局排列输入框、下拉框和筛选条件。 --%>
                <div class="form-grid">
                    <div class="field-group">
                        <label for="<%= txtUsername.ClientID %>">用户名</label>
                        <%-- 输入控件 txtUsername：接收用户输入或展示后台已有备注。 --%>
                        <asp:TextBox ID="txtUsername" runat="server" CssClass="input-control" />
                    </div>
                    <div class="field-group">
                        <label for="<%= txtDisplayName.ClientID %>">昵称</label>
                        <%-- 输入控件 txtDisplayName：接收用户输入或展示后台已有备注。 --%>
                        <asp:TextBox ID="txtDisplayName" runat="server" CssClass="input-control" />
                    </div>
                    <div class="field-group">
                        <label for="<%= txtPhone.ClientID %>">手机号</label>
                        <%-- 输入控件 txtPhone：接收用户输入或展示后台已有备注。 --%>
                        <asp:TextBox ID="txtPhone" runat="server" CssClass="input-control" />
                    </div>
                    <div class="field-group">
                        <label for="<%= txtEmail.ClientID %>">邮箱</label>
                        <%-- 输入控件 txtEmail：接收用户输入或展示后台已有备注。 --%>
                        <asp:TextBox ID="txtEmail" runat="server" CssClass="input-control" />
                    </div>
                    <div class="field-group">
                        <label for="<%= txtPassword.ClientID %>">密码</label>
                        <%-- 输入控件 txtPassword：接收用户输入或展示后台已有备注。 --%>
                        <asp:TextBox ID="txtPassword" runat="server" CssClass="input-control" TextMode="Password" />
                    </div>
                    <div class="field-group">
                        <label for="<%= txtConfirmPassword.ClientID %>">确认密码</label>
                        <%-- 输入控件 txtConfirmPassword：接收用户输入或展示后台已有备注。 --%>
                        <asp:TextBox ID="txtConfirmPassword" runat="server" CssClass="input-control" TextMode="Password" />
                    </div>
                </div>
                <%-- 操作按钮 btnRegister：点击后触发后台事件处理当前业务动作。 --%>
                <asp:Button ID="btnRegister" runat="server" Text="提交注册" CssClass="btn-primary wide-button" OnClick="btnRegister_Click" />
            </article>
        </div>
    </section>
</asp:Content>
