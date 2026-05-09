<%@ Page Title="AI 助手 | 剧本杀系统" Language="C#" MasterPageFile="~/Site.Master" AutoEventWireup="true" CodeBehind="AiSearch.aspx.cs" Inherits="DramaMurderGraduation.Web.AiSearchPage" %>
<%-- 页面用途：AiSearch 页面负责承载对应功能的 Web Forms 标记、服务端控件和前端布局。 --%>
<asp:Content ID="Content1" ContentPlaceHolderID="TitleContent" runat="server">
    AI 助手 | 剧本杀系统
</asp:Content>
<asp:Content ID="Content2" ContentPlaceHolderID="MainContent" runat="server">
    <%-- 主要内容区：承载当前页面的核心业务列表、表单或详情内容。 --%>
    <section class="section-block">
        <div class="container empty-state">
            <h1>正在跳转到 Qwen AI</h1>
            <p>如果浏览器没有自动跳转，请点击下面的按钮。</p>
            <a class="btn-primary" href="https://chat.qwen.ai/">打开 Qwen AI</a>
        </div>
    </section>
</asp:Content>
