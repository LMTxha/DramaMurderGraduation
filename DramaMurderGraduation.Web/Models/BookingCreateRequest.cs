namespace DramaMurderGraduation.Web.Models
{
    public class BookingCreateRequest
    {
        public int UserId { get; set; }
        public int SessionId { get; set; }
        public string ContactName { get; set; }
        public string Phone { get; set; }
        public int PlayerCount { get; set; }
        public string Remark { get; set; }
    }
}
