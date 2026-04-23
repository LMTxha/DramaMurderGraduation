using System;

namespace DramaMurderGraduation.Web.Models
{
    public class GiftWalletTransactionInfo
    {
        public int Id { get; set; }
        public string TransactionType { get; set; }
        public int CoinAmount { get; set; }
        public int BalanceAfter { get; set; }
        public string Summary { get; set; }
        public DateTime CreatedAt { get; set; }
    }
}
