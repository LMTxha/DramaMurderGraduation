using System;

namespace DramaMurderGraduation.Web.Models
{
    public class WalletTransactionInfo
    {
        public int Id { get; set; }
        public string TransactionType { get; set; }
        public decimal Amount { get; set; }
        public decimal BalanceAfter { get; set; }
        public string Summary { get; set; }
        public DateTime CreatedAt { get; set; }
    }
}
