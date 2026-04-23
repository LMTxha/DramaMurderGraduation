<%@ Page Title="客户端下载 | 剧本杀系统" Language="C#" AutoEventWireup="true" CodeBehind="Download.aspx.cs" Inherits="DramaMurderGraduation.Web.DownloadPage" %>
<!DOCTYPE html>
<html lang="zh-CN">
<head runat="server">
    <meta charset="utf-8" />
    <meta name="viewport" content="width=device-width, initial-scale=1" />
    <title>客户端下载 | 剧本杀系统</title>
    <style>
        * {
            box-sizing: border-box;
        }

        html,
        body {
            min-height: 100%;
            margin: 0;
            padding: 0;
        }

        body {
            background: linear-gradient(135deg, #8b66d9 0%, #bd68b5 52%, #fb7f93 100%);
            color: #fff;
            font-family: "Segoe UI", "Microsoft YaHei", Arial, sans-serif;
            overflow-x: hidden;
        }

        a {
            color: inherit;
            text-decoration: none;
        }

        .download-page {
            position: relative;
            min-height: 100vh;
            padding: 70px 7vw 42px;
            overflow: hidden;
            background:
                radial-gradient(circle at 18% 84%, rgba(255, 255, 255, 0.16), transparent 24%),
                radial-gradient(circle at 84% 16%, rgba(255, 255, 255, 0.14), transparent 22%),
                linear-gradient(135deg, #8b66d9 0%, #bd68b5 52%, #fb7f93 100%);
        }

        .download-page::before {
            content: "";
            position: absolute;
            left: -140px;
            top: -130px;
            width: 420px;
            height: 420px;
            border-radius: 999px;
            background: rgba(255, 255, 255, 0.10);
            filter: blur(8px);
        }

        .download-page::after {
            content: "";
            position: absolute;
            right: -160px;
            bottom: -180px;
            width: 520px;
            height: 520px;
            border-radius: 999px;
            background: rgba(255, 255, 255, 0.12);
            filter: blur(10px);
        }

        .download-links {
            position: absolute;
            top: 48px;
            right: 7vw;
            z-index: 2;
            display: flex;
            align-items: center;
            gap: 32px;
            color: rgba(255, 255, 255, 0.72);
            font-size: 22px;
            line-height: 1;
        }

        .download-links a:hover {
            color: #fff;
        }

        .download-center {
            position: relative;
            z-index: 1;
            display: grid;
            justify-items: center;
            padding-top: 210px;
        }

        .download-title {
            display: flex;
            align-items: center;
            justify-content: center;
            gap: 34px;
        }

        .dm-mark {
            display: grid;
            place-items: center;
            width: 92px;
            height: 92px;
            border-radius: 34px;
            background: linear-gradient(135deg, #9b6bf0 0%, #d56eb4 56%, #ff7d92 100%);
            color: #fff;
            font-size: 30px;
            font-weight: 900;
            letter-spacing: 0.08em;
            box-shadow: 0 22px 58px rgba(77, 37, 126, 0.26);
        }

        h1 {
            margin: 0;
            color: #fff;
            font-size: 56px;
            font-weight: 400;
            letter-spacing: 0;
        }

        .release-list {
            width: min(700px, 72vw);
            margin-top: 130px;
            display: grid;
            gap: 26px;
        }

        .release-row {
            display: grid;
            grid-template-columns: minmax(0, 1fr) 90px;
            align-items: center;
            gap: 42px;
            color: rgba(255, 255, 255, 0.78);
            font-size: 27px;
            line-height: 1.25;
        }

        .release-row:hover {
            color: #fff;
        }

        .release-row span {
            overflow: hidden;
            text-overflow: ellipsis;
            white-space: nowrap;
        }

        .release-row time {
            text-align: right;
            white-space: nowrap;
        }

        .more-log {
            width: min(700px, 72vw);
            margin-top: 34px;
            color: rgba(255, 255, 255, 0.82);
            font-size: 27px;
        }

        .platforms {
            position: relative;
            z-index: 1;
            width: min(1260px, 84vw);
            margin: 112px auto 0;
            display: grid;
            grid-template-columns: repeat(6, minmax(126px, 1fr));
            gap: 30px;
        }

        .platform-card {
            aspect-ratio: 1;
            display: grid;
            grid-template-rows: 46px 34px 22px;
            align-content: center;
            justify-items: center;
            gap: 8px;
            padding: 26px 20px;
            border-radius: 999px;
            background: rgba(255, 255, 255, 0.14);
            color: rgba(255, 255, 255, 0.92);
            border: 1px solid rgba(255, 255, 255, 0.12);
            transition: 0.18s ease;
        }

        .platform-card:hover {
            transform: translateY(-8px);
            background: rgba(255, 255, 255, 0.18);
            color: #fff;
        }

        .platform-icon {
            display: grid;
            place-items: center;
            width: 72px;
            height: 46px;
            color: #fff;
            font-size: 25px;
            font-weight: 800;
            line-height: 1;
        }

        .platform-card strong {
            color: #fff;
            font-size: 22px;
            font-weight: 600;
            line-height: 1.15;
            letter-spacing: 0;
            white-space: nowrap;
        }

        .platform-card small {
            max-width: 100%;
            overflow: hidden;
            color: rgba(255, 255, 255, 0.72);
            font-size: 12px;
            line-height: 1.2;
            text-overflow: ellipsis;
            white-space: nowrap;
        }

        @media (max-width: 1000px) {
            .download-page {
                padding: 46px 24px 36px;
            }

            .download-links {
                position: static;
                justify-content: flex-end;
                gap: 18px;
                font-size: 17px;
            }

            .download-center {
                padding-top: 90px;
            }

            .download-title {
                gap: 18px;
            }

            h1 {
                font-size: 38px;
            }

            .release-list,
            .more-log {
                width: 100%;
            }

            .release-list {
                margin-top: 72px;
            }

            .release-row {
                grid-template-columns: minmax(0, 1fr) 70px;
                gap: 16px;
                font-size: 20px;
            }

            .more-log {
                font-size: 20px;
            }

            .platforms {
                width: min(640px, 100%);
                grid-template-columns: repeat(3, minmax(120px, 1fr));
                gap: 22px;
                margin-top: 74px;
            }
        }

        @media (max-width: 560px) {
            .download-title {
                display: grid;
                justify-items: center;
                text-align: center;
            }

            .platforms {
                grid-template-columns: repeat(2, minmax(120px, 1fr));
            }
        }
    </style>
</head>
<body>
    <form id="MainForm" runat="server">
        <main class="download-page">
            <nav class="download-links">
                <a href="Default.aspx">返回首页</a>
                <a href="Discover.aspx">发现中心</a>
            </nav>

            <section class="download-center">
                <div class="download-title">
                    <div class="dm-mark" aria-hidden="true">DM</div>
                    <h1>剧本杀玩家客户端</h1>
                </div>

                <div class="release-list">
                    <asp:Repeater ID="rptReleaseNotes" runat="server">
                        <ItemTemplate>
                            <a href='<%# Eval("DownloadUrl") %>' class="release-row">
                                <span><%# Eval("VersionText") %> <%# Eval("Summary") %></span>
                                <time><%# Eval("ReleaseDate", "{0:MM-dd}") %></time>
                            </a>
                        </ItemTemplate>
                    </asp:Repeater>
                </div>

                <a class="more-log" href="#download-platforms">选择下载平台 &gt;</a>
            </section>

            <section class="platforms" id="download-platforms">
                <asp:Repeater ID="rptDownloadOptions" runat="server">
                    <ItemTemplate>
                        <a class='platform-card <%# Eval("PlatformCode") %>' href='<%# Eval("DownloadUrl") %>'>
                            <span class="platform-icon"><%# Eval("IconText") %></span>
                            <strong><%# Eval("PlatformName") %></strong>
                            <small><%# Eval("VersionText") %></small>
                        </a>
                    </ItemTemplate>
                </asp:Repeater>
            </section>
        </main>
    </form>
</body>
</html>
