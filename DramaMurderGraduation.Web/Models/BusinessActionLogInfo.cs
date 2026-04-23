using System;

namespace DramaMurderGraduation.Web.Models
{
    public class BusinessActionLogInfo
    {
        public int Id { get; set; }
        public string BusinessType { get; set; }
        public int BusinessId { get; set; }
        public string ActionType { get; set; }
        public string ActionTitle { get; set; }
        public string ActionContent { get; set; }
        public int? OperatorUserId { get; set; }
        public string OperatorName { get; set; }
        public DateTime CreatedAt { get; set; }
    }
}
