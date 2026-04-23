<%@ Page Title="AI 助手 | 剧本杀系统" Language="C#" MasterPageFile="~/Site.Master" AutoEventWireup="true" CodeBehind="AiSearch.aspx.cs" Inherits="DramaMurderGraduation.Web.AiSearchPage" %>
<asp:Content ID="Content1" ContentPlaceHolderID="TitleContent" runat="server">
    AI 助手 | 剧本杀系统
</asp:Content>
<asp:Content ID="Content2" ContentPlaceHolderID="MainContent" runat="server">
    <section class="section-block">
        <div class="container empty-state">
            <h1>正在跳转到 Qwen AI</h1>
            <p>如果浏览器没有自动跳转，请点击下面的按钮。</p>
            <a class="btn-primary" href="https://chat.qwen.ai/">打开 Qwen AI</a>
        </div>
    </section>
</asp:Content>
