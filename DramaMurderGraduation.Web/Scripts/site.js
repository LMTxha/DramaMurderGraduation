(function () {
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

    document.querySelectorAll("[data-recommendation-carousel]").forEach(function (carousel) {
        var items = Array.prototype.slice.call(carousel.querySelectorAll("[data-carousel-item]"));
        var dotsHost = carousel.querySelector("[data-carousel-dots]");
        var prevButton = carousel.querySelector("[data-carousel-prev]");
        var nextButton = carousel.querySelector("[data-carousel-next]");
        var intervalMs = parseInt(carousel.getAttribute("data-interval"), 10) || 20000;
        var activeIndex = 0;
        var timer = null;
        var dots = [];

        if (items.length <= 1) {
            carousel.classList.add("single-item");
            return;
        }

        var getVisibleCount = function () {
            return window.matchMedia("(max-width: 760px)").matches ? 1 : 2;
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

    var postJson = function (method, payload) {
        return fetch(endpoint + "/" + method, {
            method: "POST",
            credentials: "same-origin",
            headers: { "Content-Type": "application/json; charset=utf-8" },
            body: JSON.stringify(payload || {})
        })
            .then(function (response) {
                if (!response.ok) {
                    throw new Error("请求失败：" + response.status);
                }
                return response.json();
            })
            .then(function (json) {
                return json.d || json;
            });
    };

    var showFeedback = function (selector, message) {
        setText(selector, message);
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

    var renderState = function (payload) {
        payload = camelize(payload);
        if (!payload || !payload.success) {
            showFeedback("[data-game-feedback]", payload && payload.message ? payload.message : "房间状态读取失败。");
            return;
        }

        state = payload;
        var game = payload.game || {};
        var lifecycle = game.lifecycle || {};
        var currentStage = game.currentStage || {};
        var assignment = game.currentAssignment || {};
        var canManageRoom = !!game.canManageRoom;
        var canSeeTruth = !!game.canSeeTruth;

        var hostPanel = $("[data-host-panel]");
        if (hostPanel) {
            hostPanel.hidden = !canManageRoom;
        }

        setText("[data-current-stage-order]", currentStage.sortOrder ? "第 " + currentStage.sortOrder + " 阶段" : "等待阶段");
        setText("[data-current-stage-name]", currentStage.stageName || "尚未初始化阶段");
        setText("[data-current-stage-description]", currentStage.stageDescription || "等待 DM 初始化房间阶段。");
        setText("[data-current-stage-updated]", currentStage.updatedAtText ? "更新时间：" + currentStage.updatedAtText : "");
        setText("[data-resume-summary]", lifecycle.resumeSummary || "房间状态会自动刷新。");

        var readyButton = $("[data-toggle-ready]");
        if (readyButton) {
            readyButton.textContent = assignment.isReady ? "取消就位" : "标记我已就位";
            readyButton.disabled = !!lifecycle.isGameEnded;
        }

        var actionButton = $("[data-submit-action]");
        if (actionButton) {
            actionButton.disabled = !lifecycle.canSubmitAction;
        }

        var voteButton = $("[data-submit-vote]");
        if (voteButton) {
            voteButton.disabled = !game.canVote;
        }

        var timerText = "未开启";
        if (lifecycle.stageTimerStartedAtText && lifecycle.stageTimerDurationMinutes) {
            var start = new Date(lifecycle.stageTimerStartedAtText.replace(" ", "T"));
            var end = new Date(start.getTime() + lifecycle.stageTimerDurationMinutes * 60000);
            var remaining = Math.max(0, Math.ceil((end.getTime() - Date.now()) / 60000));
            timerText = remaining > 0 ? "剩余约 " + remaining + " 分钟" : "已到时";
        }

        var lifecycleHtml = [
            ["状态", lifecycle.statusText || "等待同步"],
            ["就位", (lifecycle.readyCount || 0) + " / " + (lifecycle.totalAssignments || 0)],
            ["投票", (lifecycle.voteCount || 0) + " / " + (lifecycle.totalAssignments || 0)],
            ["阶段计时", timerText]
        ].map(function (item) {
            return "<article class=\"status-chip-card\"><span>" + escapeHtml(item[0]) + "</span><strong>" + escapeHtml(item[1]) + "</strong></article>";
        }).join("");
        renderCards($("[data-lifecycle-summary]"), lifecycleHtml);
        renderCards($("[data-host-lifecycle]"), lifecycleHtml);

        var stageHtml = (game.stages || []).map(function (stage) {
            return "<article class=\"timeline-card" + (stage.isCurrent ? " current" : "") + "\">"
                + "<span class=\"timeline-tag\">" + escapeHtml(stage.statusText || "") + "</span>"
                + "<h3>" + escapeHtml(stage.stageName) + "</h3>"
                + "<p>" + escapeHtml(stage.stageDescription) + "</p>"
                + "<p class=\"about-text\">建议时长：" + escapeHtml(stage.durationMinutes) + " 分钟</p>"
                + "</article>";
        }).join("");
        renderCards($("[data-stage-timeline]"), stageHtml, "暂无阶段。");

        var assignmentHtml = assignment.characterName
            ? "<span class=\"stage-badge\">" + (assignment.isReady ? "已就位" : "待就位") + "</span>"
                + "<h3>" + escapeHtml(assignment.characterName) + "</h3>"
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
            return "<article class=\"roster-card" + (item.isReady ? " ready" : "") + "\">"
                + "<span class=\"stage-badge\">" + (item.isReady ? "已就位" : "未就位") + "</span>"
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
                + "</article>";
        }).join("");
        renderCards($("[data-clue-board]"), clueHtml, "当前还没有解锁线索。");

        var logHtml = (game.actionLogs || []).map(function (item) {
            return "<article class=\"chat-bubble\"><strong>" + escapeHtml(item.playerName) + " / " + escapeHtml(item.actionTitle) + "</strong>"
                + "<span>" + escapeHtml(item.createdAtText) + " / " + escapeHtml(item.actionType) + "</span>"
                + "<p>" + escapeHtml(item.actionContent) + "</p></article>";
        }).join("");
        renderCards($("[data-action-logs]"), logHtml, "暂无行动记录。");

        fillSelect($("[data-vote-select]"), game.assignments || [], function (item) {
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
            fillSelect($("[data-host-clue]"), game.pendingClues || [], function (item) {
                return item.id;
            }, function (item) {
                return item.stageName + " / " + item.title + " / " + (item.isPublic ? "公共" : "私密");
            }, "请选择待发线索");

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

    var refreshRoom = function () {
        return postJson("GetRoomState", { reservationId: reservationId }).then(renderState).catch(function (error) {
            showFeedback("[data-room-feedback]", error.message);
        });
    };

    var bindClick = function (selector, handler) {
        var element = $(selector);
        if (element) {
            element.addEventListener("click", handler);
        }
    };

    var runCommand = function (method, payload, feedbackSelector) {
        return postJson(method, payload).then(function (result) {
            showFeedback(feedbackSelector || "[data-game-feedback]", result.message || (result.success ? "操作已完成。" : "操作失败。"));
            return refreshRoom();
        }).catch(function (error) {
            showFeedback(feedbackSelector || "[data-game-feedback]", error.message);
        });
    };

    bindClick("[data-toggle-ready]", function () {
        var isReady = !(state && state.game && state.game.currentAssignment && state.game.currentAssignment.isReady);
        runCommand("ToggleReady", { reservationId: reservationId, isReady: isReady }, "[data-game-feedback]");
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
        runCommand("StartGame", { reservationId: reservationId }, "[data-host-feedback]");
    });

    bindClick("[data-advance-stage]", function () {
        runCommand("AdvanceStage", { reservationId: reservationId }, "[data-host-feedback]");
    });

    bindClick("[data-host-finish-game]", function () {
        runCommand("FinishGame", { reservationId: reservationId }, "[data-host-feedback]");
    });

    bindClick("[data-host-broadcast]", function () {
        runCommand("BroadcastNotice", {
            reservationId: reservationId,
            content: ($("[data-host-notice]") || {}).value || ""
        }, "[data-host-feedback]");
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

    refreshRoom();
    window.setInterval(refreshRoom, 8000);
})();
