using System;

namespace DramaMurderGraduation.Web.Models
{
    /// <summary>
    /// PlayerBattleRecordInfo 数据模型，用于在页面层和仓储层之间传递剧本杀业务数据。
    /// </summary>
    public class PlayerBattleRecordInfo
    {
        /// <summary>业务主键标识。</summary>
        public int Id { get; set; }
        /// <summary>页面或业务逻辑使用的数据字段。</summary>
        public int SessionId { get; set; }
        /// <summary>页面或业务逻辑使用的数据字段。</summary>
        public int ReservationId { get; set; }
        /// <summary>页面或业务逻辑使用的数据字段。</summary>
        public string ScriptName { get; set; }
        /// <summary>页面或业务逻辑使用的数据字段。</summary>
        public string RoomName { get; set; }
        /// <summary>页面或业务逻辑使用的数据字段。</summary>
        public string CharacterName { get; set; }
        /// <summary>页面或业务逻辑使用的数据字段。</summary>
        public bool WasCorrect { get; set; }
        /// <summary>页面或业务逻辑使用的数据字段。</summary>
        public string ResultTag { get; set; }
        /// <summary>页面或业务逻辑使用的数据字段。</summary>
        public string VotedCharacterName { get; set; }
        /// <summary>页面或业务逻辑使用的数据字段。</summary>
        public string CorrectCharacterName { get; set; }
        /// <summary>对应业务动作的发生时间。</summary>
        public DateTime CompletedAt { get; set; }
    }
}
