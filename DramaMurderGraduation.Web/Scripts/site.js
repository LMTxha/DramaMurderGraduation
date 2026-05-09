(function () {
    // 全站通用交互：移动端导航、顶部折叠区、侧边面板、返回按钮和推荐轮播。
    // 这些逻辑不依赖后端状态，所以放在独立闭包中，避免污染全局变量。
    var navToggle = document.querySelector("[data-nav-toggle]");
    var nav = document.querySelector("[data-nav]");
    if (navToggle && nav) {
        navToggle.addEventListener("click", function () {
            nav.classList.toggle("open");
        });
    }

    var headerFoldBody = document.querySelector("[data-header-fold-body]");
    var headerFoldToggle = document.querySelector("[data-header-fold-toggle]");
    if (headerFoldBody && headerFoldToggle) {
        headerFoldToggle.addEventListener("click", function () {
            var collapsed = headerFoldBody.classList.toggle("header-fold-collapsed");
            headerFoldToggle.setAttribute("aria-expanded", collapsed ? "false" : "true");
            headerFoldToggle.setAttribute("title", collapsed ? "展开顶部导航" : "收起顶部导航");
        });
    }

    var sidePanel = document.querySelector("[data-side-panel]");
    var sidePanelToggles = document.querySelectorAll("[data-side-panel-toggle]");
    if (sidePanel && sidePanelToggles.length) {
        var mainPane = sidePanel.closest(".wechat-main-pane");
        var applySidePanelState = function (collapsed) {
            sidePanel.classList.toggle("collapsed", collapsed);
            if (mainPane) {
                mainPane.classList.toggle("side-panel-collapsed", collapsed);
            }
            sidePanelToggles.forEach(function (toggleButton) {
                toggleButton.setAttribute("aria-expanded", collapsed ? "false" : "true");
                toggleButton.setAttribute("aria-label", collapsed ? "展开右侧功能区" : "收起右侧功能区");
                toggleButton.setAttribute("title", collapsed ? "展开右侧功能区" : "收起右侧功能区");
            });
        };

        sidePanelToggles.forEach(function (panelToggle) {
            panelToggle.addEventListener("click", function (event) {
                event.preventDefault();
                event.stopPropagation();
                var collapsed = !(mainPane && mainPane.classList.contains("side-panel-collapsed"));
                applySidePanelState(collapsed);
            });
        });

        applySidePanelState(mainPane && mainPane.classList.contains("side-panel-collapsed"));
    }

    var historyBackLinks = document.querySelectorAll("[data-history-back]");
    historyBackLinks.forEach(function (backLink) {
        backLink.addEventListener("click", function (event) {
            if (window.history.length > 1) {
                event.preventDefault();
                window.history.back();
            }
        });
    });

    document.addEventListener("click", function (event) {
        var navLink = event.target.closest("[data-room-nav-link]");
        if (!navLink) {
            return;
        }

        var targetUrl = navLink.getAttribute("href");
        if (!targetUrl || targetUrl === "#") {
            return;
        }

        event.preventDefault();
        window.location.assign(targetUrl);
    });

    var enhanceGlobalCollapsibleModules = function () {
        var selectors = [
            ".section-block .container > article",
            ".section-block .container > .form-panel",
            ".section-block .container > .about-panel",
            ".split-grid > article",
            ".detail-grid > article",
            ".wallet-layout > article",
            ".admin-grid > article",
            ".admin-card",
            ".content-card"
        ].join(", ");
        var modules = Array.prototype.slice.call(document.querySelectorAll(selectors))
            .filter(function (module, index, list) {
                return list.indexOf(module) === index
                    && !module.matches(".reservation-card, .wallet-summary-card, .script-card, .review-card, .character-card, .timeline-card, .metric-card")
                    && !module.matches("[data-host-panel], .gameplay-panel, #room-participant-panel, #room-media-panel, #room-chat-panel, .host-console-panel")
                    && !module.classList.contains("admin-collapsible-module")
                    && !module.classList.contains("dm-dashboard-collapsible-module")
                    && !module.classList.contains("room-collapsible-module")
                    && !module.querySelector(":scope > .global-collapse-toggle")
                    && !module.querySelector(":scope > .admin-collapse-toggle")
                    && !module.querySelector(":scope > .dm-dashboard-collapse-toggle")
                    && !module.querySelector(":scope > .room-module-collapse-toggle");
            });

        var getTitle = function (module, index) {
            var heading = module.querySelector(":scope > .section-heading h1, :scope > .section-heading h2, :scope > .section-heading h3, :scope > h1, :scope > h2, :scope > h3");
            var title = heading ? heading.textContent.replace(/\s+/g, " ").trim() : "";
            return title || "页面模块 " + (index + 1);
        };

        var setModuleCollapsed = function (module, button, title, collapsed) {
            module.classList.toggle("global-module-collapsed", collapsed);
            button.textContent = collapsed ? "展开" : "收起";
            button.setAttribute("aria-expanded", collapsed ? "false" : "true");
            button.setAttribute("title", (collapsed ? "展开 " : "收起 ") + title);
        };

        modules.forEach(function (module, index) {
            var title = getTitle(module, index);
            var key = "dramamurder-global-collapse:" + window.location.pathname + ":" + (module.id || title || index);
            var button = document.createElement("button");
            button.type = "button";
            button.className = "global-collapse-toggle";
            button.setAttribute("aria-label", "折叠或展开 " + title);
            module.classList.add("global-collapsible-module");
            module.appendChild(button);

            var collapsed = false;
            try {
                collapsed = window.localStorage.getItem(key) === "1";
            } catch (error) {
                collapsed = false;
            }

            setModuleCollapsed(module, button, title, collapsed);

            button.addEventListener("click", function (event) {
                event.preventDefault();
                event.stopPropagation();
                var nextCollapsed = !module.classList.contains("global-module-collapsed");
                setModuleCollapsed(module, button, title, nextCollapsed);
                try {
                    window.localStorage.setItem(key, nextCollapsed ? "1" : "0");
                } catch (error) {
                    // 浏览器禁止本地存储时，折叠仍在当前页面可用。
                }
            });
        });
    };

    enhanceGlobalCollapsibleModules();

    var adminReservationArea = document.querySelector("#reservation-orders");
    if (adminReservationArea) {
        var storagePrefix = "dramamurder-admin-collapse:";
        var getModuleTitle = function (target, index) {
            var heading = target.querySelector("h1, h2, h3");
            var title = heading ? heading.textContent.replace(/\s+/g, " ").trim() : "";
            return title || "后台模块 " + (index + 1);
        };
        var getCollapseKey = function (target, index) {
            return storagePrefix + window.location.pathname + ":" + (target.id || index);
        };
        var setCollapseButtonText = function (button, title, collapsed) {
            button.innerHTML = collapsed
                ? "<span class=\"admin-collapse-chip\">模块</span><span class=\"admin-collapse-title\">展开 " + title + "</span><span class=\"admin-collapse-icon\">+</span>"
                : "<span class=\"admin-collapse-title\">收起</span><span class=\"admin-collapse-icon\">−</span>";
            button.setAttribute("aria-expanded", collapsed ? "false" : "true");
            button.setAttribute("title", collapsed ? "展开 " + title : "收起 " + title);
        };
        var collapsibleModules = Array.prototype.slice.call(document.querySelectorAll(".detail-hero .detail-copy, .detail-hero .about-panel, .section-block"));
        collapsibleModules.filter(function (target) {
            return !target.classList.contains("global-collapsible-module");
        }).forEach(function (target, index) {
            var title = getModuleTitle(target, index);
            var key = getCollapseKey(target, index);
            var button = document.createElement("button");
            button.type = "button";
            button.className = "admin-collapse-toggle";
            button.setAttribute("aria-label", "折叠或展开 " + title);
            target.classList.add("admin-collapsible-module");
            target.appendChild(button);

            var collapsed = false;
            try {
                collapsed = window.localStorage.getItem(key) === "1";
            } catch (error) {
                collapsed = false;
            }

            target.classList.toggle("admin-module-collapsed", collapsed);
            setCollapseButtonText(button, title, collapsed);

            button.addEventListener("click", function (event) {
                event.preventDefault();
                event.stopPropagation();
                var nextCollapsed = !target.classList.contains("admin-module-collapsed");
                target.classList.toggle("admin-module-collapsed", nextCollapsed);
                setCollapseButtonText(button, title, nextCollapsed);
                try {
                    window.localStorage.setItem(key, nextCollapsed ? "1" : "0");
                } catch (error) {
                    // 浏览器禁止本地存储时，折叠仍在当前页面可用。
                }
            });
        });
    }

    if (/\/DmDashboard\.aspx$/i.test(window.location.pathname)) {
        var dmStoragePrefix = "dramamurder-dm-dashboard-collapse:";
        var dmModules = Array.prototype.slice.call(document.querySelectorAll(
            ".detail-hero .about-panel, .section-block .container > .about-panel.top-gap"
        ));
        var getDmModuleTitle = function (target, index) {
            var heading = target.querySelector("h1, h2, h3");
            var title = heading ? heading.textContent.replace(/\s+/g, " ").trim() : "";
            return title || "DM 模块 " + (index + 1);
        };
        var setDmModuleCollapsed = function (target, button, title, collapsed) {
            target.classList.toggle("dm-dashboard-module-collapsed", collapsed);
            button.textContent = collapsed ? "展开" : "收起";
            button.setAttribute("aria-expanded", collapsed ? "false" : "true");
            button.setAttribute("title", (collapsed ? "展开 " : "收起 ") + title);
        };

        dmModules.filter(function (target) {
            return !target.classList.contains("global-collapsible-module");
        }).forEach(function (target, index) {
            var title = getDmModuleTitle(target, index);
            var key = dmStoragePrefix + window.location.pathname + ":" + (target.id || index);
            var button = document.createElement("button");
            button.type = "button";
            button.className = "dm-dashboard-collapse-toggle";
            button.setAttribute("aria-label", "折叠或展开 " + title);
            target.classList.add("dm-dashboard-collapsible-module");
            target.appendChild(button);

            var collapsed = false;
            try {
                collapsed = window.localStorage.getItem(key) === "1";
            } catch (error) {
                collapsed = false;
            }

            setDmModuleCollapsed(target, button, title, collapsed);

            button.addEventListener("click", function (event) {
                event.preventDefault();
                event.stopPropagation();
                var nextCollapsed = !target.classList.contains("dm-dashboard-module-collapsed");
                setDmModuleCollapsed(target, button, title, nextCollapsed);
                try {
                    window.localStorage.setItem(key, nextCollapsed ? "1" : "0");
                } catch (error) {
                    // 浏览器禁止本地存储时，折叠仍在当前页面可用。
                }
            });
        });
    }

    document.querySelectorAll("[data-recommendation-carousel]").forEach(function (carousel) {
        // 推荐轮播支持桌面同时露出两个卡片、移动端露出一个卡片。
        // aria-hidden/aria-current 会随轮播状态更新，兼顾键盘和读屏体验。
        var items = Array.prototype.slice.call(carousel.querySelectorAll("[data-carousel-item]"));
        var dotsHost = carousel.querySelector("[data-carousel-dots]");
        var prevButton = carousel.querySelector("[data-carousel-prev]");
        var nextButton = carousel.querySelector("[data-carousel-next]");
        var intervalMs = parseInt(carousel.getAttribute("data-interval"), 10) || 20000;
        var desktopVisibleCount = parseInt(carousel.getAttribute("data-visible-desktop"), 10) || 2;
        var mobileVisibleCount = parseInt(carousel.getAttribute("data-visible-mobile"), 10) || 1;
        var activeIndex = 0;
        var timer = null;
        var dots = [];

        if (items.length <= 1) {
            carousel.classList.add("single-item");
            return;
        }

        var getVisibleCount = function () {
            return window.matchMedia("(max-width: 760px)").matches ? mobileVisibleCount : desktopVisibleCount;
        };

        var isVisible = function (itemIndex, visibleCount) {
            for (var offset = 0; offset < visibleCount; offset += 1) {
                if ((activeIndex + offset) % items.length === itemIndex) {
                    return true;
                }
            }

            return false;
        };

        var render = function () {
            var visibleCount = Math.min(getVisibleCount(), items.length);
            items.forEach(function (item, index) {
                var active = isVisible(index, visibleCount);
                item.classList.toggle("is-active", active);
                item.setAttribute("aria-hidden", active ? "false" : "true");
            });

            dots.forEach(function (dot, index) {
                var active = index === activeIndex;
                dot.classList.toggle("is-active", active);
                dot.setAttribute("aria-current", active ? "true" : "false");
            });
        };

        var goTo = function (index) {
            activeIndex = (index + items.length) % items.length;
            render();
        };

        var restart = function () {
            if (timer) {
                window.clearInterval(timer);
            }

            timer = window.setInterval(function () {
                goTo(activeIndex + 1);
            }, intervalMs);
        };

        if (dotsHost) {
            items.forEach(function (_item, index) {
                var dot = document.createElement("button");
                dot.type = "button";
                dot.className = "recommendation-dot";
                dot.setAttribute("aria-label", "切换到第 " + (index + 1) + " 个推荐");
                dot.addEventListener("click", function () {
                    goTo(index);
                    restart();
                });
                dotsHost.appendChild(dot);
                dots.push(dot);
            });
        }

        if (prevButton) {
            prevButton.addEventListener("click", function () {
                goTo(activeIndex - 1);
                restart();
            });
        }

        if (nextButton) {
            nextButton.addEventListener("click", function () {
                goTo(activeIndex + 1);
                restart();
            });
        }

        carousel.addEventListener("mouseenter", function () {
            if (timer) {
                window.clearInterval(timer);
            }
        });

        carousel.addEventListener("mouseleave", restart);
        window.addEventListener("resize", render);

        carousel.classList.add("initialized");
        render();
        restart();
    });
})();

(function () {
    // 游戏房间实时交互：轮询 WebMethod、渲染房间状态、处理媒体录制和玩家/DM 操作。
    // 后端 WebMethod 返回 ASP.NET AJAX 的 { d: ... } 包装时，postJson 会自动解包。
    var roomRoot = document.querySelector("[data-game-room]");
    if (!roomRoot) {
        return;
    }

    var endpoint = roomRoot.getAttribute("data-room-endpoint") || "GameRoom.aspx";
    var reservationId = parseInt(roomRoot.getAttribute("data-reservation-id"), 10);
    var state = null;
    var localStream = null;
    var mediaRecorder = null;
    var recordedChunks = [];
    var refreshTimerId = null;
    var refreshInFlight = false;
    var previousSnapshot = null;
    var selectedStageId = null;
    var eliminatedNoticeShown = false;
    var liveEvents = [];
    var maxLiveEvents = 6;
    var visiblePollMs = 8000;
    var hiddenPollMs = 18000;

    var $ = function (selector) {
        return document.querySelector(selector);
    };

    var setText = function (selector, value) {
        var element = $(selector);
        if (element) {
            element.textContent = value || "";
        }
    };

    var escapeHtml = function (value) {
        return String(value == null ? "" : value)
            .replace(/&/g, "&amp;")
            .replace(/</g, "&lt;")
            .replace(/>/g, "&gt;")
            .replace(/"/g, "&quot;")
            .replace(/'/g, "&#39;");
    };

    // Web Forms 的静态 WebMethod 使用 POST + JSON 调用，endpoint 形如 GameRoom.aspx/GetRoomState。
    var postJson = function (method, payload) {
        return fetch(endpoint + "/" + method, {
            method: "POST",
            credentials: "same-origin",
            headers: { "Content-Type": "application/json; charset=utf-8" },
            body: JSON.stringify(payload || {})
        })
            .then(function (response) {
                return response.text().then(function (text) {
                    if (!response.ok) {
                        throw new Error("请求失败：" + response.status + (text ? "，" + text.replace(/<[^>]+>/g, "").slice(0, 120) : ""));
                    }

                    if (!text) {
                        return {};
                    }

                    try {
                        return JSON.parse(text);
                    } catch (error) {
                        throw new Error("服务器返回格式异常：" + text.replace(/<[^>]+>/g, "").slice(0, 120));
                    }
                });
            })
            .then(function (json) {
                return json.d || json;
            });
    };

    var showFeedback = function (selector, message, isError) {
        var element = $(selector);
        if (element) {
            element.textContent = message || "";
            element.classList.toggle("feedback-error", !!isError);
            element.classList.toggle("feedback-success", !!message && !isError);
        }
    };

    var ensureHostFeedbackPanel = function () {
        var hostPanel = $("[data-host-panel]");
        if (!hostPanel || hostPanel.querySelector(".room-command-feedback")) {
            return;
        }

        var heading = hostPanel.querySelector(".section-heading");
        var feedback = document.createElement("p");
        feedback.className = "inline-note room-command-feedback";
        feedback.setAttribute("data-host-feedback", "");
        feedback.textContent = "DM 的操作会同步到当前房间。";

        if (heading && heading.parentNode) {
            heading.parentNode.insertBefore(feedback, heading.nextSibling);
        } else {
            hostPanel.insertBefore(feedback, hostPanel.firstChild);
        }
    };

    var getNowText = function () {
        return new Date().toLocaleTimeString("zh-CN", {
            hour: "2-digit",
            minute: "2-digit",
            second: "2-digit",
            hour12: false
        });
    };

    var getPollInterval = function () {
        return document.hidden ? hiddenPollMs : visiblePollMs;
    };

    // 房间动态提示只保留最近几条变化，避免轮询频繁时页面不断增高。
    var renderLiveEvents = function () {
        var container = $("[data-live-updates]");
        if (!container) {
            return;
        }

        if (!liveEvents.length) {
            container.innerHTML = "<p class=\"inline-note\">阶段推进、线索解锁、投票变化和房间消息会在这里提示。</p>";
            return;
        }

        container.innerHTML = liveEvents.map(function (item) {
            return "<article class=\"room-live-event " + escapeHtml(item.level) + "\">"
                + "<div><span class=\"room-live-event-tag\">" + escapeHtml(item.tag) + "</span><p>" + escapeHtml(item.text) + "</p></div>"
                + "<span>" + escapeHtml(item.timeText) + "</span>"
                + "</article>";
        }).join("");
    };

    var pushLiveEvent = function (tag, text, level) {
        if (!text) {
            return;
        }

        liveEvents.unshift({
            tag: tag || "同步",
            text: text,
            level: level || "normal",
            timeText: getNowText()
        });
        liveEvents = liveEvents.slice(0, maxLiveEvents);
        renderLiveEvents();
    };

    var setLiveSyncStatus = function (message) {
        var intervalSeconds = Math.round(getPollInterval() / 1000);
        setText("[data-live-sync-status]", (message || "房间动态同步中") + " · " + intervalSeconds + " 秒轮询");
    };

    var fillSelect = function (select, items, getValue, getText, placeholder) {
        if (!select) {
            return;
        }

        var selected = select.value;
        select.innerHTML = "";
        if (placeholder) {
            var emptyOption = document.createElement("option");
            emptyOption.value = "";
            emptyOption.textContent = placeholder;
            select.appendChild(emptyOption);
        }

        items.forEach(function (item) {
            var option = document.createElement("option");
            option.value = getValue(item);
            option.textContent = getText(item);
            select.appendChild(option);
        });

        if ([].some.call(select.options, function (option) { return option.value === selected; })) {
            select.value = selected;
        }
    };

    var renderCards = function (container, html, emptyText) {
        if (!container) {
            return;
        }

        container.innerHTML = html || "<p class=\"inline-note\">" + escapeHtml(emptyText || "暂无数据。") + "</p>";
    };

    var getHostClueSearchText = function () {
        var input = $("[data-host-clue-search]");
        return input ? input.value.trim().toLowerCase() : "";
    };

    var getHostClueMediaHtml = function (item) {
        if (!item || !item.assetUrl) {
            return "";
        }

        var type = (item.assetType || "").toLowerCase();
        var url = escapeHtml(item.assetUrl);
        if (type === "audio") {
            return "<audio class=\"host-clue-audio\" controls src=\"" + url + "\"></audio>";
        }
        if (type === "image") {
            return "<img class=\"host-clue-image\" src=\"" + url + "\" alt=\"" + escapeHtml(item.title || "线索图片") + "\" />";
        }
        if (type === "video") {
            return "<video class=\"host-clue-video\" controls src=\"" + url + "\"></video>";
        }

        return "<a class=\"text-link strong\" href=\"" + url + "\" target=\"_blank\" rel=\"noopener\">打开本地资料</a>";
    };

    var renderHostCluePreview = function (items) {
        var preview = $("[data-host-clue-preview]");
        var select = $("[data-host-clue]");
        if (!preview || !select) {
            return;
        }

        var selectedId = select.value;
        var selected = (items || []).filter(function (item) {
            return String(item.id) === String(selectedId);
        })[0];

        if (!selected) {
            preview.innerHTML = "<p class=\"inline-note\">请选择一条待发线索。</p>";
            return;
        }

        var meta = [
            selected.stageName,
            selected.clueType,
            selected.releaseStatus,
            selected.sourceLabel,
            selected.isPublic ? "公共" : "私密",
            selected.fileName
        ].filter(Boolean).map(function (text) {
            return "<span>" + escapeHtml(text) + "</span>";
        }).join("");

        preview.innerHTML = "<div class=\"host-clue-preview-head\">"
            + "<span class=\"clue-badge\">" + escapeHtml(selected.assetType || selected.clueType || "线索") + "</span>"
            + "<strong>" + escapeHtml(selected.title || "未命名线索") + "</strong>"
            + "</div>"
            + "<p>" + escapeHtml(selected.summary || "暂无摘要。") + "</p>"
            + "<p class=\"about-text\">" + escapeHtml(selected.detail || "暂无详情。") + "</p>"
            + (meta ? "<div class=\"clue-meta\">" + meta + "</div>" : "")
            + getHostClueMediaHtml(selected);
    };

    var renderHostClueSelect = function (items) {
        var query = getHostClueSearchText();
        var filteredItems = (items || []).filter(function (item) {
            if (!query) {
                return true;
            }

            return [
                item.title,
                item.stageName,
                item.summary,
                item.detail,
                item.clueType,
                item.assetType,
                item.fileName,
                item.sourceLabel
            ].join(" ").toLowerCase().indexOf(query) >= 0;
        });

        fillSelect($("[data-host-clue]"), filteredItems, function (item) {
            return item.id;
        }, function (item) {
            return item.stageName + " / " + item.title + " / " + (item.releaseStatus || "可发放");
        }, filteredItems.length ? "请选择剧本线索" : "当前剧本没有线索");

        renderHostCluePreview(filteredItems);
    };

    var camelize = function (value) {
        if (!value || typeof value !== "object") {
            return value;
        }

        if (Array.isArray(value)) {
            return value.map(camelize);
        }

        var result = {};
        Object.keys(value).forEach(function (key) {
            var camelKey = key.charAt(0).toLowerCase() + key.slice(1);
            result[camelKey] = camelize(value[key]);
        });
        return result;
    };

    // 把服务端状态压缩成快照，下一次轮询时用于判断阶段、线索、消息和投票是否发生变化。
    var createSnapshot = function (payload) {
        payload = camelize(payload);
        var game = payload && payload.game ? payload.game : {};
        var lifecycle = game.lifecycle || {};
        var stage = game.currentStage || {};
        var clues = game.clues || [];
        var actionLogs = game.actionLogs || [];
        var messages = payload && payload.messages ? payload.messages : [];

        return {
            stageId: stage.id || 0,
            stageName: stage.stageName || "",
            stageUpdatedAtText: stage.updatedAtText || "",
            clueIds: clues.map(function (item) { return item.id; }),
            actionLogIds: actionLogs.map(function (item) { return item.id; }),
            messageIds: messages.map(function (item) { return item.id; }),
            voteCount: lifecycle.voteCount || 0,
            readyCount: lifecycle.readyCount || 0,
            eliminatedCount: lifecycle.eliminatedCount || 0,
            canSeeTruth: !!game.canSeeTruth,
            isGameEnded: !!lifecycle.isGameEnded
        };
    };

    var announceChanges = function (payload) {
        var snapshot = createSnapshot(payload);
        var game = payload.game || {};
        var lifecycle = game.lifecycle || {};
        var messages = payload.messages || [];

        if (!previousSnapshot) {
            previousSnapshot = snapshot;
            setLiveSyncStatus("已接入房间实时动态，最近同步 " + getNowText());
            renderLiveEvents();
            return;
        }

        if (snapshot.stageId && snapshot.stageId !== previousSnapshot.stageId) {
            pushLiveEvent("阶段", "剧情已切换到《" + (snapshot.stageName || "新阶段") + "》。", "important");
        } else if (snapshot.stageUpdatedAtText && snapshot.stageUpdatedAtText !== previousSnapshot.stageUpdatedAtText) {
            pushLiveEvent("同步", "当前阶段信息已更新，请留意房间提示。", "normal");
        }

        if (snapshot.clueIds.length > previousSnapshot.clueIds.length) {
            var previousClueMap = {};
            previousSnapshot.clueIds.forEach(function (id) { previousClueMap[id] = true; });
            var newClues = (game.clues || []).filter(function (item) {
                return !previousClueMap[item.id];
            }).slice(0, 2);
            var clueText = newClues.length
                ? "新增线索：" + newClues.map(function (item) { return "《" + item.title + "》"; }).join("、")
                : "有新的线索已经解锁。";
            pushLiveEvent("线索", clueText, "important");
        }

        if (snapshot.voteCount > previousSnapshot.voteCount) {
            pushLiveEvent("投票", "终局投票新增 " + (snapshot.voteCount - previousSnapshot.voteCount) + " 票，当前共 " + snapshot.voteCount + " 票。", "normal");
        }

        if (snapshot.readyCount > previousSnapshot.readyCount && !snapshot.isGameEnded) {
            pushLiveEvent("就位", "有玩家已完成就位，当前 " + snapshot.readyCount + " / " + (lifecycle.totalAssignments || 0) + " 已准备。", "normal");
        }

        if (snapshot.eliminatedCount > previousSnapshot.eliminatedCount && !snapshot.isGameEnded) {
            pushLiveEvent("出局", "本轮投票已有玩家出局，出局玩家将进入观战状态。", "important");
        }

        if (snapshot.messageIds.length > previousSnapshot.messageIds.length) {
            var previousMessageMap = {};
            previousSnapshot.messageIds.forEach(function (id) { previousMessageMap[id] = true; });
            var newMessages = messages.filter(function (item) {
                return !previousMessageMap[item.id];
            });
            var textMessages = newMessages.filter(function (item) { return item.messageType !== "Voice"; }).length;
            var voiceMessages = newMessages.filter(function (item) { return item.messageType === "Voice"; }).length;
            if (textMessages > 0 || voiceMessages > 0) {
                var parts = [];
                if (textMessages > 0) {
                    parts.push(textMessages + " 条新消息");
                }
                if (voiceMessages > 0) {
                    parts.push(voiceMessages + " 条语音");
                }
                pushLiveEvent("房间", "房间新增 " + parts.join("，") + "。", "normal");
            }
        }

        if (snapshot.actionLogIds.length > previousSnapshot.actionLogIds.length) {
            pushLiveEvent("记录", "房间行动记录已更新。", "normal");
        }

        if (snapshot.canSeeTruth && !previousSnapshot.canSeeTruth) {
            pushLiveEvent("结案", "结案信息已开放，可以查看真凶与复盘。", "important");
        }

        previousSnapshot = snapshot;
        setLiveSyncStatus("最近同步 " + getNowText());
    };

    var renderState = function (payload) {
        payload = camelize(payload);
        if (!payload || !payload.success) {
            showFeedback("[data-game-feedback]", payload && payload.message ? payload.message : "房间状态读取失败。", true);
            setLiveSyncStatus("同步失败，等待下次重试");
            return;
        }

        if (payload.reservationId && payload.reservationId !== reservationId) {
            reservationId = payload.reservationId;
            roomRoot.setAttribute("data-reservation-id", reservationId);
        }

        announceChanges(payload);
        state = payload;
        var game = payload.game || {};
        var lifecycle = game.lifecycle || {};
        var currentStage = game.currentStage || {};
        var assignment = game.currentAssignment || {};
        var canManageRoom = !!game.canManageRoom;
        var canSeeTruth = !!game.canSeeTruth;
        var isCurrentPlayerEliminated = !!assignment.isEliminated && !lifecycle.isGameEnded;

        if (isCurrentPlayerEliminated && !eliminatedNoticeShown) {
            eliminatedNoticeShown = true;
            window.alert("你已被投票出局，可以继续观战。本局结束前不能继续发言、行动或投票；结案后可以参与复盘讨论。");
        }

        var hostPanel = $("[data-host-panel]");
        if (hostPanel) {
            hostPanel.hidden = !canManageRoom;
        }
        var dmLink = $("[data-side-dm-link]");
        if (dmLink) {
            dmLink.hidden = !canManageRoom;
        }

        var stages = game.stages || [];
        var selectedStage = currentStage;
        if (selectedStageId) {
            var matchedStage = stages.filter(function (stage) {
                return stage.id === selectedStageId;
            })[0];
            if (matchedStage) {
                selectedStage = matchedStage;
            }
        }

        setText("[data-current-stage-order]", selectedStage.sortOrder ? "第 " + selectedStage.sortOrder + " 阶段" : "等待阶段");
        setText("[data-current-stage-name]", selectedStage.stageName || "尚未初始化阶段");
        setText("[data-current-stage-description]", selectedStage.stageDescription || "等待 DM 初始化房间阶段。");
        setText("[data-current-stage-updated]", selectedStage.id === currentStage.id
            ? (currentStage.updatedAtText ? "当前房间阶段 · 更新时间：" + currentStage.updatedAtText : "当前房间阶段")
            : "正在查看阶段说明，房间当前仍在《" + (currentStage.stageName || "未开始") + "》。");
        setText("[data-resume-summary]", lifecycle.resumeSummary || "房间状态会自动刷新。");
        setText("[data-side-stage]", currentStage.stageName || "阶段同步中");
        setText("[data-side-ready]", "就位 " + (lifecycle.readyCount || 0) + "/" + (lifecycle.totalAssignments || 0));
        setText("[data-side-vote]", "投票 " + (lifecycle.voteCount || 0) + "/" + (lifecycle.totalAssignments || 0));

        var readyButton = $("[data-toggle-ready]");
        if (readyButton) {
            readyButton.textContent = assignment.isReady ? "取消就位" : "标记我已就位";
            readyButton.disabled = !!lifecycle.isGameEnded || isCurrentPlayerEliminated;
        }
        var sideReadyButton = $("[data-side-ready-toggle]");
        if (sideReadyButton) {
            sideReadyButton.disabled = !!lifecycle.isGameEnded || isCurrentPlayerEliminated;
        }

        var hostStartButton = $("[data-host-start-game]");
        if (hostStartButton) {
            if (lifecycle.isGameEnded) {
                hostStartButton.textContent = "已完成结算";
                hostStartButton.disabled = true;
                hostStartButton.title = "当前房间已经完成结算，不能再次开局。";
            } else if (lifecycle.isGameStarted) {
                hostStartButton.textContent = "已正式开局";
                hostStartButton.disabled = true;
                hostStartButton.title = "本局已经开局，请使用推进阶段、开启终局投票或完成结算。";
            } else if (!lifecycle.everyoneReady) {
                hostStartButton.textContent = "等待玩家就位";
                hostStartButton.disabled = true;
                hostStartButton.title = "所有玩家标记就位后才能正式开局。";
            } else {
                hostStartButton.textContent = "正式开局";
                hostStartButton.disabled = false;
                hostStartButton.title = "所有玩家已就位，可以正式开局。";
            }
        }

        var actionButton = $("[data-submit-action]");
        if (actionButton) {
            actionButton.disabled = !lifecycle.canSubmitAction || isCurrentPlayerEliminated;
        }

        var voteButton = $("[data-submit-vote]");
        if (voteButton) {
            voteButton.disabled = !game.canVote || isCurrentPlayerEliminated;
        }
        var chatInput = $("[data-room-input]");
        var chatButton = $("[data-send-message]");
        var recordButton = $("[data-record-voice]");
        if (chatInput) {
            chatInput.disabled = isCurrentPlayerEliminated;
            chatInput.placeholder = isCurrentPlayerEliminated ? "你已出局，结案前只能观战。" : "输入房间消息";
        }
        if (chatButton) {
            chatButton.disabled = isCurrentPlayerEliminated;
        }
        if (recordButton) {
            recordButton.disabled = isCurrentPlayerEliminated;
        }
        if (!game.canVote && !game.currentVote) {
            setText("[data-vote-feedback]", isCurrentPlayerEliminated
                ? "你已被投票出局，本局结束前只能观战，不能继续投票。"
                : (lifecycle.isGameEnded
                    ? "当前房间已经完成结算，不能再提交终局投票。"
                    : "终局投票未开放：当前还在《" + (currentStage.stageName || "未开始") + "》阶段，请等待 DM 开启终局投票。"));
        } else if (game.canVote && !game.currentVote) {
            setText("[data-vote-feedback]", "终局投票已开放，请选择你认定的真凶并提交理由。");
        }

        var timerText = "未开启";
        if (lifecycle.stageTimerStartedAtText && lifecycle.stageTimerDurationMinutes) {
            var start = new Date(lifecycle.stageTimerStartedAtText.replace(" ", "T"));
            var end = new Date(start.getTime() + lifecycle.stageTimerDurationMinutes * 60000);
            var remaining = Math.max(0, Math.ceil((end.getTime() - Date.now()) / 60000));
            timerText = remaining > 0 ? "剩余约 " + remaining + " 分钟" : "已到时";
        }

        var voteStatusUrl = "VoteStatus.aspx?reservationId=" + encodeURIComponent(reservationId || "");
        var lifecycleHtml = [
            { label: "状态", value: lifecycle.statusText || "等待同步" },
            { label: "就位", value: (lifecycle.readyCount || 0) + " / " + (lifecycle.totalAssignments || 0) },
            { label: "投票", value: (lifecycle.voteCount || 0) + " / " + (lifecycle.totalAssignments || 0), href: voteStatusUrl },
            { label: "阶段计时", value: timerText }
        ].map(function (item) {
            var tagName = item.href ? "a" : "article";
            var href = item.href ? " href=\"" + escapeHtml(item.href) + "\" data-room-nav-link" : "";
            return "<" + tagName + " class=\"status-chip-card\"" + href + "><span>" + escapeHtml(item.label) + "</span><strong>" + escapeHtml(item.value) + "</strong></" + tagName + ">";
        }).join("");
        renderCards($("[data-lifecycle-summary]"), lifecycleHtml);
        renderCards($("[data-host-lifecycle]"), lifecycleHtml);

        var stageHtml = stages.map(function (stage) {
            var isSelected = selectedStage && stage.id === selectedStage.id;
            return "<button type=\"button\" class=\"timeline-card stage-timeline-card"
                + (stage.isCurrent ? " current" : "")
                + (isSelected ? " selected" : "")
                + "\" data-view-stage-id=\"" + escapeHtml(stage.id) + "\">"
                + "<span class=\"timeline-tag\">" + escapeHtml(stage.statusText || "") + "</span>"
                + "<strong class=\"stage-step-label\">第 " + escapeHtml(stage.sortOrder || "") + " 阶段</strong>"
                + "<h3>" + escapeHtml(stage.stageName) + "</h3>"
                + "<p>" + escapeHtml(stage.stageDescription) + "</p>"
                + "<p class=\"about-text\">建议时长：" + escapeHtml(stage.durationMinutes) + " 分钟</p>"
                + "</button>";
        }).join("");
        renderCards($("[data-stage-timeline]"), stageHtml, "暂无阶段。");

        var assignmentHtml = assignment.characterName
            ? "<span class=\"stage-badge\">" + (assignment.isEliminated ? "已出局" : (assignment.isReady ? "已就位" : "待就位")) + "</span>"
                + "<h3>" + escapeHtml(assignment.characterName) + "</h3>"
                + (assignment.isEliminated ? "<p class=\"inline-note\">你已进入观战状态，结案前不能继续发言、行动或投票。</p>" : "")
                + "<p class=\"about-text\">" + escapeHtml(assignment.characterDescription || "暂无角色描述。") + "</p>"
                + "<div class=\"sheet-grid\">"
                + "<span>玩家：" + escapeHtml(assignment.playerName) + "</span>"
                + "<span>人数：" + escapeHtml(assignment.playerCount || 1) + " 人</span>"
                + "<span>性别：" + escapeHtml(assignment.gender || "未标注") + "</span>"
                + "<span>职业：" + escapeHtml(assignment.profession || "未标注") + "</span>"
                + "</div>"
                + "<div class=\"sheet-secret\"><strong>私密信息</strong><p>" + escapeHtml(assignment.secretLine || "暂无私密信息。") + "</p></div>"
            : "<p class=\"inline-note\">当前预约还没有分配角色。</p>";
        renderCards($("[data-current-assignment]"), assignmentHtml);

        var rosterHtml = (game.assignments || []).map(function (item) {
            return "<article class=\"roster-card" + (item.isReady ? " ready" : "") + (item.isEliminated ? " eliminated" : "") + "\">"
                + "<span class=\"stage-badge\">" + (item.isEliminated ? "已出局" : (item.isReady ? "已就位" : "未就位")) + "</span>"
                + "<h3>" + escapeHtml(item.characterName) + "</h3>"
                + "<p>" + escapeHtml(item.playerName) + "</p>"
                + "<p class=\"about-text\">" + escapeHtml(item.profession || "未标注") + " / " + escapeHtml(item.personality || "未标注") + "</p>"
                + "</article>";
        }).join("");
        renderCards($("[data-character-roster]"), rosterHtml, "暂无角色分配。");

        var clueHtml = (game.clues || []).map(function (item) {
            return "<article class=\"clue-card " + (item.isPublic ? "public" : "private") + "\">"
                + "<span class=\"clue-badge\">" + (item.isPublic ? "公共线索" : "私密线索") + "</span>"
                + "<h3>" + escapeHtml(item.title) + "</h3>"
                + "<p>" + escapeHtml(item.summary) + "</p>"
                + "<p class=\"about-text\">" + escapeHtml(item.detail) + "</p>"
                + "<div class=\"clue-meta\"><span>" + escapeHtml(item.stageName) + "</span><span>" + escapeHtml(item.clueType) + "</span><span>" + escapeHtml(item.revealMethod) + "</span><span>" + escapeHtml(item.revealedAtText) + "</span></div>"
                + getHostClueMediaHtml(item)
                + "</article>";
        }).join("");
        renderCards($("[data-clue-board]"), clueHtml, "当前还没有解锁线索。");

        var logHtml = (game.actionLogs || []).map(function (item) {
            return "<article class=\"chat-bubble\"><strong>" + escapeHtml(item.playerName) + " / " + escapeHtml(item.actionTitle) + "</strong>"
                + "<span>" + escapeHtml(item.createdAtText) + " / " + escapeHtml(item.actionType) + "</span>"
                + "<p>" + escapeHtml(item.actionContent) + "</p></article>";
        }).join("");
        renderCards($("[data-action-logs]"), logHtml, "暂无行动记录。");

        var activeAssignments = (game.assignments || []).filter(function (item) {
            return !item.isEliminated;
        });
        fillSelect($("[data-vote-select]"), activeAssignments, function (item) {
            return item.characterId;
        }, function (item) {
            return item.characterName + "（" + item.playerName + "）";
        }, game.canVote ? "请选择你认定的真凶" : "请先进入终局阶段");

        if (game.currentVote && game.currentVote.suspectCharacterId) {
            var voteSelect = $("[data-vote-select]");
            if (voteSelect) {
                voteSelect.value = String(game.currentVote.suspectCharacterId);
            }
            setText("[data-vote-feedback]", "你已投给《" + game.currentVote.suspectCharacterName + "》。可在结算前重新提交。");
        }

        var voteHtml = (game.voteSummary || []).map(function (item) {
            return "<article class=\"vote-card" + (item.isCorrect ? " correct" : "") + "\">"
                + "<span class=\"vote-count\">" + escapeHtml(item.voteCount) + " 票</span>"
                + "<h3>" + escapeHtml(item.suspectCharacterName) + "</h3>"
                + "<p>" + (canSeeTruth && item.isCorrect ? "系统设定真凶" : "可被指认角色") + "</p>"
                + "</article>";
        }).join("");
        renderCards($("[data-vote-summary]"), voteHtml, "当前还没有投票。");

        var endingHtml = canSeeTruth
            ? "<span class=\"stage-badge\">结案信息</span><h3>真凶角色：" + escapeHtml(game.correctCharacterName || "DM 尚未设置") + "</h3><p class=\"about-text\">" + escapeHtml(game.truthSummary || "当前剧本尚未录入真相摘要，请 DM 在上方结案设置中补充。") + "</p>"
            : "<p class=\"inline-note\">终局结算前隐藏真凶和真相摘要，避免提前剧透。</p>";
        renderCards($("[data-ending-summary]"), endingHtml);

        var participantHtml = (payload.participants || []).map(function (item) {
            var snapshot = item.videoSnapshot
                ? "<img class=\"participant-snapshot\" src=\"" + escapeHtml(item.videoSnapshot) + "\" alt=\"玩家画面\" />"
                : "<div class=\"participant-snapshot placeholder\">未同步画面</div>";
            return "<article class=\"participant-card\">" + snapshot
                + "<h3>" + escapeHtml(item.displayName || item.contactName) + "</h3>"
                + "<p>" + escapeHtml(item.status) + " / " + escapeHtml(item.playerCount) + " 人</p>"
                + "<p class=\"about-text\">摄像头：" + (item.cameraEnabled ? "开" : "关") + " / 麦克风：" + (item.microphoneEnabled ? "开" : "关") + " / " + escapeHtml(item.updatedAtText) + "</p>"
                + "</article>";
        }).join("");
        renderCards($("[data-room-participants]"), participantHtml, "暂无同房玩家。");

        var textMessageHtml = (payload.messages || []).filter(function (item) {
            return item.messageType !== "Voice";
        }).map(function (item) {
            return "<article class=\"chat-bubble\"><strong>" + escapeHtml(item.senderName) + "</strong><span>" + escapeHtml(item.sentAtText) + "</span><p>" + escapeHtml(item.content) + "</p></article>";
        }).join("");
        renderCards($("[data-room-messages]"), textMessageHtml, "暂无房间消息。");

        var voiceHtml = (payload.messages || []).filter(function (item) {
            return item.messageType === "Voice";
        }).map(function (item) {
            return "<article class=\"voice-card\"><strong>" + escapeHtml(item.senderName) + " / " + escapeHtml(item.sentAtText) + "</strong><audio controls src=\"" + escapeHtml(item.mediaData) + "\"></audio></article>";
        }).join("");
        renderCards($("[data-voice-messages]"), voiceHtml, "暂无语音留言。");

        if (canManageRoom) {
            renderHostClueSelect(game.pendingClues || []);

            fillSelect($("[data-host-target]"), game.assignments || [], function (item) {
                return item.reservationId;
            }, function (item) {
                return item.playerName + " - " + item.characterName;
            }, "公共线索发给所有人");

            fillSelect($("[data-host-stage]"), game.stages || [], function (item) {
                return item.id;
            }, function (item) {
                return item.stageName;
            }, "请选择阶段");

            if (currentStage.id) {
                var stageSelect = $("[data-host-stage]");
                if (stageSelect) {
                    stageSelect.value = String(currentStage.id);
                }
            }

            fillSelect($("[data-host-truth-character]"), game.assignments || [], function (item) {
                return item.characterId;
            }, function (item) {
                return item.characterName + "（" + item.playerName + "）";
            }, "请选择真凶角色");

            var truthSelect = $("[data-host-truth-character]");
            if (truthSelect && game.correctCharacterName) {
                [].some.call(truthSelect.options, function (option) {
                    if (option.textContent.indexOf(game.correctCharacterName) === 0) {
                        truthSelect.value = option.value;
                        return true;
                    }
                    return false;
                });
            }

            var truthInput = $("[data-host-truth-summary]");
            if (truthInput && !truthInput.value && game.truthSummary) {
                truthInput.value = game.truthSummary;
            }

            var notesInput = $("[data-host-dm-notes]");
            if (notesInput && !notesInput.value && lifecycle.dmNotes) {
                notesInput.value = lifecycle.dmNotes;
            }

            var timerInput = $("[data-host-timer-minutes]");
            if (timerInput && currentStage.durationMinutes && timerInput.value === "20") {
                timerInput.value = currentStage.durationMinutes;
            }
        }
    };

    var scheduleRefresh = function (delay) {
        if (refreshTimerId) {
            window.clearTimeout(refreshTimerId);
        }

        refreshTimerId = window.setTimeout(function () {
            refreshRoom();
        }, typeof delay === "number" ? delay : getPollInterval());
    };

    var refreshRoom = function () {
        if (refreshInFlight) {
            return Promise.resolve();
        }

        refreshInFlight = true;
        setLiveSyncStatus("正在同步房间动态");
        return postJson("GetRoomState", { reservationId: reservationId }).then(function (result) {
            renderState(result);
            return result;
        }).catch(function (error) {
            showFeedback("[data-room-feedback]", error.message);
            setLiveSyncStatus("同步失败：" + error.message);
        }).then(function (result) {
            refreshInFlight = false;
            scheduleRefresh();
            return result;
        });
    };

    var bindClick = function (selector, handler) {
        var element = $(selector);
        if (element) {
            element.addEventListener("click", handler);
        }
    };

    document.addEventListener("click", function (event) {
        var stageButton = event.target.closest("[data-view-stage-id]");
        if (!stageButton) {
            return;
        }

        selectedStageId = parseInt(stageButton.getAttribute("data-view-stage-id"), 10) || null;
        if (state) {
            renderState(state);
        }
    });

    var runCommand = function (method, payload, feedbackSelector) {
        var selector = feedbackSelector || "[data-game-feedback]";
        showFeedback(selector, "正在执行操作，请稍候...");
        return postJson(method, payload).then(function (result) {
            var success = !!(result && result.success);
            showFeedback(selector, (result && result.message) || (success ? "操作已完成。" : "操作失败。"), !success);

            if (!success) {
                return result;
            }

            return refreshRoom().then(function () {
                showFeedback(selector, result.message || "操作已完成。");
                return result;
            });
        }).catch(function (error) {
            showFeedback(selector, error.message, true);
        });
    };

    var roomModules = Array.prototype.slice.call(document.querySelectorAll(
        "[data-host-panel], .gameplay-panel, #room-participant-panel, #room-media-panel, #room-chat-panel"
    ));
    var getRoomModuleTitle = function (module, index) {
        var heading = module.querySelector("h2, h3");
        var title = heading ? heading.textContent.replace(/\s+/g, " ").trim() : "";
        return title || "游戏模块 " + (index + 1);
    };
    var setRoomModuleCollapsed = function (module, collapsed, persist) {
        var title = module.getAttribute("data-room-module-title") || "游戏模块";
        var button = module.querySelector("[data-room-collapse-toggle]");
        var key = module.getAttribute("data-room-collapse-key");
        module.classList.toggle("room-module-collapsed", collapsed);
        if (button) {
            button.textContent = collapsed ? "展开" : "收起";
            button.setAttribute("aria-expanded", collapsed ? "false" : "true");
            button.setAttribute("title", (collapsed ? "展开 " : "收起 ") + title);
        }
        if (persist && key) {
            try {
                window.localStorage.setItem(key, collapsed ? "1" : "0");
            } catch (error) {
                // 本地存储不可用时，仅保持当前页面状态。
            }
        }
    };
    roomModules.forEach(function (module, index) {
        var title = getRoomModuleTitle(module, index);
        var key = "dramamurder-room-collapse:" + window.location.pathname + ":" + (module.id || index);
        var button = document.createElement("button");
        button.type = "button";
        button.className = "room-module-collapse-toggle";
        button.setAttribute("data-room-collapse-toggle", "");
        button.setAttribute("aria-label", "折叠或展开 " + title);
        module.classList.add("room-collapsible-module");
        module.setAttribute("data-room-module-title", title);
        module.setAttribute("data-room-collapse-key", key);
        module.appendChild(button);

        var collapsed = false;
        try {
            collapsed = window.localStorage.getItem(key) === "1";
        } catch (error) {
            collapsed = false;
        }
        setRoomModuleCollapsed(module, collapsed, false);

        button.addEventListener("click", function (event) {
            event.preventDefault();
            event.stopPropagation();
            var nextCollapsed = !module.classList.contains("room-module-collapsed");
            setRoomModuleCollapsed(module, nextCollapsed, true);
        });
    });

    bindClick("[data-toggle-ready]", function () {
        var isReady = !(state && state.game && state.game.currentAssignment && state.game.currentAssignment.isReady);
        runCommand("ToggleReady", { reservationId: reservationId, isReady: isReady }, "[data-game-feedback]");
    });

    bindClick("[data-side-ready-toggle]", function () {
        var isReady = !(state && state.game && state.game.currentAssignment && state.game.currentAssignment.isReady);
        runCommand("ToggleReady", { reservationId: reservationId, isReady: isReady }, "[data-game-feedback]");
    });

    bindClick("[data-side-refresh]", function () {
        setLiveSyncStatus("正在手动同步房间动态");
        refreshRoom();
    });

    bindClick("[data-collapse-room-modules]", function () {
        roomModules.forEach(function (module) {
            setRoomModuleCollapsed(module, true, true);
        });
    });

    bindClick("[data-expand-room-modules]", function () {
        roomModules.forEach(function (module) {
            setRoomModuleCollapsed(module, false, true);
        });
    });

    bindClick("[data-submit-action]", function () {
        runCommand("SubmitAction", {
            reservationId: reservationId,
            title: ($("[data-action-title]") || {}).value || "",
            content: ($("[data-action-content]") || {}).value || ""
        }, "[data-game-feedback]").then(function () {
            var title = $("[data-action-title]");
            var content = $("[data-action-content]");
            if (title) title.value = "";
            if (content) content.value = "";
        });
    });

    bindClick("[data-submit-vote]", function () {
        var select = $("[data-vote-select]");
        runCommand("SubmitVote", {
            reservationId: reservationId,
            suspectCharacterId: select && select.value ? parseInt(select.value, 10) : 0,
            comment: ($("[data-vote-comment]") || {}).value || ""
        }, "[data-vote-feedback]");
    });

    bindClick("[data-host-start-game]", function () {
        if (state && state.game && state.game.lifecycle) {
            var lifecycle = state.game.lifecycle;
            if (lifecycle.isGameEnded) {
                showFeedback("[data-host-feedback]", "当前房间已经完成结算，不能再次开局。");
                return;
            }
            if (lifecycle.isGameStarted) {
                showFeedback("[data-host-feedback]", "本局已经正式开局，请使用“推进下一阶段”继续控场。");
                return;
            }
            if (!lifecycle.everyoneReady) {
                showFeedback("[data-host-feedback]", "还有玩家未就位，请所有玩家准备完成后再开局。");
                return;
            }
        }

        runCommand("StartGame", { reservationId: reservationId }, "[data-host-feedback]");
    });

    bindClick("[data-advance-stage]", function () {
        runCommand("AdvanceStage", { reservationId: reservationId }, "[data-host-feedback]");
    });

    bindClick("[data-host-open-vote]", function () {
        var stages = state && state.game && state.game.stages ? state.game.stages : [];
        var endingStage = stages.filter(function (stage) {
            return stage.stageKey === "ending" || stage.stageName === "终局复盘" || stage.stageName === "终局投票";
        })[0];
        if (!endingStage || !endingStage.id) {
            showFeedback("[data-host-feedback]", "未找到终局阶段，请先确认剧本阶段配置。");
            return;
        }

        runCommand("SetStage", {
            reservationId: reservationId,
            stageId: endingStage.id
        }, "[data-host-feedback]");
    });

    bindClick("[data-host-finish-game]", function () {
        runCommand("FinishGame", { reservationId: reservationId }, "[data-host-feedback]");
    });

    bindClick("[data-host-broadcast]", function () {
        var noticeInput = $("[data-host-notice]");
        runCommand("BroadcastNotice", {
            reservationId: reservationId,
            content: noticeInput ? noticeInput.value : ""
        }, "[data-host-feedback]").then(function (result) {
            if (result && result.success && noticeInput) {
                noticeInput.value = "";
            }
        });
    });

    bindClick("[data-host-reveal]", function () {
        var clueSelect = $("[data-host-clue]");
        var targetSelect = $("[data-host-target]");
        runCommand("RevealClue", {
            reservationId: reservationId,
            clueId: clueSelect && clueSelect.value ? parseInt(clueSelect.value, 10) : 0,
            targetReservationId: targetSelect && targetSelect.value ? parseInt(targetSelect.value, 10) : null
        }, "[data-host-feedback]");
    });

    var hostClueSelect = $("[data-host-clue]");
    if (hostClueSelect) {
        hostClueSelect.addEventListener("change", function () {
            renderHostCluePreview(state && state.game ? state.game.pendingClues || [] : []);
        });
    }

    var hostClueSearch = $("[data-host-clue-search]");
    if (hostClueSearch) {
        hostClueSearch.addEventListener("input", function () {
            renderHostClueSelect(state && state.game ? state.game.pendingClues || [] : []);
        });
    }

    bindClick("[data-host-set-stage]", function () {
        var stageSelect = $("[data-host-stage]");
        runCommand("SetStage", {
            reservationId: reservationId,
            stageId: stageSelect && stageSelect.value ? parseInt(stageSelect.value, 10) : 0
        }, "[data-host-feedback]");
    });

    bindClick("[data-host-save-truth]", function () {
        var characterSelect = $("[data-host-truth-character]");
        runCommand("SaveTruth", {
            reservationId: reservationId,
            characterId: characterSelect && characterSelect.value ? parseInt(characterSelect.value, 10) : 0,
            truthSummary: ($("[data-host-truth-summary]") || {}).value || ""
        }, "[data-host-feedback]");
    });

    bindClick("[data-host-save-notes]", function () {
        runCommand("SaveDmNotes", {
            reservationId: reservationId,
            notes: ($("[data-host-dm-notes]") || {}).value || ""
        }, "[data-host-feedback]");
    });

    bindClick("[data-host-start-timer]", function () {
        var input = $("[data-host-timer-minutes]");
        runCommand("StartTimer", {
            reservationId: reservationId,
            durationMinutes: input && input.value ? parseInt(input.value, 10) : 20
        }, "[data-host-feedback]");
    });

    bindClick("[data-send-message]", function () {
        var input = $("[data-room-input]");
        runCommand("SendTextMessage", {
            reservationId: reservationId,
            content: input ? input.value : ""
        }, "[data-room-feedback]").then(function () {
            if (input) input.value = "";
        });
    });

    bindClick("[data-refresh-room]", function () {
        setLiveSyncStatus("正在手动同步房间动态");
        refreshRoom();
    });

    var captureSnapshot = function () {
        var video = $("[data-local-video]");
        if (!video || !video.videoWidth) {
            return "";
        }

        var canvas = document.createElement("canvas");
        canvas.width = 320;
        canvas.height = Math.round(320 * video.videoHeight / video.videoWidth);
        canvas.getContext("2d").drawImage(video, 0, 0, canvas.width, canvas.height);
        return canvas.toDataURL("image/jpeg", 0.68);
    };

    bindClick("[data-enable-media]", function () {
        if (!navigator.mediaDevices || !navigator.mediaDevices.getUserMedia) {
            showFeedback("[data-media-status]", "当前浏览器不支持摄像头/麦克风调用。");
            return;
        }

        navigator.mediaDevices.getUserMedia({ video: true, audio: true }).then(function (stream) {
            localStream = stream;
            var video = $("[data-local-video]");
            if (video) {
                video.srcObject = stream;
            }
            var placeholder = $("[data-video-placeholder]");
            if (placeholder) {
                placeholder.hidden = true;
            }
            showFeedback("[data-media-status]", "摄像头和麦克风已启用。");
            return postJson("UpdatePresence", {
                reservationId: reservationId,
                cameraEnabled: true,
                microphoneEnabled: true,
                snapshotDataUrl: ""
            });
        }).then(refreshRoom).catch(function (error) {
            showFeedback("[data-media-status]", "无法启用媒体设备：" + error.message);
        });
    });

    bindClick("[data-sync-snapshot]", function () {
        postJson("UpdatePresence", {
            reservationId: reservationId,
            cameraEnabled: !!localStream,
            microphoneEnabled: !!localStream,
            snapshotDataUrl: captureSnapshot()
        }).then(function () {
            showFeedback("[data-media-status]", "画面已同步。");
            return refreshRoom();
        }).catch(function (error) {
            showFeedback("[data-media-status]", error.message);
        });
    });

    bindClick("[data-record-voice]", function () {
        if (!localStream || typeof MediaRecorder === "undefined") {
            showFeedback("[data-media-status]", "请先启用麦克风后再录音。");
            return;
        }

        recordedChunks = [];
        mediaRecorder = new MediaRecorder(localStream);
        mediaRecorder.ondataavailable = function (event) {
            if (event.data && event.data.size) {
                recordedChunks.push(event.data);
            }
        };
        mediaRecorder.onstop = function () {
            var blob = new Blob(recordedChunks, { type: "audio/webm" });
            var reader = new FileReader();
            reader.onload = function () {
                postJson("SendVoiceMessage", {
                    reservationId: reservationId,
                    audioDataUrl: reader.result,
                    durationSeconds: 0
                }).then(function (result) {
                    showFeedback("[data-media-status]", result.message || "语音已发送。");
                    return refreshRoom();
                }).catch(function (error) {
                    showFeedback("[data-media-status]", error.message);
                });
            };
            reader.readAsDataURL(blob);
        };
        mediaRecorder.start();
        var start = $("[data-record-voice]");
        var stop = $("[data-stop-voice]");
        if (start) start.disabled = true;
        if (stop) stop.disabled = false;
        showFeedback("[data-media-status]", "正在录音...");
    });

    bindClick("[data-stop-voice]", function () {
        if (mediaRecorder && mediaRecorder.state !== "inactive") {
            mediaRecorder.stop();
        }
        var start = $("[data-record-voice]");
        var stop = $("[data-stop-voice]");
        if (start) start.disabled = false;
        if (stop) stop.disabled = true;
    });

    document.addEventListener("visibilitychange", function () {
        if (!document.hidden) {
            refreshRoom();
        } else {
            setLiveSyncStatus("页面暂不在前台，已切换为低频同步");
            scheduleRefresh();
        }
    });

    window.addEventListener("focus", function () {
        refreshRoom();
    });

    ensureHostFeedbackPanel();
    refreshRoom();
})();
