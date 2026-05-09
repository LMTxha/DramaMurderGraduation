using System.Collections.Generic;

namespace DramaMurderGraduation.Web.Models
{
    /// <summary>
    /// 游戏房间页面一次渲染所需的完整状态快照。
    /// GameRepository 会把阶段、角色分配、线索、投票、行动日志和结算信息组装到这个模型里。
    /// </summary>
    public class GameRoomStateInfo
    {
        /// <summary>当前进行到的游戏阶段。</summary>
        public GameStageInfo CurrentStage { get; set; }

        /// <summary>根据当前阶段和玩家身份计算出的操作开关。</summary>
        public GameSessionLifecycleInfo Lifecycle { get; set; }

        /// <summary>完整阶段时间线，页面用于显示进度条。</summary>
        public IList<GameStageInfo> Stages { get; set; }

        /// <summary>当前登录玩家在本场游戏中的角色分配。</summary>
        public GameAssignmentInfo CurrentAssignment { get; set; }

        /// <summary>本场游戏全部玩家的角色分配，DM 视图会使用。</summary>
        public IList<GameAssignmentInfo> Assignments { get; set; }

        /// <summary>当前玩家可见的线索列表。</summary>
        public IList<GameClueInfo> Clues { get; set; }

        /// <summary>房间行动日志，用于展示系统消息、玩家操作和 DM 广播。</summary>
        public IList<GameActionLogInfo> ActionLogs { get; set; }

        /// <summary>当前玩家已提交的投票。</summary>
        public GamePlayerVoteInfo CurrentVote { get; set; }

        /// <summary>全场投票汇总。</summary>
        public IList<GameVoteSummaryInfo> VoteSummary { get; set; }

        /// <summary>当前玩家此刻是否可以提交投票。</summary>
        public bool CanVote { get; set; }

        /// <summary>当前用户是否具备房间管理权限。</summary>
        public bool CanManageRoom { get; set; }

        /// <summary>正确嫌疑人/真凶角色名，结算后展示。</summary>
        public string CorrectCharacterName { get; set; }

        /// <summary>案件真相说明，结算后展示。</summary>
        public string TruthSummary { get; set; }

        /// <summary>DM 尚可发放的线索选项。</summary>
        public IList<GameHostClueOptionInfo> PendingClues { get; set; }
    }
}
