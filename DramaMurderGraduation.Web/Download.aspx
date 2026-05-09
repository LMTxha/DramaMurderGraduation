<%@ Page Title="客户端下载 | 剧本杀系统" Language="C#" AutoEventWireup="true" CodeBehind="Download.aspx.cs" Inherits="DramaMurderGraduation.Web.DownloadPage" %>
<%-- 页面用途：Download 页面负责承载对应功能的 Web Forms 标记、服务端控件和前端布局。 --%>
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
            background:
                linear-gradient(180deg, rgba(3, 3, 4, 0.24), rgba(3, 3, 4, 0.70)),
                linear-gradient(90deg, rgba(0, 0, 0, 0.42), rgba(0, 0, 0, 0.04) 48%, rgba(0, 0, 0, 0.48)),
                url("Content/celestial-map-bg.jpg") center top / cover no-repeat fixed,
                #050506;
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
                radial-gradient(circle at 50% 46%, rgba(247, 200, 95, 0.16), transparent 28%),
                linear-gradient(180deg, rgba(5, 5, 6, 0.16), rgba(5, 5, 6, 0.68)),
                url("Content/celestial-map-bg.jpg") center top / cover no-repeat fixed,
                #050506;
        }

        .download-page::before {
            content: "";
            position: absolute;
            left: -140px;
            top: -130px;
            width: 420px;
            height: 420px;
            border-radius: 999px;
            display: none;
        }

        .download-page::after {
            content: "";
            position: absolute;
            right: -160px;
            bottom: -180px;
            width: 520px;
            height: 520px;
            border-radius: 999px;
            display: none;
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
            position: relative;
            display: grid;
            place-items: center;
            width: 104px;
            height: 92px;
            border: 1px solid rgba(255, 255, 255, 0.14);
            border-radius: 28px;
            background:
                radial-gradient(circle at 78% 18%, rgba(255, 255, 255, 0.18), transparent 24px),
                linear-gradient(145deg, #101014, #050506 66%, #15151c);
            color: #fff;
            box-shadow: 0 22px 58px rgba(5, 5, 6, 0.44);
            overflow: hidden;
        }

        .dm-mark::after {
            content: "";
            position: absolute;
            inset: 12px;
            border-radius: 22px;
            background: linear-gradient(135deg, rgba(255, 92, 92, 0.18), rgba(42, 209, 255, 0.14));
            filter: blur(16px);
            opacity: 0.86;
        }

        .dm-logo-svg {
            position: relative;
            z-index: 1;
            width: 82px;
            height: 52px;
            overflow: visible;
        }

        .dm-logo-stroke {
            fill: none;
            stroke-linecap: round;
            stroke-linejoin: round;
            stroke-width: 7;
        }

        .dm-logo-red {
            stroke: #ff466d;
        }

        .dm-logo-orange {
            stroke: #ff9f43;
        }

        .dm-logo-cyan {
            stroke: #24c8ff;
        }

        .dm-logo-green {
            stroke: #60d978;
        }

        .dm-logo-yellow {
            stroke: #ffe55c;
        }

        .dm-logo-dot {
            filter: drop-shadow(0 0 5px currentColor);
        }

        .dm-logo-orange-fill {
            color: #ff9f43;
            fill: #ff9f43;
        }

        .dm-logo-cyan-fill {
            color: #24c8ff;
            fill: #24c8ff;
        }

        .dm-logo-green-fill {
            color: #60d978;
            fill: #60d978;
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

            <%-- 页面分区：把当前页面内容按业务模块拆分展示。 --%>
            <section class="download-center">
                <div class="download-title">
                    <div class="dm-mark" aria-label="DM">
                        <svg class="dm-logo-svg" viewBox="0 0 128 82" aria-hidden="true" focusable="false">
                            <path class="dm-logo-stroke dm-logo-red" d="M18 64 V18" />
                            <path class="dm-logo-stroke dm-logo-orange" d="M18 18 H43 C57 18 67 27 67 41" />
                            <path class="dm-logo-stroke dm-logo-cyan" d="M67 41 C67 56 56 64 42 64 H18" />
                            <path class="dm-logo-stroke dm-logo-green" d="M80 64 V18 L97 46" />
                            <path class="dm-logo-stroke dm-logo-yellow" d="M97 46 L114 18 V64" />
                            <circle class="dm-logo-dot dm-logo-orange-fill" cx="43" cy="18" r="4" />
                            <circle class="dm-logo-dot dm-logo-cyan-fill" cx="67" cy="64" r="4" />
                            <circle class="dm-logo-dot dm-logo-green-fill" cx="80" cy="18" r="4" />
                        </svg>
                    </div>
                    <h1>剧本杀玩家客户端</h1>
                </div>

                <div class="release-list">
                    <%-- 数据列表控件 rptReleaseNotes：后台绑定集合数据后，按 ItemTemplate 循环渲染每条记录。 --%>
                    <asp:Repeater ID="rptReleaseNotes" runat="server">
                        <%-- 列表项模板：定义 Repeater 中每一条业务记录的 HTML 结构和绑定字段。 --%>
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

            <%-- 页面分区：把当前页面内容按业务模块拆分展示。 --%>
            <section class="platforms" id="download-platforms">
                <%-- 数据列表控件 rptDownloadOptions：后台绑定集合数据后，按 ItemTemplate 循环渲染每条记录。 --%>
                <asp:Repeater ID="rptDownloadOptions" runat="server">
                    <%-- 列表项模板：定义 Repeater 中每一条业务记录的 HTML 结构和绑定字段。 --%>
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
