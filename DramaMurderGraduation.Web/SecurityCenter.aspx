<%@ Page Title="安全中心 | 剧本杀系统" Language="C#" MasterPageFile="~/Site.Master" AutoEventWireup="true" CodeBehind="SecurityCenter.aspx.cs" Inherits="DramaMurderGraduation.Web.SecurityCenterPage" %>
<asp:Content ID="SecurityTitle" ContentPlaceHolderID="TitleContent" runat="server">
    安全中心 | 剧本杀系统
</asp:Content>
<asp:Content ID="SecurityMain" ContentPlaceHolderID="MainContent" runat="server">
    <section class="section-block">
        <div class="container split-grid detail-split">
            <article class="about-panel">
                <div class="section-heading left">
                    <h2>账号安全</h2>
                    <p>查看最近登录痕迹、资料变更记录，并从这里进入密码找回流程。</p>
                </div>
                <div class="wallet-summary-grid">
                    <article class="wallet-summary-card accent">
                        <span>当前角色</span>
                        <strong><asp:Literal ID="litRoleName" runat="server" /></strong>
                        <small>仅展示当前账号可见的安全记录</small>
                    </article>
                    <article class="wallet-summary-card">
                        <span>最近登录结果</span>
                        <strong><asp:Literal ID="litLatestLoginResult" runat="server" /></strong>
                        <small><asp:Literal ID="litLatestLoginTime" runat="server" /></small>
                    </article>
                </div>
                <div class="hero-actions top-gap">
                    <a class="btn-primary" href="ForgotPassword.aspx">找回密码</a>
                    <a class="btn-secondary" href="Settings.aspx">返回设置</a>
                </div>
            </article>

            <article class="about-panel">
                <div class="section-heading left">
                    <h2>最近登录日志</h2>
                    <p>记录登录结果、来源 IP 和浏览器信息，方便排查账号异常。</p>
                </div>
                <div class="reservation-list">
                    <asp:Repeater ID="rptLoginLogs" runat="server">
                        <ItemTemplate>
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

    <section class="section-block alt">
        <div class="container">
            <div class="section-heading left">
                <h2>资料变更历史</h2>
                <p>保存昵称、手机号、头像和签名等资料的最近变更结果。</p>
            </div>
            <div class="reservation-list">
                <asp:Repeater ID="rptProfileChangeLogs" runat="server">
                    <ItemTemplate>
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
