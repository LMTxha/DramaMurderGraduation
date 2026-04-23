namespace DramaMurderGraduation.Web.Models
{
    public class GameAssignmentInfo
    {
        public int ReservationId { get; set; }
        public int? UserId { get; set; }
        public string PlayerName { get; set; }
        public string ContactName { get; set; }
        public int PlayerCount { get; set; }
        public int CharacterId { get; set; }
        public string CharacterName { get; set; }
        public string Gender { get; set; }
        public string AgeRange { get; set; }
        public string Profession { get; set; }
        public string Personality { get; set; }
        public string CharacterDescription { get; set; }
        public string SecretLine { get; set; }
        public bool IsReady { get; set; }
    }
}
