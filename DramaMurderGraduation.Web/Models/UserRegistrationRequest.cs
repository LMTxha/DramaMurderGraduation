namespace DramaMurderGraduation.Web.Models
{
    public class UserRegistrationRequest
    {
        public string Username { get; set; }
        public string Password { get; set; }
        public string DisplayName { get; set; }
        public string Email { get; set; }
        public string Phone { get; set; }
    }
}
