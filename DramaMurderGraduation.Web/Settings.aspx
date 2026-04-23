<%@ Page Title="微信式设置 | 剧本杀系统" Language="C#" MasterPageFile="~/Site.Master" AutoEventWireup="true" CodeBehind="Settings.aspx.cs" Inherits="DramaMurderGraduation.Web.SettingsPage" %>
<asp:Content ID="SettingsTitle" ContentPlaceHolderID="TitleContent" runat="server">
    微信式设置 | 剧本杀系统
</asp:Content>
<asp:Content ID="SettingsMain" ContentPlaceHolderID="MainContent" runat="server">
    <section class="wechat-settings-page">
        <a class="wx-close" href="Friends.aspx">×</a>
        <nav class="wx-settings-nav">
            <a class="active" href="#account"><span class="wx-icon wx-icon-contacts"></span>账号与存储<i></i></a>
            <a href="#general"><span class="wx-icon wx-icon-settings"></span>通用</a>
            <a href="#shortcut"><span class="wx-icon wx-icon-menu"></span>快捷键</a>
            <a href="#notice"><span class="wx-icon wx-icon-chat"></span>通知</a>
            <a href="#plugin"><span class="wx-icon wx-icon-moments"></span>插件</a>
            <a href="#security"><span class="wx-icon wx-icon-wallet"></span>账号安全</a>
        </nav>

        <main class="wx-settings-scroll">
            <div hidden>
                <asp:Literal ID="litUsername" runat="server" />
                <asp:Literal ID="litPhone" runat="server" />
                <asp:Literal ID="litEmail" runat="server" />
            </div>

            <section class="wx-settings-card" id="account">
                <div class="wx-account-head">
                    <asp:Image ID="imgAvatar" runat="server" AlternateText="玩家头像" />
                    <div>
                        <strong><asp:Literal ID="litDisplayName" runat="server" /></strong>
                        <span><asp:Literal ID="litPublicUserCode" runat="server" /></span>
                    </div>
                    <asp:LinkButton ID="btnLogoutProxy" runat="server" CssClass="wx-secondary-btn" OnClick="btnLogoutProxy_Click">退出登录</asp:LinkButton>
                </div>
                <div class="wx-setting-line">
                    <div>
                        <strong>登录方式</strong>
                        <p>在本机登录微信需手机确认或扫码登录。</p>
                    </div>
                    <asp:DropDownList ID="ddlLoginConfirmMode" runat="server" CssClass="wx-choice-input">
                        <asp:ListItem Value="MobileConfirm">在手机微信中确认</asp:ListItem>
                        <asp:ListItem Value="QrCode">扫码登录</asp:ListItem>
                        <asp:ListItem Value="Password">账号密码登录</asp:ListItem>
                    </asp:DropDownList>
                </div>
                <div class="wx-setting-line">
                    <strong>保留聊天记录</strong>
                    <asp:CheckBox ID="chkKeepChatHistory" runat="server" CssClass="wx-native-check" />
                </div>
            </section>

            <section class="wx-settings-card" id="storage">
                <div class="wx-setting-line">
                    <div>
                        <strong>存储空间</strong>
                        <p>含部分历史版本数据。</p>
                    </div>
                    <a class="wx-secondary-btn" href="#storage">管理</a>
                </div>
                <div class="wx-setting-line">
                    <div>
                        <strong>存储位置</strong>
                        <asp:TextBox ID="txtStoragePath" runat="server" CssClass="wx-path-input" />
                    </div>
                    <a class="wx-secondary-btn" href="#storage">更改</a>
                </div>
                <div class="wx-setting-line">
                    <strong>自动下载小于</strong>
                    <span class="wx-inline-edit"><asp:TextBox ID="txtAutoDownloadMaxMb" runat="server" CssClass="wx-number-input" /> MB 的文件</span>
                    <asp:CheckBox ID="chkNotificationEnabled" runat="server" CssClass="wx-native-check" />
                </div>
                <asp:Panel ID="pnlDesktopMessage" runat="server" Visible="false" CssClass="status-message">
                    <asp:Literal ID="litDesktopMessage" runat="server" />
                </asp:Panel>
                <asp:Button ID="btnSaveDesktopSettings" runat="server" Text="保存桌面端设置" CssClass="wx-primary-btn" OnClick="btnSaveDesktopSettings_Click" />
            </section>

            <section class="wx-phone-card" id="profile">
                <div class="wx-phone-title">个人资料</div>
                <div class="wx-avatar-editor">
                    <div class="wx-avatar-preview-wrap">
                        <asp:Image ID="imgAvatarPreview" runat="server" CssClass="wx-avatar-preview" AlternateText="头像预览" />
                        <button type="button" class="wx-avatar-pick-btn" data-avatar-picker>选择本地头像</button>
                    </div>
                    <div class="wx-avatar-url-field">
                        <label for="<%= txtAvatarUrl.ClientID %>">头像图片 URL 或本地头像</label>
                        <asp:TextBox ID="txtAvatarUrl" runat="server" CssClass="wx-avatar-url-input" placeholder="https://images.unsplash.com/photo-1500648767791-00dcc994a43e?auto=format&fit=crop&w=600&q=80" />
                        <div class="wx-avatar-upload-row">
                            <asp:FileUpload ID="fuAvatarImage" runat="server" CssClass="wx-avatar-file-input" accept="image/*" />
                            <span>支持 jpg、png、gif、webp，本地选择后点保存即可更换头像。</span>
                        </div>
                        <div class="wx-avatar-actions">
                            <button type="button" class="wx-secondary-btn" data-avatar-picker>选择图片</button>
                            <asp:Button ID="btnSaveAvatar" runat="server" Text="保存头像" CssClass="wx-primary-btn" OnClick="btnSaveAvatar_Click" />
                        </div>
                        <p>可以选择本地图片上传，也可以粘贴一张公开可访问的图片地址。保存后会同步到玩家中心、好友列表和聊天头像。</p>
                    </div>
                </div>
                <div class="wx-phone-row"><span>名字</span><asp:TextBox ID="txtDisplayName" runat="server" CssClass="wx-phone-input" /></div>
                <div class="wx-phone-row"><span>性别</span><asp:TextBox ID="txtGender" runat="server" CssClass="wx-phone-input" /></div>
                <div class="wx-phone-row"><span>地区</span><asp:TextBox ID="txtRegion" runat="server" CssClass="wx-phone-input" /></div>
                <div class="wx-phone-row"><span>手机号</span><asp:TextBox ID="txtPhone" runat="server" CssClass="wx-phone-input" /></div>
                <div class="wx-phone-row"><span>微信号</span><asp:TextBox ID="txtPublicUserCode" runat="server" CssClass="wx-phone-input" /></div>
                <div class="wx-phone-row"><span>邮箱</span><asp:TextBox ID="txtEmail" runat="server" CssClass="wx-phone-input" ReadOnly="true" /></div>
                <div class="wx-phone-row"><span>签名</span><asp:TextBox ID="txtSignature" runat="server" CssClass="wx-phone-input" /></div>
                <asp:Panel ID="pnlProfileMessage" runat="server" Visible="false" CssClass="status-message">
                    <asp:Literal ID="litProfileMessage" runat="server" />
                </asp:Panel>
                <asp:Button ID="btnSaveProfile" runat="server" Text="保存个人资料" CssClass="wx-primary-btn wide" OnClick="btnSaveProfile_Click" />
            </section>

            <section class="wx-phone-card" id="security">
                <div class="wx-phone-title">账号安全</div>
                <div class="wx-phone-row"><span>微信密码</span><em>已设置</em></div>
                <div class="wx-phone-row"><span>声音锁</span><em>已开启</em></div>
                <div class="wx-phone-row"><span>应急联系人</span><em></em></div>
                <div class="wx-phone-row"><span>登录设备管理</span><em></em></div>
                <div class="wx-phone-row"><span>更多安全设置</span><em></em></div>
                <p class="wx-phone-note">如果遇到账号信息泄露、忘记密码、诈骗等账号安全问题，可前往微信安全中心。</p>
            </section>

            <section class="wx-phone-card" id="password">
                <div class="wx-phone-title">设置密码</div>
                <p class="wx-phone-note">设置微信密码后可以通过微信号 / 手机号 / 邮箱 + 微信密码登录。</p>
                <asp:Panel ID="pnlPasswordMessage" runat="server" Visible="false" CssClass="status-message">
                    <asp:Literal ID="litPasswordMessage" runat="server" />
                </asp:Panel>
                <div class="wx-phone-row"><span>旧密码</span><asp:TextBox ID="txtCurrentPassword" runat="server" CssClass="wx-phone-input" TextMode="Password" placeholder="请填写旧密码" /></div>
                <div class="wx-phone-row"><span>新密码</span><asp:TextBox ID="txtNewPassword" runat="server" CssClass="wx-phone-input" TextMode="Password" placeholder="请输入新的密码" /></div>
                <div class="wx-phone-row"><span>确认密码</span><asp:TextBox ID="txtConfirmPassword" runat="server" CssClass="wx-phone-input" TextMode="Password" placeholder="请再次输入新密码" /></div>
                <p class="wx-phone-note">密码必须是 8-16 位英文字母、数字、字符组合。</p>
                <asp:Button ID="btnChangePassword" runat="server" Text="完成" CssClass="wx-primary-btn wide" OnClick="btnChangePassword_Click" />
            </section>

            <section class="wx-settings-card" id="general">
                <div class="wx-setting-line"><strong>快捷键方案</strong><asp:DropDownList ID="ddlShortcutScheme" runat="server" CssClass="wx-choice-input"><asp:ListItem Value="Default">默认</asp:ListItem><asp:ListItem Value="Classic">经典微信</asp:ListItem><asp:ListItem Value="GameRoom">开本助手</asp:ListItem></asp:DropDownList></div>
                <div class="wx-setting-line"><strong>插件</strong><asp:CheckBox ID="chkPluginEnabled" runat="server" CssClass="wx-native-check" /></div>
                <div class="wx-setting-line"><strong>允许好友申请</strong><asp:CheckBox ID="chkFriendRequestEnabled" runat="server" CssClass="wx-native-check" /></div>
                <div class="wx-setting-line"><strong>允许通过手机号搜索我</strong><asp:CheckBox ID="chkPhoneSearchEnabled" runat="server" CssClass="wx-native-check" /></div>
                <div class="wx-setting-line"><strong>允许陌生人查看朋友圈</strong><asp:CheckBox ID="chkShowMomentsToStrangers" runat="server" CssClass="wx-native-check" /></div>
                <div class="wx-setting-line"><strong>按 Enter 发送消息</strong><asp:CheckBox ID="chkUseEnterToSend" runat="server" CssClass="wx-native-check" /></div>
            </section>
        </main>
    </section>
    <script>
        (function () {
            var input = document.getElementById('<%= txtAvatarUrl.ClientID %>');
            var fileInput = document.getElementById('<%= fuAvatarImage.ClientID %>');
            var preview = document.getElementById('<%= imgAvatarPreview.ClientID %>');
            var headerAvatar = document.getElementById('<%= imgAvatar.ClientID %>');
            var pickerButtons = document.querySelectorAll('[data-avatar-picker]');
            if (!input || !preview) {
                return;
            }

            var fallback = preview.getAttribute('src') || 'https://images.unsplash.com/photo-1500648767791-00dcc994a43e?auto=format&fit=crop&w=600&q=80';
            function updatePreview() {
                var nextUrl = input.value.trim();
                preview.src = nextUrl || fallback;
                if (headerAvatar) {
                    headerAvatar.src = nextUrl || fallback;
                }
            }

            preview.addEventListener('error', function () {
                preview.src = fallback;
            });
            input.addEventListener('input', updatePreview);
            input.addEventListener('change', updatePreview);
            if (fileInput) {
                preview.style.cursor = 'pointer';
                preview.addEventListener('click', function () {
                    fileInput.click();
                });
                for (var i = 0; i < pickerButtons.length; i++) {
                    pickerButtons[i].addEventListener('click', function () {
                        fileInput.click();
                    });
                }
                fileInput.addEventListener('change', function () {
                    var file = fileInput.files && fileInput.files[0];
                    if (!file) {
                        updatePreview();
                        return;
                    }

                    if (!file.type || file.type.indexOf('image/') !== 0) {
                        updatePreview();
                        return;
                    }

                    var objectUrl = URL.createObjectURL(file);
                    preview.src = objectUrl;
                    if (headerAvatar) {
                        headerAvatar.src = objectUrl;
                    }
                    input.value = '';
                });
            }
        })();
    </script>
</asp:Content>
