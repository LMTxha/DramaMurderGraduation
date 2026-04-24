using System;

namespace DramaMurderGraduation.Web.Models
{
    public class WalletTransactionInfo
    {
        public int Id { get; set; }
        public int UserId { get; set; }
        public string Username { get; set; }
        public string UserDisplayName { get; set; }
        public string TransactionType { get; set; }
        public decimal Amount { get; set; }
        public decimal BalanceBefore { get; set; }
        public decimal BalanceAfter { get; set; }
        public string Summary { get; set; }
        public bool IsAnomaly { get; set; }
        public string AuditNote { get; set; }
        public DateTime CreatedAt { get; set; }
    }
}
