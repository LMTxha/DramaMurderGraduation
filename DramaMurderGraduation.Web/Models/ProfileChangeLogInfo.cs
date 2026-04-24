using System;

namespace DramaMurderGraduation.Web.Models
{
    public class ProfileChangeLogInfo
    {
        public int Id { get; set; }
        public int UserId { get; set; }
        public string FieldName { get; set; }
        public string BeforeValue { get; set; }
        public string AfterValue { get; set; }
        public DateTime ChangedAt { get; set; }
    }
}
