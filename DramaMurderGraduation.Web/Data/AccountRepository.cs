using System;
using System.Collections.Generic;
using System.Data.SqlClient;
using DramaMurderGraduation.Web.Models;

namespace DramaMurderGraduation.Web.Data
{
    public class AccountRepository
    {
        public bool Register(UserRegistrationRequest request, out string message)
        {
            const string sql = @"
IF EXISTS (SELECT 1 FROM dbo.Users WHERE Username = @Username)
BEGIN
    RAISERROR(N'用户名已存在，请更换后再试。', 16, 1);
    RETURN;
END

INSERT INTO dbo.Users
(
    Username,
    PasswordHash,
    DisplayName,
    Email,
    Phone,
    RoleCode,
    ReviewStatus,
    CreatedAt
)
VALUES
(
    @Username,
    @PasswordHash,
    @DisplayName,
    @Email,
    @Phone,
    N'Player',
    N'Pending',
    GETDATE()
);";

            using (var connection = DbHelper.CreateConnection())
            using (var command = new SqlCommand(sql, connection))
            {
                command.Parameters.AddWithValue("@Username", request.Username);
                command.Parameters.AddWithValue("@PasswordHash", AuthManager.HashPassword(request.Password));
                command.Parameters.AddWithValue("@DisplayName", request.DisplayName);
                command.Parameters.AddWithValue("@Email", request.Email);
                command.Parameters.AddWithValue("@Phone", request.Phone);

                connection.Open();
                try
                {
                    command.ExecuteNonQuery();
                    message = "注册成功，账号已提交管理员审核。";
                    return true;
                }
                catch (SqlException ex)
                {
                    message = ex.Message;
                    return false;
                }
            }
        }

        public UserAccountInfo Authenticate(string username, string password, out string message)
        {
            const string sql = @"
SELECT TOP 1
    Id,
    Username,
    DisplayName,
    PublicUserCode,
    Email,
    Phone,
    Balance,
    RoleCode,
    ReviewStatus,
    ReviewRemark,
    CreatedAt,
    ReviewedAt
FROM dbo.Users
WHERE Username = @Username
  AND PasswordHash = @PasswordHash;";

            using (var connection = DbHelper.CreateConnection())
            using (var command = new SqlCommand(sql, connection))
            {
                command.Parameters.AddWithValue("@Username", username);
                command.Parameters.AddWithValue("@PasswordHash", AuthManager.HashPassword(password));
                connection.Open();

                using (var reader = command.ExecuteReader())
                {
                    if (!reader.Read())
                    {
                        message = "用户名或密码不正确。";
                        return null;
                    }

                    var user = MapUser(reader);

                    if (user.ReviewStatus == "Pending")
                    {
                        message = "账号还在等待管理员审核，请稍后再登录。";
                        return null;
                    }

                    if (user.ReviewStatus == "Rejected")
                    {
                        message = string.IsNullOrWhiteSpace(user.ReviewRemark)
                            ? "账号审核未通过，请联系管理员。"
                            : "账号审核未通过：" + user.ReviewRemark;
                        return null;
                    }

                    message = "登录成功。";
                    return user;
                }
            }
        }

        public IList<UserAccountInfo> GetPendingUsers()
        {
            const string sql = @"
SELECT
    Id,
    Username,
    DisplayName,
    PublicUserCode,
    Email,
    Phone,
    Balance,
    RoleCode,
    ReviewStatus,
    ReviewRemark,
    CreatedAt,
    ReviewedAt
FROM dbo.Users
WHERE ReviewStatus = N'Pending'
ORDER BY CreatedAt ASC, Id ASC;";

            var results = new List<UserAccountInfo>();
            using (var connection = DbHelper.CreateConnection())
            using (var command = new SqlCommand(sql, connection))
            {
                connection.Open();
                using (var reader = command.ExecuteReader())
                {
                    while (reader.Read())
                    {
                        results.Add(MapUser(reader));
                    }
                }
            }

            return results;
        }

        public bool ReviewUser(int userId, bool approved, string remark, out string message)
        {
            const string sql = @"
UPDATE dbo.Users
SET ReviewStatus = @ReviewStatus,
    ReviewRemark = @ReviewRemark,
    ReviewedAt = GETDATE()
WHERE Id = @UserId;";

            using (var connection = DbHelper.CreateConnection())
            using (var command = new SqlCommand(sql, connection))
            {
                command.Parameters.AddWithValue("@ReviewStatus", approved ? "Approved" : "Rejected");
                command.Parameters.AddWithValue("@ReviewRemark", (object)remark ?? DBNull.Value);
                command.Parameters.AddWithValue("@UserId", userId);

                connection.Open();
                var affectedRows = command.ExecuteNonQuery();
                message = affectedRows > 0 ? "用户审核已处理。" : "未找到对应用户。";
                return affectedRows > 0;
            }
        }

        public UserAccountInfo GetUserById(int userId)
        {
            const string sql = @"
SELECT TOP 1
    Id,
    Username,
    DisplayName,
    PublicUserCode,
    Email,
    Phone,
    Balance,
    RoleCode,
    ReviewStatus,
    ReviewRemark,
    CreatedAt,
    ReviewedAt
FROM dbo.Users
WHERE Id = @UserId;";

            using (var connection = DbHelper.CreateConnection())
            using (var command = new SqlCommand(sql, connection))
            {
                command.Parameters.AddWithValue("@UserId", userId);
                connection.Open();

                using (var reader = command.ExecuteReader())
                {
                    return reader.Read() ? MapUser(reader) : null;
                }
            }
        }

        public UserSettingsInfo GetUserSettings(int userId)
        {
            const string sql = @"
SELECT TOP 1
    u.Id AS UserId,
    u.Username,
    u.DisplayName,
    ISNULL(u.PublicUserCode, N'') AS PublicUserCode,
    u.Phone,
    u.Email,
    ISNULL(pp.AvatarUrl, N'') AS AvatarUrl,
    ISNULL(pp.FavoriteGenre, N'') AS FavoriteGenre
FROM dbo.Users u
LEFT JOIN dbo.PlayerProfiles pp ON pp.UserId = u.Id
WHERE u.Id = @UserId;";

            using (var connection = DbHelper.CreateConnection())
            using (var command = new SqlCommand(sql, connection))
            {
                command.Parameters.AddWithValue("@UserId", userId);
                connection.Open();
                using (var reader = command.ExecuteReader())
                {
                    if (!reader.Read())
                    {
                        return null;
                    }

                    return new UserSettingsInfo
                    {
                        UserId = Convert.ToInt32(reader["UserId"]),
                        Username = Convert.ToString(reader["Username"]),
                        DisplayName = Convert.ToString(reader["DisplayName"]),
                        PublicUserCode = Convert.ToString(reader["PublicUserCode"]),
                        Phone = Convert.ToString(reader["Phone"]),
                        Email = Convert.ToString(reader["Email"]),
                        AvatarUrl = Convert.ToString(reader["AvatarUrl"]),
                        FavoriteGenre = Convert.ToString(reader["FavoriteGenre"])
                    };
                }
            }
        }

        public bool UpdateUserSettings(int userId, string displayName, string phone, string avatarUrl, string publicUserCode, out string message)
        {
            var normalizedCode = NormalizePublicUserCode(publicUserCode);
            if (!IsValidPublicUserCode(normalizedCode))
            {
                message = "账号 ID 需为 4 到 20 位，只能包含字母、数字或下划线。";
                return false;
            }

            if (string.IsNullOrWhiteSpace(displayName))
            {
                message = "昵称不能为空。";
                return false;
            }

            if (string.IsNullOrWhiteSpace(phone))
            {
                message = "手机号不能为空。";
                return false;
            }

            const string sql = @"
IF EXISTS (SELECT 1 FROM dbo.Users WHERE PublicUserCode = @PublicUserCode AND Id <> @UserId)
BEGIN
    RAISERROR(N'这个账号 ID 已经被其他玩家使用，请换一个。', 16, 1);
    RETURN;
END

UPDATE dbo.Users
SET DisplayName = @DisplayName,
    Phone = @Phone,
    PublicUserCode = @PublicUserCode
WHERE Id = @UserId;

IF @@ROWCOUNT = 0
BEGIN
    RAISERROR(N'未找到当前账号，无法保存设置。', 16, 1);
    RETURN;
END

IF EXISTS (SELECT 1 FROM dbo.PlayerProfiles WHERE UserId = @UserId)
BEGIN
    UPDATE dbo.PlayerProfiles
    SET DisplayName = @DisplayName,
        AvatarUrl = @AvatarUrl
    WHERE UserId = @UserId;
END
ELSE
BEGIN
    INSERT INTO dbo.PlayerProfiles
    (
        UserId,
        DisplayName,
        DisplayTitle,
        Motto,
        AvatarUrl,
        FavoriteGenre,
        JoinDays,
        CompletedScripts,
        WinRate,
        ReputationLevel
    )
    VALUES
    (
        @UserId,
        @DisplayName,
        N'互动玩家',
        N'在这里整理自己的社交名片与开本身份。',
        @AvatarUrl,
        N'本格推理',
        30,
        0,
        0,
        N'新秀玩家'
    );
END;";

            using (var connection = DbHelper.CreateConnection())
            using (var command = new SqlCommand(sql, connection))
            {
                command.Parameters.AddWithValue("@UserId", userId);
                command.Parameters.AddWithValue("@DisplayName", displayName.Trim());
                command.Parameters.AddWithValue("@Phone", phone.Trim());
                command.Parameters.AddWithValue("@AvatarUrl", string.IsNullOrWhiteSpace(avatarUrl) ? (object)DBNull.Value : avatarUrl.Trim());
                command.Parameters.AddWithValue("@PublicUserCode", normalizedCode);
                connection.Open();
                try
                {
                    command.ExecuteNonQuery();
                    message = "设置已保存，新的头像、手机号和账号 ID 已同步更新。";
                    return true;
                }
                catch (SqlException ex)
                {
                    message = ex.Message;
                    return false;
                }
            }
        }

        public bool ChangePassword(int userId, string currentPassword, string newPassword, out string message)
        {
            if (string.IsNullOrWhiteSpace(currentPassword) || string.IsNullOrWhiteSpace(newPassword))
            {
                message = "请输入当前密码和新密码。";
                return false;
            }

            if (newPassword.Length < 6)
            {
                message = "新密码至少需要 6 位。";
                return false;
            }

            const string sql = @"
UPDATE dbo.Users
SET PasswordHash = @NewPasswordHash
WHERE Id = @UserId
  AND PasswordHash = @CurrentPasswordHash;

IF @@ROWCOUNT = 0
BEGIN
    RAISERROR(N'当前密码不正确，请重新输入。', 16, 1);
    RETURN;
END";

            using (var connection = DbHelper.CreateConnection())
            using (var command = new SqlCommand(sql, connection))
            {
                command.Parameters.AddWithValue("@UserId", userId);
                command.Parameters.AddWithValue("@CurrentPasswordHash", AuthManager.HashPassword(currentPassword));
                command.Parameters.AddWithValue("@NewPasswordHash", AuthManager.HashPassword(newPassword));
                connection.Open();
                try
                {
                    command.ExecuteNonQuery();
                    message = "密码已更新，下次登录请使用新密码。";
                    return true;
                }
                catch (SqlException ex)
                {
                    message = ex.Message;
                    return false;
                }
            }
        }

        public bool SubmitRechargeRequest(int userId, string paymentMethod, decimal amount, string paymentAccount, out string message)
        {
            const string sql = @"
DECLARE @BalanceAfter DECIMAL(10,2);
DECLARE @WalletTransactionId INT;

IF @PaymentMethod = N'BankCard'
BEGIN
    INSERT INTO dbo.RechargeRequests
    (
        UserId,
        PaymentMethod,
        Amount,
        PaymentAccount,
        RequestStatus,
        ReviewRemark,
        WalletTransactionId,
        SubmittedAt,
        ReviewedAt,
        ReviewedByUserId
    )
    VALUES
    (
        @UserId,
        @PaymentMethod,
        @Amount,
        @PaymentAccount,
        N'Pending',
        NULL,
        NULL,
        GETDATE(),
        NULL,
        NULL
    );

    RETURN;
END

UPDATE dbo.Users
SET Balance = Balance + @Amount
WHERE Id = @UserId
  AND ReviewStatus = N'Approved';

IF @@ROWCOUNT = 0
BEGIN
    RAISERROR(N'当前账号不可充值，请重新登录后再试。', 16, 1);
    RETURN;
END

SELECT @BalanceAfter = Balance
FROM dbo.Users
WHERE Id = @UserId;

INSERT INTO dbo.WalletTransactions(UserId, TransactionType, Amount, BalanceAfter, Summary, CreatedAt)
VALUES(@UserId, N'充值', @Amount, @BalanceAfter, @Summary, GETDATE());

SET @WalletTransactionId = SCOPE_IDENTITY();

INSERT INTO dbo.RechargeRequests
(
    UserId,
    PaymentMethod,
    Amount,
    PaymentAccount,
    RequestStatus,
    ReviewRemark,
    WalletTransactionId,
    SubmittedAt,
    ReviewedAt,
    ReviewedByUserId
)
VALUES
(
    @UserId,
    @PaymentMethod,
    @Amount,
    @PaymentAccount,
    N'Approved',
    N'系统自动到账',
    @WalletTransactionId,
    GETDATE(),
    GETDATE(),
    NULL
);";

            using (var connection = DbHelper.CreateConnection())
            using (var command = new SqlCommand(sql, connection))
            {
                command.Parameters.AddWithValue("@UserId", userId);
                command.Parameters.AddWithValue("@Amount", amount);
                command.Parameters.AddWithValue("@PaymentMethod", paymentMethod);
                command.Parameters.AddWithValue("@PaymentAccount", string.IsNullOrWhiteSpace(paymentAccount) ? (object)DBNull.Value : paymentAccount);
                command.Parameters.AddWithValue("@Summary", paymentMethod == "ScanCode" ? "扫码支付充值成功" : "微信支付充值成功");
                connection.Open();

                using (var transaction = connection.BeginTransaction())
                {
                    command.Transaction = transaction;
                    try
                    {
                        command.ExecuteNonQuery();

                        #if false
                        using (var incomeCommand = new SqlCommand(@"
DECLARE @GiftTotalCoins INT;
DECLARE @ReceiverBalanceAfter INT;

SELECT @GiftTotalCoins = PriceInCoins * @Quantity
FROM dbo.GiftCatalog
WHERE Id = @GiftId;

SELECT @ReceiverBalanceAfter = GiftBalance
FROM dbo.Users
WHERE Id = @ReceiverUserId;

INSERT INTO dbo.GiftWalletTransactions(UserId, TransactionType, CoinAmount, BalanceAfter, Summary, CreatedAt)
VALUES(@ReceiverUserId, N'收到礼物', @GiftTotalCoins, @ReceiverBalanceAfter, @Summary, GETDATE());", connection, transaction))
                        {
                            incomeCommand.Parameters.AddWithValue("@ReceiverUserId", receiverUserId);
                            incomeCommand.Parameters.AddWithValue("@GiftId", giftId);
                            incomeCommand.Parameters.AddWithValue("@Quantity", quantity);
                            incomeCommand.Parameters.AddWithValue("@Summary", "礼物收入");
                            incomeCommand.ExecuteNonQuery();
                        }
                        #endif

                        transaction.Commit();
                        message = paymentMethod == "BankCard"
                            ? "银行卡充值申请已提交，等待管理员审核后到账。"
                            : "充值成功，余额已经更新。";
                        return true;
                    }
                    catch (SqlException ex)
                    {
                        transaction.Rollback();
                        message = ex.Message;
                        return false;
                    }
                }
            }
        }

        public IList<RechargeRequestInfo> GetRechargeRequests(int userId, int top)
        {
            const string sql = @"
SELECT TOP (@Top)
    rr.Id,
    rr.UserId,
    u.Username,
    u.DisplayName,
    rr.PaymentMethod,
    rr.Amount,
    rr.PaymentAccount,
    rr.RequestStatus,
    rr.ReviewRemark,
    rr.SubmittedAt,
    rr.ReviewedAt
FROM dbo.RechargeRequests rr
INNER JOIN dbo.Users u ON u.Id = rr.UserId
WHERE rr.UserId = @UserId
ORDER BY rr.SubmittedAt DESC, rr.Id DESC;";

            var results = new List<RechargeRequestInfo>();
            using (var connection = DbHelper.CreateConnection())
            using (var command = new SqlCommand(sql, connection))
            {
                command.Parameters.AddWithValue("@Top", top);
                command.Parameters.AddWithValue("@UserId", userId);
                connection.Open();

                using (var reader = command.ExecuteReader())
                {
                    while (reader.Read())
                    {
                        results.Add(MapRechargeRequest(reader));
                    }
                }
            }

            return results;
        }

        public IList<RechargeRequestInfo> GetPendingRechargeRequests()
        {
            const string sql = @"
SELECT
    rr.Id,
    rr.UserId,
    u.Username,
    u.DisplayName,
    rr.PaymentMethod,
    rr.Amount,
    rr.PaymentAccount,
    rr.RequestStatus,
    rr.ReviewRemark,
    rr.SubmittedAt,
    rr.ReviewedAt
FROM dbo.RechargeRequests rr
INNER JOIN dbo.Users u ON u.Id = rr.UserId
WHERE rr.RequestStatus = N'Pending'
ORDER BY rr.SubmittedAt ASC, rr.Id ASC;";

            var results = new List<RechargeRequestInfo>();
            using (var connection = DbHelper.CreateConnection())
            using (var command = new SqlCommand(sql, connection))
            {
                connection.Open();
                using (var reader = command.ExecuteReader())
                {
                    while (reader.Read())
                    {
                        results.Add(MapRechargeRequest(reader));
                    }
                }
            }

            return results;
        }

        public bool ReviewRechargeRequest(int requestId, bool approved, string remark, int reviewedByUserId, out string message)
        {
            const string sql = @"
DECLARE @UserId INT;
DECLARE @Amount DECIMAL(10,2);
DECLARE @RequestStatus NVARCHAR(20);
DECLARE @PaymentMethod NVARCHAR(20);
DECLARE @BalanceAfter DECIMAL(10,2);
DECLARE @WalletTransactionId INT;

SELECT
    @UserId = UserId,
    @Amount = Amount,
    @RequestStatus = RequestStatus,
    @PaymentMethod = PaymentMethod
FROM dbo.RechargeRequests WITH (UPDLOCK, HOLDLOCK)
WHERE Id = @RequestId;

IF @RequestStatus IS NULL
BEGIN
    RAISERROR(N'未找到对应充值申请。', 16, 1);
    RETURN;
END

IF @RequestStatus <> N'Pending'
BEGIN
    RAISERROR(N'该充值申请已经处理过了。', 16, 1);
    RETURN;
END

IF @PaymentMethod <> N'BankCard'
BEGIN
    RAISERROR(N'只有银行卡充值需要管理员审核。', 16, 1);
    RETURN;
END

IF @Approved = 1
BEGIN
    UPDATE dbo.Users
    SET Balance = Balance + @Amount
    WHERE Id = @UserId;

    SELECT @BalanceAfter = Balance
    FROM dbo.Users
    WHERE Id = @UserId;

    INSERT INTO dbo.WalletTransactions(UserId, TransactionType, Amount, BalanceAfter, Summary, CreatedAt)
    VALUES(@UserId, N'银行卡充值', @Amount, @BalanceAfter, N'管理员审核通过后到账', GETDATE());

    SET @WalletTransactionId = SCOPE_IDENTITY();

    UPDATE dbo.RechargeRequests
    SET RequestStatus = N'Approved',
        ReviewRemark = @ReviewRemark,
        ReviewedAt = GETDATE(),
        ReviewedByUserId = @ReviewedByUserId,
        WalletTransactionId = @WalletTransactionId
    WHERE Id = @RequestId;
END
ELSE
BEGIN
    UPDATE dbo.RechargeRequests
    SET RequestStatus = N'Rejected',
        ReviewRemark = @ReviewRemark,
        ReviewedAt = GETDATE(),
        ReviewedByUserId = @ReviewedByUserId
    WHERE Id = @RequestId;
END";

            using (var connection = DbHelper.CreateConnection())
            using (var command = new SqlCommand(sql, connection))
            {
                command.Parameters.AddWithValue("@RequestId", requestId);
                command.Parameters.AddWithValue("@Approved", approved);
                command.Parameters.AddWithValue("@ReviewedByUserId", reviewedByUserId);
                command.Parameters.AddWithValue("@ReviewRemark", string.IsNullOrWhiteSpace(remark)
                    ? (approved ? "银行卡充值审核通过" : "银行卡充值审核未通过")
                    : remark);

                connection.Open();
                using (var transaction = connection.BeginTransaction())
                {
                    command.Transaction = transaction;
                    try
                    {
                        command.ExecuteNonQuery();
                        transaction.Commit();
                        message = approved ? "充值申请已通过，余额已到账。" : "充值申请已驳回。";
                        return true;
                    }
                    catch (SqlException ex)
                    {
                        transaction.Rollback();
                        message = ex.Message;
                        return false;
                    }
                }
            }
        }

        public IList<WalletTransactionInfo> GetWalletTransactions(int userId, int top)
        {
            const string sql = @"
SELECT TOP (@Top)
    Id,
    TransactionType,
    Amount,
    BalanceAfter,
    Summary,
    CreatedAt
FROM dbo.WalletTransactions
WHERE UserId = @UserId
ORDER BY CreatedAt DESC, Id DESC;";

            var results = new List<WalletTransactionInfo>();
            using (var connection = DbHelper.CreateConnection())
            using (var command = new SqlCommand(sql, connection))
            {
                command.Parameters.AddWithValue("@Top", top);
                command.Parameters.AddWithValue("@UserId", userId);
                connection.Open();

                using (var reader = command.ExecuteReader())
                {
                    while (reader.Read())
                    {
                        results.Add(new WalletTransactionInfo
                        {
                            Id = Convert.ToInt32(reader["Id"]),
                            TransactionType = Convert.ToString(reader["TransactionType"]),
                            Amount = Convert.ToDecimal(reader["Amount"]),
                            BalanceAfter = Convert.ToDecimal(reader["BalanceAfter"]),
                            Summary = Convert.ToString(reader["Summary"]),
                            CreatedAt = Convert.ToDateTime(reader["CreatedAt"])
                        });
                    }
                }
            }

            return results;
        }

        public GiftStatsInfo GetGiftStats(int userId)
        {
            const string sql = @"
SELECT
    ISNULL(u.GiftBalance, 0) AS GiftBalance,
    ISNULL(sent.TotalGiftCountSent, 0) AS TotalGiftCountSent,
    ISNULL(received.TotalGiftCountReceived, 0) AS TotalGiftCountReceived,
    ISNULL(sent.TotalGiftCoinsSent, 0) AS TotalGiftCoinsSent,
    ISNULL(received.TotalGiftCoinsReceived, 0) AS TotalGiftCoinsReceived
FROM dbo.Users u
OUTER APPLY
(
    SELECT SUM(Quantity) AS TotalGiftCountSent, SUM(TotalCoins) AS TotalGiftCoinsSent
    FROM dbo.GiftTransactions
    WHERE SenderUserId = u.Id
) sent
OUTER APPLY
(
    SELECT SUM(Quantity) AS TotalGiftCountReceived, SUM(TotalCoins) AS TotalGiftCoinsReceived
    FROM dbo.GiftTransactions
    WHERE ReceiverUserId = u.Id
) received
WHERE u.Id = @UserId;";

            using (var connection = DbHelper.CreateConnection())
            using (var command = new SqlCommand(sql, connection))
            {
                command.Parameters.AddWithValue("@UserId", userId);
                connection.Open();

                using (var reader = command.ExecuteReader())
                {
                    if (!reader.Read())
                    {
                        return new GiftStatsInfo();
                    }

                    return new GiftStatsInfo
                    {
                        GiftBalance = Convert.ToInt32(reader["GiftBalance"]),
                        TotalGiftCountSent = Convert.ToInt32(reader["TotalGiftCountSent"]),
                        TotalGiftCountReceived = Convert.ToInt32(reader["TotalGiftCountReceived"]),
                        TotalGiftCoinsSent = Convert.ToInt32(reader["TotalGiftCoinsSent"]),
                        TotalGiftCoinsReceived = Convert.ToInt32(reader["TotalGiftCoinsReceived"])
                    };
                }
            }
        }

        public int GetUnreadFriendMessageCount(int userId)
        {
            const string sql = @"
SELECT COUNT(1)
FROM dbo.FriendMessages fm
WHERE fm.ReceiverUserId = @UserId
  AND ISNULL(IsRead, 0) = 0
  AND ISNULL(IsRevoked, 0) = 0
  AND NOT EXISTS
  (
      SELECT 1
      FROM dbo.UserBlocks b
      WHERE (b.UserId = @UserId AND b.BlockedUserId = fm.SenderUserId)
         OR (b.UserId = fm.SenderUserId AND b.BlockedUserId = @UserId)
  );";

            using (var connection = DbHelper.CreateConnection())
            using (var command = new SqlCommand(sql, connection))
            {
                command.Parameters.AddWithValue("@UserId", userId);
                connection.Open();
                return Convert.ToInt32(command.ExecuteScalar());
            }
        }

        public IList<GiftCatalogInfo> GetGiftCatalog()
        {
            const string sql = @"
SELECT Id, Name, PriceInCoins, IconText, Summary
FROM dbo.GiftCatalog
WHERE IsActive = 1
ORDER BY SortOrder ASC, Id ASC;";

            var results = new List<GiftCatalogInfo>();
            using (var connection = DbHelper.CreateConnection())
            using (var command = new SqlCommand(sql, connection))
            {
                connection.Open();
                using (var reader = command.ExecuteReader())
                {
                    while (reader.Read())
                    {
                        results.Add(new GiftCatalogInfo
                        {
                            Id = Convert.ToInt32(reader["Id"]),
                            Name = Convert.ToString(reader["Name"]),
                            PriceInCoins = Convert.ToInt32(reader["PriceInCoins"]),
                            IconText = Convert.ToString(reader["IconText"]),
                            Summary = reader["Summary"] == DBNull.Value ? string.Empty : Convert.ToString(reader["Summary"])
                        });
                    }
                }
            }

            return results;
        }

        public bool RechargeGiftBalanceFromCash(int userId, int giftCoins, out string message)
        {
            const string sql = @"
DECLARE @ChargeAmount DECIMAL(10,2) = CAST(@GiftCoins AS DECIMAL(10,2)) / 10.0;
DECLARE @CashBalance DECIMAL(10,2);
DECLARE @GiftBalanceAfter INT;

SELECT @CashBalance = Balance
FROM dbo.Users WITH (UPDLOCK, HOLDLOCK)
WHERE Id = @UserId;

IF @CashBalance IS NULL
BEGIN
    RAISERROR(N'未找到当前用户。', 16, 1);
    RETURN;
END;

IF @CashBalance < @ChargeAmount
BEGIN
    RAISERROR(N'账户余额不足，请先充值现金余额。', 16, 1);
    RETURN;
END;

UPDATE dbo.Users
SET Balance = Balance - @ChargeAmount,
    GiftBalance = ISNULL(GiftBalance, 0) + @GiftCoins
WHERE Id = @UserId;

SELECT
    @CashBalance = Balance,
    @GiftBalanceAfter = GiftBalance
FROM dbo.Users
WHERE Id = @UserId;

INSERT INTO dbo.WalletTransactions(UserId, TransactionType, Amount, BalanceAfter, Summary, CreatedAt)
VALUES(@UserId, N'礼物币兑换', @ChargeAmount, @CashBalance, N'使用现金余额兑换礼物币', GETDATE());

INSERT INTO dbo.GiftWalletTransactions(UserId, TransactionType, CoinAmount, BalanceAfter, Summary, CreatedAt)
VALUES(@UserId, N'礼物币充值', @GiftCoins, @GiftBalanceAfter, N'从现金余额兑换礼物币', GETDATE());";

            using (var connection = DbHelper.CreateConnection())
            using (var command = new SqlCommand(sql, connection))
            {
                command.Parameters.AddWithValue("@UserId", userId);
                command.Parameters.AddWithValue("@GiftCoins", giftCoins);
                connection.Open();

                using (var transaction = connection.BeginTransaction())
                {
                    command.Transaction = transaction;
                    try
                    {
                        command.ExecuteNonQuery();
                        transaction.Commit();
                        message = "礼物币充值成功，已从现金余额中完成兑换。";
                        return true;
                    }
                    catch (SqlException ex)
                    {
                        transaction.Rollback();
                        message = ex.Message;
                        return false;
                    }
                }
            }
        }

        public IList<GiftWalletTransactionInfo> GetGiftWalletTransactions(int userId, int top)
        {
            const string sql = @"
SELECT TOP (@Top)
    Id,
    TransactionType,
    CoinAmount,
    BalanceAfter,
    Summary,
    CreatedAt
FROM dbo.GiftWalletTransactions
WHERE UserId = @UserId
ORDER BY CreatedAt DESC, Id DESC;";

            var results = new List<GiftWalletTransactionInfo>();
            using (var connection = DbHelper.CreateConnection())
            using (var command = new SqlCommand(sql, connection))
            {
                command.Parameters.AddWithValue("@Top", top);
                command.Parameters.AddWithValue("@UserId", userId);
                connection.Open();
                using (var reader = command.ExecuteReader())
                {
                    while (reader.Read())
                    {
                        results.Add(new GiftWalletTransactionInfo
                        {
                            Id = Convert.ToInt32(reader["Id"]),
                            TransactionType = Convert.ToString(reader["TransactionType"]),
                            CoinAmount = Convert.ToInt32(reader["CoinAmount"]),
                            BalanceAfter = Convert.ToInt32(reader["BalanceAfter"]),
                            Summary = Convert.ToString(reader["Summary"]),
                            CreatedAt = Convert.ToDateTime(reader["CreatedAt"])
                        });
                    }
                }
            }

            return results;
        }

        public IList<GiftTransactionInfo> GetGiftSentRecords(int userId, int top)
        {
            return GetGiftTransactions(@"
SELECT TOP (@Top)
    gt.Id,
    gt.SenderUserId,
    sender.DisplayName AS SenderDisplayName,
    gt.ReceiverUserId,
    receiver.DisplayName AS ReceiverDisplayName,
    gc.Name AS GiftName,
    gc.IconText,
    gt.Quantity,
    gt.TotalCoins,
    gt.Summary,
    gt.CreatedAt
FROM dbo.GiftTransactions gt
INNER JOIN dbo.Users sender ON sender.Id = gt.SenderUserId
INNER JOIN dbo.Users receiver ON receiver.Id = gt.ReceiverUserId
INNER JOIN dbo.GiftCatalog gc ON gc.Id = gt.GiftId
WHERE gt.SenderUserId = @UserId
ORDER BY gt.CreatedAt DESC, gt.Id DESC;", userId, top);
        }

        public IList<GiftTransactionInfo> GetGiftReceivedRecords(int userId, int top)
        {
            return GetGiftTransactions(@"
SELECT TOP (@Top)
    gt.Id,
    gt.SenderUserId,
    sender.DisplayName AS SenderDisplayName,
    gt.ReceiverUserId,
    receiver.DisplayName AS ReceiverDisplayName,
    gc.Name AS GiftName,
    gc.IconText,
    gt.Quantity,
    gt.TotalCoins,
    gt.Summary,
    gt.CreatedAt
FROM dbo.GiftTransactions gt
INNER JOIN dbo.Users sender ON sender.Id = gt.SenderUserId
INNER JOIN dbo.Users receiver ON receiver.Id = gt.ReceiverUserId
INNER JOIN dbo.GiftCatalog gc ON gc.Id = gt.GiftId
WHERE gt.ReceiverUserId = @UserId
ORDER BY gt.CreatedAt DESC, gt.Id DESC;", userId, top);
        }

        public IList<UserAccountInfo> GetGiftRecipientCandidates(int userId, int top)
        {
            const string sql = @"
SELECT TOP (@Top)
    u.Id,
    u.Username,
    u.DisplayName,
    u.Email,
    u.Phone,
    u.Balance,
    u.RoleCode,
    u.ReviewStatus,
    u.ReviewRemark,
    u.CreatedAt,
    u.ReviewedAt
FROM dbo.Users u
WHERE u.Id <> @UserId
  AND u.ReviewStatus = N'Approved'
  AND NOT EXISTS
  (
      SELECT 1
      FROM dbo.UserBlocks b
      WHERE (b.UserId = @UserId AND b.BlockedUserId = u.Id)
         OR (b.UserId = u.Id AND b.BlockedUserId = @UserId)
  )
ORDER BY u.DisplayName ASC, u.Id ASC;";

            var results = new List<UserAccountInfo>();
            using (var connection = DbHelper.CreateConnection())
            using (var command = new SqlCommand(sql, connection))
            {
                command.Parameters.AddWithValue("@Top", top);
                command.Parameters.AddWithValue("@UserId", userId);
                connection.Open();
                using (var reader = command.ExecuteReader())
                {
                    while (reader.Read())
                    {
                        results.Add(MapUser(reader));
                    }
                }
            }

            return results;
        }

        public bool SendGift(int senderUserId, int receiverUserId, int giftId, int quantity, out string message)
        {
            const string sql = @"
DECLARE @GiftName NVARCHAR(50);
DECLARE @UnitPrice INT;
DECLARE @TotalCoins INT;
DECLARE @SenderGiftBalance INT;
DECLARE @SenderBalanceAfter INT;
DECLARE @ReceiverBalanceAfter INT;

  IF @SenderUserId = @ReceiverUserId
  BEGIN
      RAISERROR(N'不能给自己送礼物。', 16, 1);
      RETURN;
  END;

  IF EXISTS
  (
      SELECT 1
      FROM dbo.UserBlocks
      WHERE (UserId = @SenderUserId AND BlockedUserId = @ReceiverUserId)
         OR (UserId = @ReceiverUserId AND BlockedUserId = @SenderUserId)
  )
  BEGIN
      RAISERROR(N'当前好友关系已被限制，无法继续送礼。', 16, 1);
      RETURN;
  END;

SELECT
    @GiftName = Name,
    @UnitPrice = PriceInCoins
FROM dbo.GiftCatalog
WHERE Id = @GiftId
  AND IsActive = 1;

IF @GiftName IS NULL
BEGIN
    RAISERROR(N'未找到对应礼物。', 16, 1);
    RETURN;
END;

IF NOT EXISTS (SELECT 1 FROM dbo.Users WHERE Id = @ReceiverUserId AND ReviewStatus = N'Approved')
BEGIN
    RAISERROR(N'收礼玩家不存在或尚未通过审核。', 16, 1);
    RETURN;
END;

SET @TotalCoins = @UnitPrice * @Quantity;

SELECT @SenderGiftBalance = GiftBalance
FROM dbo.Users WITH (UPDLOCK, HOLDLOCK)
WHERE Id = @SenderUserId;

IF @SenderGiftBalance IS NULL
BEGIN
    RAISERROR(N'未找到送礼用户。', 16, 1);
    RETURN;
END;

IF @SenderGiftBalance < @TotalCoins
BEGIN
    RAISERROR(N'礼物币余额不足，请先在钱包中心充值礼物币。', 16, 1);
    RETURN;
END;

UPDATE dbo.Users
SET GiftBalance = GiftBalance - @TotalCoins
WHERE Id = @SenderUserId;

SELECT @SenderBalanceAfter = GiftBalance
FROM dbo.Users
WHERE Id = @SenderUserId;

UPDATE dbo.Users
SET GiftBalance = ISNULL(GiftBalance, 0) + @TotalCoins
WHERE Id = @ReceiverUserId;

SELECT @ReceiverBalanceAfter = GiftBalance
FROM dbo.Users
WHERE Id = @ReceiverUserId;

INSERT INTO dbo.GiftTransactions(SenderUserId, ReceiverUserId, GiftId, Quantity, UnitPrice, TotalCoins, Summary, CreatedAt)
VALUES(@SenderUserId, @ReceiverUserId, @GiftId, @Quantity, @UnitPrice, @TotalCoins, @Summary, GETDATE());

INSERT INTO dbo.GiftWalletTransactions(UserId, TransactionType, CoinAmount, BalanceAfter, Summary, CreatedAt)
VALUES(@SenderUserId, N'送出礼物', -@TotalCoins, @SenderBalanceAfter, @Summary, GETDATE());

INSERT INTO dbo.GiftWalletTransactions(UserId, TransactionType, CoinAmount, BalanceAfter, Summary, CreatedAt)
VALUES(@ReceiverUserId, N'收到礼物', @TotalCoins, @ReceiverBalanceAfter, @Summary, GETDATE());

IF OBJECT_ID('dbo.FriendMessages', 'U') IS NOT NULL
BEGIN
    INSERT INTO dbo.FriendMessages(SenderUserId, ReceiverUserId, MessageType, Content, AttachmentUrl, LocationText, CreatedAt)
    VALUES(@SenderUserId, @ReceiverUserId, N'Gift', @GiftName + N' x' + CONVERT(NVARCHAR(20), @Quantity), NULL, NULL, GETDATE());
END;";

            using (var connection = DbHelper.CreateConnection())
            using (var command = new SqlCommand(sql, connection))
            {
                command.Parameters.AddWithValue("@SenderUserId", senderUserId);
                command.Parameters.AddWithValue("@ReceiverUserId", receiverUserId);
                command.Parameters.AddWithValue("@GiftId", giftId);
                command.Parameters.AddWithValue("@Quantity", quantity);
                command.Parameters.AddWithValue("@Summary", "互动送礼");
                connection.Open();

                using (var transaction = connection.BeginTransaction())
                {
                    command.Transaction = transaction;
                    try
                    {
                        command.ExecuteNonQuery();
                        transaction.Commit();
                        message = "礼物已经送出，对方的收礼记录和你的送礼总额都已更新。";
                        return true;
                    }
                    catch (SqlException ex)
                    {
                        transaction.Rollback();
                        message = ex.Message;
                        return false;
                    }
                }
            }
        }

        public IList<FriendInfo> GetFriends(int userId)
        {
            const string sql = @"
SELECT
    f.FriendUserId AS UserId,
    u.Username,
    u.DisplayName,
    ISNULL(pp.AvatarUrl, N'') AS AvatarUrl,
    ISNULL(pp.FavoriteGenre, N'') AS FavoriteGenre,
    ISNULL(pp.ReputationLevel, N'新朋友') AS ReputationLevel,
    f.CreatedAt
FROM dbo.Friendships f
INNER JOIN dbo.Users u ON u.Id = f.FriendUserId
LEFT JOIN dbo.PlayerProfiles pp ON pp.UserId = u.Id
WHERE f.UserId = @UserId
ORDER BY f.CreatedAt DESC, f.Id DESC;";

            var results = new List<FriendInfo>();
            using (var connection = DbHelper.CreateConnection())
            using (var command = new SqlCommand(sql, connection))
            {
                command.Parameters.AddWithValue("@UserId", userId);
                connection.Open();
                using (var reader = command.ExecuteReader())
                {
                    while (reader.Read())
                    {
                        results.Add(new FriendInfo
                        {
                            UserId = Convert.ToInt32(reader["UserId"]),
                            Username = Convert.ToString(reader["Username"]),
                            DisplayName = Convert.ToString(reader["DisplayName"]),
                            AvatarUrl = Convert.ToString(reader["AvatarUrl"]),
                            FavoriteGenre = Convert.ToString(reader["FavoriteGenre"]),
                            ReputationLevel = Convert.ToString(reader["ReputationLevel"]),
                            CreatedAt = Convert.ToDateTime(reader["CreatedAt"])
                        });
                    }
                }
            }

            return results;
        }

        public IList<int> GetPinnedFriendIds(int userId)
        {
            return GetConversationPreferenceFriendIds(userId, "IsPinned");
        }

        public IList<int> GetHiddenFriendIds(int userId)
        {
            return GetConversationPreferenceFriendIds(userId, "IsHidden");
        }

        public bool SetConversationPinned(int userId, int friendUserId, bool pinned, out string message)
        {
            return SaveConversationPreference(userId, friendUserId, pinned, null, pinned ? "会话已置顶。" : "已取消置顶。", out message);
        }

        public bool SetConversationHidden(int userId, int friendUserId, bool hidden, out string message)
        {
            return SaveConversationPreference(userId, friendUserId, null, hidden, hidden ? "会话已隐藏，可在隐藏会话区恢复。" : "会话已恢复到主列表。", out message);
        }

        public bool AreFriends(int userId, int otherUserId)
        {
            const string sql = @"
SELECT COUNT(1)
FROM dbo.Friendships
WHERE UserId = @UserId
  AND FriendUserId = @OtherUserId;";

            using (var connection = DbHelper.CreateConnection())
            using (var command = new SqlCommand(sql, connection))
            {
                command.Parameters.AddWithValue("@UserId", userId);
                command.Parameters.AddWithValue("@OtherUserId", otherUserId);
                connection.Open();
                return Convert.ToInt32(command.ExecuteScalar()) > 0;
            }
        }

        public IList<UserAccountInfo> GetSuggestedFriends(int userId, int top)
        {
            const string sql = @"
SELECT TOP (@Top)
    u.Id,
    u.Username,
    u.DisplayName,
    u.Email,
    u.Phone,
    u.Balance,
    u.RoleCode,
    u.ReviewStatus,
    u.ReviewRemark,
    u.CreatedAt,
    u.ReviewedAt
FROM dbo.Users u
LEFT JOIN dbo.UserDesktopSettings uds ON uds.UserId = u.Id
WHERE u.Id <> @UserId
  AND u.ReviewStatus = N'Approved'
  AND ISNULL(uds.FriendRequestEnabled, 1) = 1
  AND NOT EXISTS (SELECT 1 FROM dbo.Friendships f WHERE f.UserId = @UserId AND f.FriendUserId = u.Id)
  AND NOT EXISTS
  (
      SELECT 1
      FROM dbo.UserBlocks b
      WHERE (b.UserId = @UserId AND b.BlockedUserId = u.Id)
         OR (b.UserId = u.Id AND b.BlockedUserId = @UserId)
  )
ORDER BY u.DisplayName ASC, u.Id ASC;";

            var results = new List<UserAccountInfo>();
            using (var connection = DbHelper.CreateConnection())
            using (var command = new SqlCommand(sql, connection))
            {
                command.Parameters.AddWithValue("@Top", top);
                command.Parameters.AddWithValue("@UserId", userId);
                connection.Open();
                using (var reader = command.ExecuteReader())
                {
                    while (reader.Read())
                    {
                        results.Add(MapUser(reader));
                    }
                }
            }

            return results;
        }

        public bool SendFriendRequest(int senderUserId, int receiverUserId, string requestMessage, out string message)
        {
            const string sql = @"
  IF @SenderUserId = @ReceiverUserId
  BEGIN
      RAISERROR(N'不能给自己发送好友申请。', 16, 1);
      RETURN;
  END;

  IF EXISTS
  (
      SELECT 1
      FROM dbo.UserBlocks
      WHERE (UserId = @SenderUserId AND BlockedUserId = @ReceiverUserId)
         OR (UserId = @ReceiverUserId AND BlockedUserId = @SenderUserId)
  )
  BEGIN
      RAISERROR(N'对方已被你拉黑或已将你拉黑，无法发送好友申请。', 16, 1);
      RETURN;
  END;

IF NOT EXISTS (SELECT 1 FROM dbo.Users WHERE Id = @ReceiverUserId AND ReviewStatus = N'Approved')
BEGIN
    RAISERROR(N'对方账号不存在或尚未通过审核。', 16, 1);
    RETURN;
END;

IF EXISTS (SELECT 1 FROM dbo.UserDesktopSettings WHERE UserId = @ReceiverUserId AND FriendRequestEnabled = 0)
BEGIN
    RAISERROR(N'对方当前关闭了好友申请。', 16, 1);
    RETURN;
END;

IF EXISTS (SELECT 1 FROM dbo.Friendships WHERE UserId = @SenderUserId AND FriendUserId = @ReceiverUserId)
BEGIN
    RAISERROR(N'你们已经是好友了。', 16, 1);
    RETURN;
END;

IF EXISTS
(
    SELECT 1
    FROM dbo.FriendRequests
    WHERE SenderUserId = @SenderUserId
      AND ReceiverUserId = @ReceiverUserId
      AND Status = N'Pending'
)
BEGIN
    RAISERROR(N'你已经发出过好友申请，请等待对方处理。', 16, 1);
    RETURN;
END;

IF EXISTS
(
    SELECT 1
    FROM dbo.FriendRequests
    WHERE SenderUserId = @ReceiverUserId
      AND ReceiverUserId = @SenderUserId
      AND Status = N'Pending'
)
BEGIN
    RAISERROR(N'对方已经向你发出好友申请，请到新的朋友中处理。', 16, 1);
    RETURN;
END;

INSERT INTO dbo.FriendRequests(SenderUserId, ReceiverUserId, RequestMessage, Status, CreatedAt)
VALUES(@SenderUserId, @ReceiverUserId, @RequestMessage, N'Pending', GETDATE());";

            using (var connection = DbHelper.CreateConnection())
            using (var command = new SqlCommand(sql, connection))
            {
                command.Parameters.AddWithValue("@SenderUserId", senderUserId);
                command.Parameters.AddWithValue("@ReceiverUserId", receiverUserId);
                command.Parameters.AddWithValue("@RequestMessage", string.IsNullOrWhiteSpace(requestMessage) ? (object)DBNull.Value : requestMessage.Trim());
                connection.Open();
                try
                {
                    command.ExecuteNonQuery();
                    message = "好友申请已发送。";
                    return true;
                }
                catch (SqlException ex)
                {
                    message = ex.Message;
                    return false;
                }
            }
        }

        public bool SendFriendRequestByPublicId(int senderUserId, string publicUserCode, string requestMessage, out string message)
        {
            var normalizedCode = NormalizePublicUserCode(publicUserCode);
            if (!IsValidPublicUserCode(normalizedCode))
            {
                message = "请输入有效的账号 ID。";
                return false;
            }

            const string sql = @"
SELECT TOP 1 Id
FROM dbo.Users
WHERE PublicUserCode = @PublicUserCode
  AND ReviewStatus = N'Approved';";

            using (var connection = DbHelper.CreateConnection())
            using (var command = new SqlCommand(sql, connection))
            {
                command.Parameters.AddWithValue("@PublicUserCode", normalizedCode);
                connection.Open();
                var receiver = command.ExecuteScalar();
                if (receiver == null || receiver == DBNull.Value)
                {
                    message = "没有找到这个账号 ID 对应的玩家。";
                    return false;
                }

                return SendFriendRequest(senderUserId, Convert.ToInt32(receiver), requestMessage, out message);
            }
        }

        public IList<FriendRequestInfo> GetIncomingFriendRequests(int userId)
        {
            return GetFriendRequests(@"
SELECT
    fr.Id,
    fr.SenderUserId,
    sender.DisplayName AS SenderDisplayName,
    ISNULL(sender.PublicUserCode, N'') AS SenderPublicUserCode,
    ISNULL(senderProfile.AvatarUrl, N'') AS SenderAvatarUrl,
    fr.ReceiverUserId,
    receiver.DisplayName AS ReceiverDisplayName,
    ISNULL(receiver.PublicUserCode, N'') AS ReceiverPublicUserCode,
    fr.RequestMessage,
    fr.Status,
    fr.CreatedAt,
    fr.ReviewedAt
FROM dbo.FriendRequests fr
INNER JOIN dbo.Users sender ON sender.Id = fr.SenderUserId
INNER JOIN dbo.Users receiver ON receiver.Id = fr.ReceiverUserId
LEFT JOIN dbo.PlayerProfiles senderProfile ON senderProfile.UserId = sender.Id
WHERE fr.ReceiverUserId = @UserId
  AND fr.Status = N'Pending'
ORDER BY fr.CreatedAt DESC, fr.Id DESC;", userId);
        }

        public IList<FriendRequestInfo> GetOutgoingFriendRequests(int userId)
        {
            return GetFriendRequests(@"
SELECT
    fr.Id,
    fr.SenderUserId,
    sender.DisplayName AS SenderDisplayName,
    ISNULL(sender.PublicUserCode, N'') AS SenderPublicUserCode,
    ISNULL(senderProfile.AvatarUrl, N'') AS SenderAvatarUrl,
    fr.ReceiverUserId,
    receiver.DisplayName AS ReceiverDisplayName,
    ISNULL(receiver.PublicUserCode, N'') AS ReceiverPublicUserCode,
    fr.RequestMessage,
    fr.Status,
    fr.CreatedAt,
    fr.ReviewedAt
FROM dbo.FriendRequests fr
INNER JOIN dbo.Users sender ON sender.Id = fr.SenderUserId
INNER JOIN dbo.Users receiver ON receiver.Id = fr.ReceiverUserId
LEFT JOIN dbo.PlayerProfiles senderProfile ON senderProfile.UserId = sender.Id
WHERE fr.SenderUserId = @UserId
ORDER BY fr.CreatedAt DESC, fr.Id DESC;", userId);
        }

        public bool ReviewFriendRequest(int requestId, int currentUserId, bool approved, out string message)
        {
            const string sql = @"
DECLARE @SenderUserId INT;
DECLARE @ReceiverUserId INT;
DECLARE @Status NVARCHAR(20);

SELECT
    @SenderUserId = SenderUserId,
    @ReceiverUserId = ReceiverUserId,
    @Status = Status
FROM dbo.FriendRequests WITH (UPDLOCK, HOLDLOCK)
WHERE Id = @RequestId;

IF @Status IS NULL
BEGIN
    RAISERROR(N'未找到对应好友申请。', 16, 1);
    RETURN;
END;

IF @ReceiverUserId <> @CurrentUserId
BEGIN
    RAISERROR(N'只有被申请方可以处理该好友申请。', 16, 1);
    RETURN;
END;

IF @Status <> N'Pending'
BEGIN
    RAISERROR(N'该好友申请已经处理过了。', 16, 1);
    RETURN;
END;

UPDATE dbo.FriendRequests
SET Status = @ReviewStatus,
    ReviewedAt = GETDATE()
WHERE Id = @RequestId;

IF @ReviewStatus = N'Approved'
BEGIN
    IF NOT EXISTS (SELECT 1 FROM dbo.Friendships WHERE UserId = @SenderUserId AND FriendUserId = @ReceiverUserId)
    BEGIN
        INSERT INTO dbo.Friendships(UserId, FriendUserId, CreatedAt)
        VALUES(@SenderUserId, @ReceiverUserId, GETDATE());
    END;

    IF NOT EXISTS (SELECT 1 FROM dbo.Friendships WHERE UserId = @ReceiverUserId AND FriendUserId = @SenderUserId)
    BEGIN
        INSERT INTO dbo.Friendships(UserId, FriendUserId, CreatedAt)
        VALUES(@ReceiverUserId, @SenderUserId, GETDATE());
    END;
END;";

            using (var connection = DbHelper.CreateConnection())
            using (var command = new SqlCommand(sql, connection))
            {
                command.Parameters.AddWithValue("@RequestId", requestId);
                command.Parameters.AddWithValue("@CurrentUserId", currentUserId);
                command.Parameters.AddWithValue("@ReviewStatus", approved ? "Approved" : "Rejected");
                connection.Open();

                using (var transaction = connection.BeginTransaction())
                {
                    command.Transaction = transaction;
                    try
                    {
                        command.ExecuteNonQuery();
                        transaction.Commit();
                        message = approved ? "已通过好友申请。" : "已拒绝好友申请。";
                        return true;
                    }
                    catch (SqlException ex)
                    {
                        transaction.Rollback();
                        message = ex.Message;
                        return false;
                    }
                }
            }
        }

        public IList<FriendChatSummaryInfo> GetFriendChatSummaries(int userId)
        {
            const string sql = @"
SELECT
    f.FriendUserId,
    u.Username,
    u.DisplayName,
    ISNULL(pp.AvatarUrl, N'') AS AvatarUrl,
    ISNULL(pp.FavoriteGenre, N'') AS FavoriteGenre,
    ISNULL(pp.ReputationLevel, N'新朋友') AS ReputationLevel,
    latest.LastMessagePreview,
    latest.LastMessageAt,
    ISNULL(unread.UnreadCount, 0) AS UnreadCount
FROM dbo.Friendships f
INNER JOIN dbo.Users u ON u.Id = f.FriendUserId
LEFT JOIN dbo.PlayerProfiles pp ON pp.UserId = u.Id
OUTER APPLY
(
    SELECT TOP 1
        CASE
            WHEN ISNULL(fm.IsRevoked, 0) = 1 THEN N'[已撤回消息]'
            WHEN fm.MessageType = N'Photo' THEN N'[照片] ' + ISNULL(NULLIF(fm.Content, N''), N'分享了一张照片')
            WHEN fm.MessageType = N'Location' THEN N'[位置] ' + ISNULL(NULLIF(fm.LocationText, N''), ISNULL(NULLIF(fm.Content, N''), N'分享了位置'))
            WHEN fm.MessageType = N'Voice' THEN N'[语音] ' + ISNULL(NULLIF(fm.Content, N''), N'发来一条语音留言')
            WHEN fm.MessageType = N'VideoCall' THEN N'[视频通话] ' + ISNULL(NULLIF(fm.Content, N''), N'发起了视频通话邀请')
            WHEN fm.MessageType = N'RedPacket' THEN N'[红包] ' + ISNULL(NULLIF(fm.Content, N''), N'发来了红包')
            WHEN fm.MessageType = N'Transfer' THEN N'[转账] ' + ISNULL(NULLIF(fm.Content, N''), N'发起了一笔转账')
            WHEN fm.MessageType = N'Gift' THEN N'[礼物] ' + ISNULL(NULLIF(fm.Content, N''), N'送来一份礼物')
            ELSE ISNULL(NULLIF(fm.Content, N''), N'开始聊天吧')
        END AS LastMessagePreview,
        fm.CreatedAt AS LastMessageAt
    FROM dbo.FriendMessages fm
    WHERE (fm.SenderUserId = @UserId AND fm.ReceiverUserId = f.FriendUserId)
       OR (fm.SenderUserId = f.FriendUserId AND fm.ReceiverUserId = @UserId)
    ORDER BY fm.CreatedAt DESC, fm.Id DESC
) latest
OUTER APPLY
(
    SELECT COUNT(1) AS UnreadCount
    FROM dbo.FriendMessages fm
    WHERE fm.SenderUserId = f.FriendUserId
      AND fm.ReceiverUserId = @UserId
      AND ISNULL(fm.IsRead, 0) = 0
) unread
WHERE f.UserId = @UserId
  AND NOT EXISTS
  (
      SELECT 1
      FROM dbo.UserBlocks b
      WHERE (b.UserId = @UserId AND b.BlockedUserId = f.FriendUserId)
         OR (b.UserId = f.FriendUserId AND b.BlockedUserId = @UserId)
  )
ORDER BY ISNULL(latest.LastMessageAt, f.CreatedAt) DESC, f.FriendUserId ASC;";

            var results = new List<FriendChatSummaryInfo>();
            using (var connection = DbHelper.CreateConnection())
            using (var command = new SqlCommand(sql, connection))
            {
                command.Parameters.AddWithValue("@UserId", userId);
                connection.Open();
                using (var reader = command.ExecuteReader())
                {
                    while (reader.Read())
                    {
                        results.Add(new FriendChatSummaryInfo
                        {
                            FriendUserId = Convert.ToInt32(reader["FriendUserId"]),
                            Username = Convert.ToString(reader["Username"]),
                            DisplayName = Convert.ToString(reader["DisplayName"]),
                            AvatarUrl = Convert.ToString(reader["AvatarUrl"]),
                            FavoriteGenre = Convert.ToString(reader["FavoriteGenre"]),
                            ReputationLevel = Convert.ToString(reader["ReputationLevel"]),
                            LastMessagePreview = reader["LastMessagePreview"] == DBNull.Value ? "开始聊天吧" : Convert.ToString(reader["LastMessagePreview"]),
                            LastMessageAt = reader["LastMessageAt"] == DBNull.Value ? (DateTime?)null : Convert.ToDateTime(reader["LastMessageAt"]),
                            UnreadCount = reader["UnreadCount"] == DBNull.Value ? 0 : Convert.ToInt32(reader["UnreadCount"])
                        });
                    }
                }
            }

            return results;
        }

        public IList<FriendChatMessageInfo> GetFriendConversation(int userId, int friendUserId, int top)
        {
            const string sql = @"
WITH RecentMessages AS
(
    SELECT TOP (@Top)
        fm.Id,
        fm.SenderUserId,
        sender.DisplayName AS SenderDisplayName,
        ISNULL(senderProfile.AvatarUrl, N'') AS SenderAvatarUrl,
        fm.ReceiverUserId,
        receiver.DisplayName AS ReceiverDisplayName,
        ISNULL(receiverProfile.AvatarUrl, N'') AS ReceiverAvatarUrl,
        fm.MessageType,
        fm.Content,
        fm.AttachmentUrl,
        fm.LocationText,
        ISNULL(fm.IsRead, 0) AS IsRead,
        ISNULL(fm.IsRevoked, 0) AS IsRevoked,
        fm.RevokedAt,
        fm.CreatedAt
    FROM dbo.FriendMessages fm
    INNER JOIN dbo.Users sender ON sender.Id = fm.SenderUserId
    INNER JOIN dbo.Users receiver ON receiver.Id = fm.ReceiverUserId
    LEFT JOIN dbo.PlayerProfiles senderProfile ON senderProfile.UserId = fm.SenderUserId
    LEFT JOIN dbo.PlayerProfiles receiverProfile ON receiverProfile.UserId = fm.ReceiverUserId
    WHERE
    (
        (fm.SenderUserId = @UserId AND fm.ReceiverUserId = @FriendUserId)
        OR (fm.SenderUserId = @FriendUserId AND fm.ReceiverUserId = @UserId)
    )
      AND NOT EXISTS
      (
          SELECT 1
          FROM dbo.UserBlocks b
          WHERE (b.UserId = @UserId AND b.BlockedUserId = @FriendUserId)
             OR (b.UserId = @FriendUserId AND b.BlockedUserId = @UserId)
      )
    ORDER BY fm.CreatedAt DESC, fm.Id DESC
)
SELECT *
FROM RecentMessages
ORDER BY CreatedAt ASC, Id ASC;";

            var results = new List<FriendChatMessageInfo>();
            using (var connection = DbHelper.CreateConnection())
            using (var command = new SqlCommand(sql, connection))
            {
                command.Parameters.AddWithValue("@Top", top);
                command.Parameters.AddWithValue("@UserId", userId);
                command.Parameters.AddWithValue("@FriendUserId", friendUserId);
                connection.Open();
                using (var reader = command.ExecuteReader())
                {
                    while (reader.Read())
                    {
                        results.Add(new FriendChatMessageInfo
                        {
                            Id = Convert.ToInt32(reader["Id"]),
                            SenderUserId = Convert.ToInt32(reader["SenderUserId"]),
                            SenderDisplayName = Convert.ToString(reader["SenderDisplayName"]),
                            SenderAvatarUrl = Convert.ToString(reader["SenderAvatarUrl"]),
                            ReceiverUserId = Convert.ToInt32(reader["ReceiverUserId"]),
                            ReceiverDisplayName = Convert.ToString(reader["ReceiverDisplayName"]),
                            ReceiverAvatarUrl = Convert.ToString(reader["ReceiverAvatarUrl"]),
                            MessageType = Convert.ToString(reader["MessageType"]),
                            Content = reader["Content"] == DBNull.Value ? string.Empty : Convert.ToString(reader["Content"]),
                            AttachmentUrl = reader["AttachmentUrl"] == DBNull.Value ? string.Empty : Convert.ToString(reader["AttachmentUrl"]),
                            LocationText = reader["LocationText"] == DBNull.Value ? string.Empty : Convert.ToString(reader["LocationText"]),
                            IsRead = Convert.ToBoolean(reader["IsRead"]),
                            IsRevoked = Convert.ToBoolean(reader["IsRevoked"]),
                            RevokedAt = reader["RevokedAt"] == DBNull.Value ? (DateTime?)null : Convert.ToDateTime(reader["RevokedAt"]),
                            CreatedAt = Convert.ToDateTime(reader["CreatedAt"])
                        });
                    }
                }
            }

            return results;
        }

        public bool SendFriendMessage(int senderUserId, int receiverUserId, string messageType, string content, string attachmentUrl, string locationText, out string message)
        {
            const string sql = @"
  IF @SenderUserId = @ReceiverUserId
  BEGIN
      RAISERROR(N'不能给自己发送消息。', 16, 1);
      RETURN;
  END;

  IF EXISTS
  (
      SELECT 1
      FROM dbo.UserBlocks
      WHERE (UserId = @SenderUserId AND BlockedUserId = @ReceiverUserId)
         OR (UserId = @ReceiverUserId AND BlockedUserId = @SenderUserId)
  )
  BEGIN
      RAISERROR(N'当前好友关系已被限制，无法继续发送消息。', 16, 1);
      RETURN;
  END;

IF NOT EXISTS
(
    SELECT 1
    FROM dbo.Friendships
    WHERE UserId = @SenderUserId
      AND FriendUserId = @ReceiverUserId
)
BEGIN
    RAISERROR(N'只有好友之间才能发送互动消息。', 16, 1);
    RETURN;
END;

IF NULLIF(LTRIM(RTRIM(ISNULL(@Content, N''))), N'') IS NULL
   AND NULLIF(LTRIM(RTRIM(ISNULL(@AttachmentUrl, N''))), N'') IS NULL
   AND NULLIF(LTRIM(RTRIM(ISNULL(@LocationText, N''))), N'') IS NULL
BEGIN
    RAISERROR(N'请至少填写消息内容、附件地址或位置信息中的一项。', 16, 1);
    RETURN;
END;

INSERT INTO dbo.FriendMessages
(
    SenderUserId,
    ReceiverUserId,
    MessageType,
    Content,
    AttachmentUrl,
    LocationText,
    CreatedAt
)
VALUES
(
    @SenderUserId,
    @ReceiverUserId,
    @MessageType,
    NULLIF(@Content, N''),
    NULLIF(@AttachmentUrl, N''),
    NULLIF(@LocationText, N''),
    GETDATE()
);";

            using (var connection = DbHelper.CreateConnection())
            using (var command = new SqlCommand(sql, connection))
            {
                command.Parameters.AddWithValue("@SenderUserId", senderUserId);
                command.Parameters.AddWithValue("@ReceiverUserId", receiverUserId);
                command.Parameters.AddWithValue("@MessageType", string.IsNullOrWhiteSpace(messageType) ? "Text" : messageType);
                command.Parameters.AddWithValue("@Content", string.IsNullOrWhiteSpace(content) ? string.Empty : content.Trim());
                command.Parameters.AddWithValue("@AttachmentUrl", string.IsNullOrWhiteSpace(attachmentUrl) ? string.Empty : attachmentUrl.Trim());
                command.Parameters.AddWithValue("@LocationText", string.IsNullOrWhiteSpace(locationText) ? string.Empty : locationText.Trim());
                connection.Open();
                try
                {
                    command.ExecuteNonQuery();
                    message = "好友消息已发送，聊天记录已经更新。";
                    return true;
                }
                catch (SqlException ex)
                {
                    message = ex.Message;
                    return false;
                }
            }
        }

        public bool MarkConversationAsRead(int userId, int friendUserId)
        {
            const string sql = @"
UPDATE dbo.FriendMessages
SET IsRead = 1
WHERE SenderUserId = @FriendUserId
  AND ReceiverUserId = @UserId
  AND ISNULL(IsRead, 0) = 0;";

            using (var connection = DbHelper.CreateConnection())
            using (var command = new SqlCommand(sql, connection))
            {
                command.Parameters.AddWithValue("@UserId", userId);
                command.Parameters.AddWithValue("@FriendUserId", friendUserId);
                connection.Open();
                command.ExecuteNonQuery();
            }

            return true;
        }

        public bool RevokeFriendMessage(int userId, int messageId, out string message)
        {
            const string sql = @"
IF NOT EXISTS
(
    SELECT 1
    FROM dbo.FriendMessages
    WHERE Id = @MessageId
      AND SenderUserId = @UserId
      AND ISNULL(IsRevoked, 0) = 0
)
BEGIN
    RAISERROR(N'这条消息不存在，或你没有权限撤回。', 16, 1);
    RETURN;
END;

UPDATE dbo.FriendMessages
SET IsRevoked = 1,
    RevokedAt = GETDATE(),
    Content = N'你撤回了一条消息',
    AttachmentUrl = NULL,
    LocationText = NULL
WHERE Id = @MessageId
  AND SenderUserId = @UserId;";

            using (var connection = DbHelper.CreateConnection())
            using (var command = new SqlCommand(sql, connection))
            {
                command.Parameters.AddWithValue("@MessageId", messageId);
                command.Parameters.AddWithValue("@UserId", userId);
                connection.Open();
                try
                {
                    command.ExecuteNonQuery();
                    message = "消息已撤回。";
                    return true;
                }
                catch (SqlException ex)
                {
                    message = ex.Message;
                    return false;
                }
            }
        }

        public bool RemoveFriend(int userId, int friendUserId, out string message)
        {
            const string sql = @"
IF NOT EXISTS (SELECT 1 FROM dbo.Friendships WHERE UserId = @UserId AND FriendUserId = @FriendUserId)
BEGIN
    RAISERROR(N'你们当前还不是好友。', 16, 1);
    RETURN;
END;

DELETE FROM dbo.Friendships
WHERE (UserId = @UserId AND FriendUserId = @FriendUserId)
   OR (UserId = @FriendUserId AND FriendUserId = @UserId);";

            using (var connection = DbHelper.CreateConnection())
            using (var command = new SqlCommand(sql, connection))
            {
                command.Parameters.AddWithValue("@UserId", userId);
                command.Parameters.AddWithValue("@FriendUserId", friendUserId);
                connection.Open();
                try
                {
                    command.ExecuteNonQuery();
                    message = "好友关系已经解除。";
                    return true;
                }
                catch (SqlException ex)
                {
                    message = ex.Message;
                    return false;
                }
            }
        }

        public bool BlockUser(int userId, int blockedUserId, out string message)
        {
            const string sql = @"
IF @UserId = @BlockedUserId
BEGIN
    RAISERROR(N'不能拉黑自己。', 16, 1);
    RETURN;
END;

IF EXISTS (SELECT 1 FROM dbo.UserBlocks WHERE UserId = @UserId AND BlockedUserId = @BlockedUserId)
BEGIN
    RAISERROR(N'该玩家已经在黑名单中。', 16, 1);
    RETURN;
END;

INSERT INTO dbo.UserBlocks(UserId, BlockedUserId, CreatedAt)
VALUES(@UserId, @BlockedUserId, GETDATE());

DELETE FROM dbo.Friendships
WHERE (UserId = @UserId AND FriendUserId = @BlockedUserId)
   OR (UserId = @BlockedUserId AND FriendUserId = @UserId);

UPDATE dbo.FriendRequests
SET Status = N'Rejected',
    ReviewedAt = GETDATE()
WHERE ((SenderUserId = @UserId AND ReceiverUserId = @BlockedUserId)
    OR (SenderUserId = @BlockedUserId AND ReceiverUserId = @UserId))
  AND Status = N'Pending';";

            using (var connection = DbHelper.CreateConnection())
            using (var command = new SqlCommand(sql, connection))
            {
                command.Parameters.AddWithValue("@UserId", userId);
                command.Parameters.AddWithValue("@BlockedUserId", blockedUserId);
                connection.Open();
                try
                {
                    command.ExecuteNonQuery();
                    message = "该玩家已加入黑名单，并解除好友关系。";
                    return true;
                }
                catch (SqlException ex)
                {
                    message = ex.Message;
                    return false;
                }
            }
        }

        public bool UnblockUser(int userId, int blockedUserId, out string message)
        {
            const string sql = @"
DELETE FROM dbo.UserBlocks
WHERE UserId = @UserId
  AND BlockedUserId = @BlockedUserId;";

            using (var connection = DbHelper.CreateConnection())
            using (var command = new SqlCommand(sql, connection))
            {
                command.Parameters.AddWithValue("@UserId", userId);
                command.Parameters.AddWithValue("@BlockedUserId", blockedUserId);
                connection.Open();
                var affected = command.ExecuteNonQuery();
                message = affected > 0 ? "已移出黑名单。" : "未找到对应黑名单记录。";
                return affected > 0;
            }
        }

        public IList<BlockedUserInfo> GetBlockedUsers(int userId)
        {
            const string sql = @"
SELECT
    b.BlockedUserId,
    u.Username,
    u.DisplayName,
    ISNULL(pp.AvatarUrl, N'') AS AvatarUrl,
    b.CreatedAt
FROM dbo.UserBlocks b
INNER JOIN dbo.Users u ON u.Id = b.BlockedUserId
LEFT JOIN dbo.PlayerProfiles pp ON pp.UserId = u.Id
WHERE b.UserId = @UserId
ORDER BY b.CreatedAt DESC, b.Id DESC;";

            var results = new List<BlockedUserInfo>();
            using (var connection = DbHelper.CreateConnection())
            using (var command = new SqlCommand(sql, connection))
            {
                command.Parameters.AddWithValue("@UserId", userId);
                connection.Open();
                using (var reader = command.ExecuteReader())
                {
                    while (reader.Read())
                    {
                        results.Add(new BlockedUserInfo
                        {
                            BlockedUserId = Convert.ToInt32(reader["BlockedUserId"]),
                            Username = Convert.ToString(reader["Username"]),
                            DisplayName = Convert.ToString(reader["DisplayName"]),
                            AvatarUrl = Convert.ToString(reader["AvatarUrl"]),
                            CreatedAt = Convert.ToDateTime(reader["CreatedAt"])
                        });
                    }
                }
            }

            return results;
        }

        public bool CreateMoment(int userId, string content, string imageUrl, string locationText, out string message)
        {
            return CreateMoment(userId, content, imageUrl, locationText, "Friends", out message);
        }

        public bool CreateMoment(int userId, string content, string imageUrl, string locationText, string visibility, out string message)
        {
            const string sql = @"
IF NULLIF(LTRIM(RTRIM(ISNULL(@Content, N''))), N'') IS NULL
   AND NULLIF(LTRIM(RTRIM(ISNULL(@ImageUrl, N''))), N'') IS NULL
   AND NULLIF(LTRIM(RTRIM(ISNULL(@LocationText, N''))), N'') IS NULL
BEGIN
    RAISERROR(N'朋友圈分享至少要填写文字、图片或位置中的一项。', 16, 1);
    RETURN;
END;

INSERT INTO dbo.FriendMoments(UserId, Content, ImageUrl, LocationText, Visibility, CreatedAt)
VALUES(@UserId, NULLIF(@Content, N''), NULLIF(@ImageUrl, N''), NULLIF(@LocationText, N''), @Visibility, GETDATE());";

            using (var connection = DbHelper.CreateConnection())
            using (var command = new SqlCommand(sql, connection))
            {
                command.Parameters.AddWithValue("@UserId", userId);
                command.Parameters.AddWithValue("@Content", string.IsNullOrWhiteSpace(content) ? string.Empty : content.Trim());
                command.Parameters.AddWithValue("@ImageUrl", string.IsNullOrWhiteSpace(imageUrl) ? string.Empty : imageUrl.Trim());
                command.Parameters.AddWithValue("@LocationText", string.IsNullOrWhiteSpace(locationText) ? string.Empty : locationText.Trim());
                command.Parameters.AddWithValue("@Visibility", NormalizeMomentVisibility(visibility));
                connection.Open();
                try
                {
                    command.ExecuteNonQuery();
                    message = "朋友圈已经分享成功，好友刷新后就能看到。";
                    return true;
                }
                catch (SqlException ex)
                {
                    message = ex.Message;
                    return false;
                }
            }
        }

        public IList<MomentPostInfo> GetMomentFeed(int userId, int top)
        {
            const string sql = @"
SELECT TOP (@Top)
    fm.Id,
    fm.UserId,
    u.DisplayName,
    ISNULL(pp.AvatarUrl, N'') AS AvatarUrl,
    ISNULL(fm.Content, N'') AS Content,
    ISNULL(fm.ImageUrl, N'') AS ImageUrl,
    ISNULL(fm.LocationText, N'') AS LocationText,
    fm.Visibility,
    fm.CreatedAt,
    ISNULL(likes.LikeCount, 0) AS LikeCount,
    ISNULL(comments.CommentCount, 0) AS CommentCount,
    CASE WHEN EXISTS (SELECT 1 FROM dbo.MomentLikes ml WHERE ml.MomentId = fm.Id AND ml.UserId = @UserId) THEN CAST(1 AS BIT) ELSE CAST(0 AS BIT) END AS IsLikedByCurrentUser
FROM dbo.FriendMoments fm
INNER JOIN dbo.Users u ON u.Id = fm.UserId
LEFT JOIN dbo.PlayerProfiles pp ON pp.UserId = fm.UserId
OUTER APPLY
(
    SELECT COUNT(1) AS LikeCount
    FROM dbo.MomentLikes ml
    WHERE ml.MomentId = fm.Id
) likes
OUTER APPLY
(
    SELECT COUNT(1) AS CommentCount
    FROM dbo.MomentComments mc
    WHERE mc.MomentId = fm.Id
) comments
WHERE
(
    fm.UserId = @UserId
    OR
    (
        fm.Visibility <> N'Private'
        AND EXISTS
        (
            SELECT 1
            FROM dbo.Friendships f
            WHERE f.UserId = @UserId
              AND f.FriendUserId = fm.UserId
        )
    )
)
AND NOT EXISTS
  (
      SELECT 1
      FROM dbo.UserBlocks b
      WHERE (b.UserId = @UserId AND b.BlockedUserId = fm.UserId)
         OR (b.UserId = fm.UserId AND b.BlockedUserId = @UserId)
  )
ORDER BY fm.CreatedAt DESC, fm.Id DESC;";

            var results = new List<MomentPostInfo>();
            using (var connection = DbHelper.CreateConnection())
            using (var command = new SqlCommand(sql, connection))
            {
                command.Parameters.AddWithValue("@Top", top);
                command.Parameters.AddWithValue("@UserId", userId);
                connection.Open();
                using (var reader = command.ExecuteReader())
                {
                    while (reader.Read())
                    {
                        results.Add(new MomentPostInfo
                        {
                            Id = Convert.ToInt32(reader["Id"]),
                            UserId = Convert.ToInt32(reader["UserId"]),
                            DisplayName = Convert.ToString(reader["DisplayName"]),
                            AvatarUrl = Convert.ToString(reader["AvatarUrl"]),
                            Content = Convert.ToString(reader["Content"]),
                            ImageUrl = Convert.ToString(reader["ImageUrl"]),
                            LocationText = Convert.ToString(reader["LocationText"]),
                            Visibility = Convert.ToString(reader["Visibility"]),
                            LikeCount = Convert.ToInt32(reader["LikeCount"]),
                            CommentCount = Convert.ToInt32(reader["CommentCount"]),
                            IsLikedByCurrentUser = Convert.ToBoolean(reader["IsLikedByCurrentUser"]),
                            CreatedAt = Convert.ToDateTime(reader["CreatedAt"])
                        });
                    }
                }
            }

            return results;
        }

        public bool ToggleMomentLike(int userId, int momentId, out string message)
        {
            const string sql = @"
IF NOT EXISTS
(
    SELECT 1
    FROM dbo.FriendMoments fm
    WHERE fm.Id = @MomentId
      AND
      (
          fm.UserId = @UserId
          OR fm.Visibility = N'Public'
          OR
          (
              fm.Visibility = N'Friends'
              AND EXISTS
              (
                  SELECT 1
                  FROM dbo.Friendships f
                  WHERE f.UserId = @UserId
                    AND f.FriendUserId = fm.UserId
              )
          )
      )
      AND NOT EXISTS
      (
          SELECT 1
          FROM dbo.UserBlocks b
          WHERE (b.UserId = @UserId AND b.BlockedUserId = fm.UserId)
             OR (b.UserId = fm.UserId AND b.BlockedUserId = @UserId)
      )
)
BEGIN
    RAISERROR(N'当前动态不存在或你没有权限互动。', 16, 1);
    RETURN;
END;

IF EXISTS (SELECT 1 FROM dbo.MomentLikes WHERE UserId = @UserId AND MomentId = @MomentId)
BEGIN
    DELETE FROM dbo.MomentLikes
    WHERE UserId = @UserId
      AND MomentId = @MomentId;
END
ELSE
BEGIN
    INSERT INTO dbo.MomentLikes(UserId, MomentId, CreatedAt)
    VALUES(@UserId, @MomentId, GETDATE());
END;";

            using (var connection = DbHelper.CreateConnection())
            using (var command = new SqlCommand(sql, connection))
            {
                command.Parameters.AddWithValue("@UserId", userId);
                command.Parameters.AddWithValue("@MomentId", momentId);
                connection.Open();
                try
                {
                    command.ExecuteNonQuery();
                    message = "朋友圈互动已更新。";
                    return true;
                }
                catch (SqlException ex)
                {
                    message = ex.Message;
                    return false;
                }
            }
        }

        public bool AddMomentComment(int userId, int momentId, string content, int? parentCommentId, out string message)
        {
            const string sql = @"
IF NULLIF(LTRIM(RTRIM(ISNULL(@Content, N''))), N'') IS NULL
BEGIN
    RAISERROR(N'评论内容不能为空。', 16, 1);
    RETURN;
END;

IF NOT EXISTS
(
    SELECT 1
    FROM dbo.FriendMoments fm
    WHERE fm.Id = @MomentId
      AND
      (
          fm.UserId = @UserId
          OR fm.Visibility = N'Public'
          OR
          (
              fm.Visibility = N'Friends'
              AND EXISTS
              (
                  SELECT 1
                  FROM dbo.Friendships f
                  WHERE f.UserId = @UserId
                    AND f.FriendUserId = fm.UserId
              )
          )
      )
      AND NOT EXISTS
      (
          SELECT 1
          FROM dbo.UserBlocks b
          WHERE (b.UserId = @UserId AND b.BlockedUserId = fm.UserId)
             OR (b.UserId = fm.UserId AND b.BlockedUserId = @UserId)
      )
)
BEGIN
    RAISERROR(N'当前动态不存在或你没有权限评论。', 16, 1);
    RETURN;
END;

IF @ParentCommentId IS NOT NULL
   AND NOT EXISTS (SELECT 1 FROM dbo.MomentComments WHERE Id = @ParentCommentId AND MomentId = @MomentId)
BEGIN
    RAISERROR(N'要回复的评论不存在。', 16, 1);
    RETURN;
END;

INSERT INTO dbo.MomentComments(MomentId, UserId, Content, CreatedAt)
VALUES(@MomentId, @UserId, @Content, GETDATE());

IF @ParentCommentId IS NOT NULL
BEGIN
    UPDATE dbo.MomentComments
    SET ParentCommentId = @ParentCommentId
    WHERE Id = SCOPE_IDENTITY();
END;";

            using (var connection = DbHelper.CreateConnection())
            using (var command = new SqlCommand(sql, connection))
            {
                command.Parameters.AddWithValue("@MomentId", momentId);
                command.Parameters.AddWithValue("@UserId", userId);
                command.Parameters.AddWithValue("@Content", content == null ? string.Empty : content.Trim());
                command.Parameters.AddWithValue("@ParentCommentId", parentCommentId.HasValue ? (object)parentCommentId.Value : DBNull.Value);
                connection.Open();
                try
                {
                    command.ExecuteNonQuery();
                    message = "评论已发布。";
                    return true;
                }
                catch (SqlException ex)
                {
                    message = ex.Message;
                    return false;
                }
            }
        }

        public IList<MomentCommentInfo> GetMomentComments(int currentUserId, int momentId, int top)
        {
            const string sql = @"
SELECT TOP (@Top)
    mc.Id,
    mc.MomentId,
    mc.UserId,
    mc.ParentCommentId,
    u.DisplayName,
    parentUser.DisplayName AS ReplyToDisplayName,
    ISNULL(pp.AvatarUrl, N'') AS AvatarUrl,
    mc.Content,
    mc.CreatedAt
FROM dbo.MomentComments mc
INNER JOIN dbo.Users u ON u.Id = mc.UserId
LEFT JOIN dbo.PlayerProfiles pp ON pp.UserId = mc.UserId
LEFT JOIN dbo.MomentComments parentComment ON parentComment.Id = mc.ParentCommentId
LEFT JOIN dbo.Users parentUser ON parentUser.Id = parentComment.UserId
WHERE mc.MomentId = @MomentId
  AND NOT EXISTS
  (
      SELECT 1
      FROM dbo.UserBlocks b
      WHERE (b.UserId = @CurrentUserId AND b.BlockedUserId = mc.UserId)
         OR (b.UserId = mc.UserId AND b.BlockedUserId = @CurrentUserId)
  )
ORDER BY mc.CreatedAt ASC, mc.Id ASC;";

            var results = new List<MomentCommentInfo>();
            using (var connection = DbHelper.CreateConnection())
            using (var command = new SqlCommand(sql, connection))
            {
                command.Parameters.AddWithValue("@Top", top);
                command.Parameters.AddWithValue("@CurrentUserId", currentUserId);
                command.Parameters.AddWithValue("@MomentId", momentId);
                connection.Open();
                using (var reader = command.ExecuteReader())
                {
                    while (reader.Read())
                    {
                        results.Add(new MomentCommentInfo
                        {
                            Id = Convert.ToInt32(reader["Id"]),
                            MomentId = Convert.ToInt32(reader["MomentId"]),
                            UserId = Convert.ToInt32(reader["UserId"]),
                            ParentCommentId = reader["ParentCommentId"] == DBNull.Value ? (int?)null : Convert.ToInt32(reader["ParentCommentId"]),
                            DisplayName = Convert.ToString(reader["DisplayName"]),
                            ReplyToDisplayName = reader["ReplyToDisplayName"] == DBNull.Value ? string.Empty : Convert.ToString(reader["ReplyToDisplayName"]),
                            AvatarUrl = Convert.ToString(reader["AvatarUrl"]),
                            Content = Convert.ToString(reader["Content"]),
                            CreatedAt = Convert.ToDateTime(reader["CreatedAt"])
                        });
                    }
                }
            }

            return results;
        }

        public bool DeleteMoment(int userId, int momentId, out string message)
        {
            const string sql = @"
IF NOT EXISTS (SELECT 1 FROM dbo.FriendMoments WHERE Id = @MomentId AND UserId = @UserId)
BEGIN
    RAISERROR(N'只能删除自己发布的朋友圈动态。', 16, 1);
    RETURN;
END;

DELETE FROM dbo.MomentLikes WHERE MomentId = @MomentId;
DELETE FROM dbo.MomentComments WHERE MomentId = @MomentId;
DELETE FROM dbo.FriendMoments WHERE Id = @MomentId AND UserId = @UserId;";

            using (var connection = DbHelper.CreateConnection())
            using (var command = new SqlCommand(sql, connection))
            {
                command.Parameters.AddWithValue("@UserId", userId);
                command.Parameters.AddWithValue("@MomentId", momentId);
                connection.Open();
                try
                {
                    command.ExecuteNonQuery();
                    message = "朋友圈动态已删除。";
                    return true;
                }
                catch (SqlException ex)
                {
                    message = ex.Message;
                    return false;
                }
            }
        }

        public bool DeleteMomentComment(int userId, int commentId, out string message)
        {
            const string sql = @"
DECLARE @MomentId INT;

SELECT @MomentId = mc.MomentId
FROM dbo.MomentComments mc
INNER JOIN dbo.FriendMoments fm ON fm.Id = mc.MomentId
WHERE mc.Id = @CommentId
  AND (mc.UserId = @UserId OR fm.UserId = @UserId);

IF @MomentId IS NULL
BEGIN
    RAISERROR(N'只能删除自己的评论，或删除自己动态下的评论。', 16, 1);
    RETURN;
END;

DELETE FROM dbo.MomentComments
WHERE Id = @CommentId
   OR ParentCommentId = @CommentId;";

            using (var connection = DbHelper.CreateConnection())
            using (var command = new SqlCommand(sql, connection))
            {
                command.Parameters.AddWithValue("@UserId", userId);
                command.Parameters.AddWithValue("@CommentId", commentId);
                connection.Open();
                try
                {
                    command.ExecuteNonQuery();
                    message = "评论已删除。";
                    return true;
                }
                catch (SqlException ex)
                {
                    message = ex.Message;
                    return false;
                }
            }
        }

        public bool SendPeerTransfer(int senderUserId, int receiverUserId, decimal amount, string transferType, string note, out string message)
        {
            const string sql = @"
DECLARE @SenderBalance DECIMAL(10,2);
DECLARE @SenderBalanceAfter DECIMAL(10,2);
DECLARE @ReceiverBalanceAfter DECIMAL(10,2);
DECLARE @TransferLabel NVARCHAR(20);
DECLARE @ReceiverExists INT;

  IF @SenderUserId = @ReceiverUserId
  BEGIN
      RAISERROR(N'不能给自己发红包或转账。', 16, 1);
      RETURN;
  END;

  IF EXISTS
  (
      SELECT 1
      FROM dbo.UserBlocks
      WHERE (UserId = @SenderUserId AND BlockedUserId = @ReceiverUserId)
         OR (UserId = @ReceiverUserId AND BlockedUserId = @SenderUserId)
  )
  BEGIN
      RAISERROR(N'当前好友关系已被限制，无法继续资金互动。', 16, 1);
      RETURN;
  END;

IF @Amount <= 0
BEGIN
    RAISERROR(N'金额必须大于 0。', 16, 1);
    RETURN;
END;

IF @Amount > 20000
BEGIN
    RAISERROR(N'单笔金额不能超过 20000 元。', 16, 1);
    RETURN;
END;

IF NOT EXISTS
(
    SELECT 1
    FROM dbo.Friendships
    WHERE UserId = @SenderUserId
      AND FriendUserId = @ReceiverUserId
)
BEGIN
    RAISERROR(N'只有好友之间才能发红包或转账。', 16, 1);
    RETURN;
END;

SET @TransferLabel = CASE WHEN @TransferType = N'RedPacket' THEN N'红包' ELSE N'转账' END;

SELECT @SenderBalance = Balance
FROM dbo.Users WITH (UPDLOCK, HOLDLOCK)
WHERE Id = @SenderUserId;

SELECT @ReceiverExists = COUNT(1)
FROM dbo.Users WITH (UPDLOCK, HOLDLOCK)
WHERE Id = @ReceiverUserId;

IF @SenderBalance IS NULL
BEGIN
    RAISERROR(N'未找到当前账号。', 16, 1);
    RETURN;
END;

IF ISNULL(@ReceiverExists, 0) = 0
BEGIN
    RAISERROR(N'未找到接收好友账号。', 16, 1);
    RETURN;
END;

IF @SenderBalance < @Amount
BEGIN
    RAISERROR(N'余额不足，请先去钱包中心充值。', 16, 1);
    RETURN;
END;

UPDATE dbo.Users
SET Balance = Balance - @Amount
WHERE Id = @SenderUserId
  AND Balance >= @Amount;

IF @@ROWCOUNT = 0
BEGIN
    RAISERROR(N'余额不足，请先去钱包中心充值。', 16, 1);
    RETURN;
END;

UPDATE dbo.Users
SET Balance = Balance + @Amount
WHERE Id = @ReceiverUserId;

IF @@ROWCOUNT = 0
BEGIN
    RAISERROR(N'接收方余额入账失败，请稍后再试。', 16, 1);
    RETURN;
END;

SELECT @SenderBalanceAfter = Balance
FROM dbo.Users
WHERE Id = @SenderUserId;

SELECT @ReceiverBalanceAfter = Balance
FROM dbo.Users
WHERE Id = @ReceiverUserId;

INSERT INTO dbo.FriendMoneyTransfers(SenderUserId, ReceiverUserId, TransferType, Amount, Note, CreatedAt)
VALUES(@SenderUserId, @ReceiverUserId, @TransferType, @Amount, NULLIF(@Note, N''), GETDATE());

INSERT INTO dbo.WalletTransactions(UserId, TransactionType, Amount, BalanceAfter, Summary, CreatedAt)
VALUES(@SenderUserId, @TransferLabel + N'支出', -@Amount, @SenderBalanceAfter, @TransferLabel + N'已发出，现金余额实时扣减', GETDATE());

INSERT INTO dbo.WalletTransactions(UserId, TransactionType, Amount, BalanceAfter, Summary, CreatedAt)
VALUES(@ReceiverUserId, @TransferLabel + N'收入', @Amount, @ReceiverBalanceAfter, @TransferLabel + N'已到账，现金余额实时增加', GETDATE());

INSERT INTO dbo.FriendMessages(SenderUserId, ReceiverUserId, MessageType, Content, AttachmentUrl, LocationText, CreatedAt)
VALUES(@SenderUserId, @ReceiverUserId, @TransferType, @TransferLabel + N' ￥' + CONVERT(NVARCHAR(20), CAST(@Amount AS DECIMAL(10,2))) + CASE WHEN NULLIF(@Note, N'') IS NULL THEN N'' ELSE N' · ' + @Note END, NULL, NULL, GETDATE());";

            using (var connection = DbHelper.CreateConnection())
            using (var command = new SqlCommand(sql, connection))
            {
                command.Parameters.AddWithValue("@SenderUserId", senderUserId);
                command.Parameters.AddWithValue("@ReceiverUserId", receiverUserId);
                command.Parameters.AddWithValue("@Amount", amount);
                command.Parameters.AddWithValue("@TransferType", transferType == "RedPacket" ? "RedPacket" : "Transfer");
                command.Parameters.AddWithValue("@Note", string.IsNullOrWhiteSpace(note) ? string.Empty : note.Trim());
                connection.Open();
                using (var transaction = connection.BeginTransaction())
                {
                    command.Transaction = transaction;
                    try
                    {
                        command.ExecuteNonQuery();
                        transaction.Commit();
                        message = transferType == "RedPacket" ? "红包已经发出，对方余额和聊天记录都已更新。" : "转账已经完成，对方余额和聊天记录都已更新。";
                        return true;
                    }
                    catch (SqlException ex)
                    {
                        transaction.Rollback();
                        message = ex.Message;
                        return false;
                    }
                }
            }
        }

        public IList<FriendMoneyTransferInfo> GetFriendMoneyTransfers(int userId, int top)
        {
            const string sql = @"
SELECT TOP (@Top)
    fmt.Id,
    fmt.SenderUserId,
    sender.DisplayName AS SenderDisplayName,
    fmt.ReceiverUserId,
    receiver.DisplayName AS ReceiverDisplayName,
    fmt.TransferType,
    fmt.Amount,
    ISNULL(fmt.Note, N'') AS Note,
    fmt.CreatedAt
FROM dbo.FriendMoneyTransfers fmt
INNER JOIN dbo.Users sender ON sender.Id = fmt.SenderUserId
INNER JOIN dbo.Users receiver ON receiver.Id = fmt.ReceiverUserId
WHERE fmt.SenderUserId = @UserId
   OR fmt.ReceiverUserId = @UserId
ORDER BY fmt.CreatedAt DESC, fmt.Id DESC;";

            var results = new List<FriendMoneyTransferInfo>();
            using (var connection = DbHelper.CreateConnection())
            using (var command = new SqlCommand(sql, connection))
            {
                command.Parameters.AddWithValue("@Top", top);
                command.Parameters.AddWithValue("@UserId", userId);
                connection.Open();
                using (var reader = command.ExecuteReader())
                {
                    while (reader.Read())
                    {
                        results.Add(new FriendMoneyTransferInfo
                        {
                            Id = Convert.ToInt32(reader["Id"]),
                            SenderUserId = Convert.ToInt32(reader["SenderUserId"]),
                            SenderDisplayName = Convert.ToString(reader["SenderDisplayName"]),
                            ReceiverUserId = Convert.ToInt32(reader["ReceiverUserId"]),
                            ReceiverDisplayName = Convert.ToString(reader["ReceiverDisplayName"]),
                            TransferType = Convert.ToString(reader["TransferType"]),
                            Amount = Convert.ToDecimal(reader["Amount"]),
                            Note = Convert.ToString(reader["Note"]),
                            CreatedAt = Convert.ToDateTime(reader["CreatedAt"])
                        });
                    }
                }
            }

            return results;
        }

        public IList<MomentPostInfo> GetMomentFeedForUser(int viewerUserId, int profileUserId, int top)
        {
            const string sql = @"
SELECT TOP (@Top)
    fm.Id,
    fm.UserId,
    u.DisplayName,
    ISNULL(pp.AvatarUrl, N'') AS AvatarUrl,
    ISNULL(fm.Content, N'') AS Content,
    ISNULL(fm.ImageUrl, N'') AS ImageUrl,
    ISNULL(fm.LocationText, N'') AS LocationText,
    fm.Visibility,
    fm.CreatedAt,
    ISNULL(likes.LikeCount, 0) AS LikeCount,
    ISNULL(comments.CommentCount, 0) AS CommentCount,
    CASE WHEN EXISTS (SELECT 1 FROM dbo.MomentLikes ml WHERE ml.MomentId = fm.Id AND ml.UserId = @ViewerUserId) THEN CAST(1 AS BIT) ELSE CAST(0 AS BIT) END AS IsLikedByCurrentUser
FROM dbo.FriendMoments fm
INNER JOIN dbo.Users u ON u.Id = fm.UserId
LEFT JOIN dbo.PlayerProfiles pp ON pp.UserId = fm.UserId
OUTER APPLY
(
    SELECT COUNT(1) AS LikeCount
    FROM dbo.MomentLikes ml
    WHERE ml.MomentId = fm.Id
) likes
OUTER APPLY
(
    SELECT COUNT(1) AS CommentCount
    FROM dbo.MomentComments mc
    WHERE mc.MomentId = fm.Id
) comments
WHERE fm.UserId = @ProfileUserId
  AND
  (
      @ViewerUserId = @ProfileUserId
      OR EXISTS
      (
          SELECT 1
          FROM dbo.Friendships f
          WHERE f.UserId = @ViewerUserId
            AND f.FriendUserId = @ProfileUserId
      )
  )
  AND NOT EXISTS
  (
      SELECT 1
      FROM dbo.UserBlocks b
      WHERE (b.UserId = @ViewerUserId AND b.BlockedUserId = @ProfileUserId)
         OR (b.UserId = @ProfileUserId AND b.BlockedUserId = @ViewerUserId)
  )
ORDER BY fm.CreatedAt DESC, fm.Id DESC;";

            var results = new List<MomentPostInfo>();
            using (var connection = DbHelper.CreateConnection())
            using (var command = new SqlCommand(sql, connection))
            {
                command.Parameters.AddWithValue("@Top", top);
                command.Parameters.AddWithValue("@ViewerUserId", viewerUserId);
                command.Parameters.AddWithValue("@ProfileUserId", profileUserId);
                connection.Open();
                using (var reader = command.ExecuteReader())
                {
                    while (reader.Read())
                    {
                        results.Add(new MomentPostInfo
                        {
                            Id = Convert.ToInt32(reader["Id"]),
                            UserId = Convert.ToInt32(reader["UserId"]),
                            DisplayName = Convert.ToString(reader["DisplayName"]),
                            AvatarUrl = Convert.ToString(reader["AvatarUrl"]),
                            Content = Convert.ToString(reader["Content"]),
                            ImageUrl = Convert.ToString(reader["ImageUrl"]),
                            LocationText = Convert.ToString(reader["LocationText"]),
                            Visibility = Convert.ToString(reader["Visibility"]),
                            LikeCount = Convert.ToInt32(reader["LikeCount"]),
                            CommentCount = Convert.ToInt32(reader["CommentCount"]),
                            IsLikedByCurrentUser = Convert.ToBoolean(reader["IsLikedByCurrentUser"]),
                            CreatedAt = Convert.ToDateTime(reader["CreatedAt"])
                        });
                    }
                }
            }

            return results;
        }

        public bool SendGameInvite(int senderUserId, int receiverUserId, int scriptId, out string message)
        {
            var contentRepository = new ContentRepository();
            var script = contentRepository.GetScriptDetail(scriptId);
            if (script == null)
            {
                message = "未找到可邀请的剧本。";
                return false;
            }

            var inviteText = "邀请你一起预约《" + script.Name + "》";
            var inviteLink = "Booking.aspx?scriptId=" + script.Id;
            return SendFriendMessage(senderUserId, receiverUserId, "GameInvite", inviteText, inviteLink, string.Empty, out message);
        }

        private IList<int> GetConversationPreferenceFriendIds(int userId, string columnName)
        {
            var safeColumn = string.Equals(columnName, "IsPinned", StringComparison.OrdinalIgnoreCase) ? "IsPinned" : "IsHidden";
            var sql = @"
SELECT FriendUserId
FROM dbo.FriendConversationPreferences
WHERE UserId = @UserId
  AND " + safeColumn + @" = 1;";

            var results = new List<int>();
            using (var connection = DbHelper.CreateConnection())
            using (var command = new SqlCommand(sql, connection))
            {
                command.Parameters.AddWithValue("@UserId", userId);
                connection.Open();
                using (var reader = command.ExecuteReader())
                {
                    while (reader.Read())
                    {
                        results.Add(Convert.ToInt32(reader["FriendUserId"]));
                    }
                }
            }

            return results;
        }

        private bool SaveConversationPreference(int userId, int friendUserId, bool? isPinned, bool? isHidden, string successMessage, out string message)
        {
            const string sql = @"
IF NOT EXISTS (SELECT 1 FROM dbo.Friendships WHERE UserId = @UserId AND FriendUserId = @FriendUserId)
BEGIN
    RAISERROR(N'当前好友关系不存在。', 16, 1);
    RETURN;
END;

IF EXISTS (SELECT 1 FROM dbo.FriendConversationPreferences WHERE UserId = @UserId AND FriendUserId = @FriendUserId)
BEGIN
    UPDATE dbo.FriendConversationPreferences
    SET IsPinned = COALESCE(@IsPinned, IsPinned),
        IsHidden = COALESCE(@IsHidden, IsHidden),
        UpdatedAt = GETDATE()
    WHERE UserId = @UserId
      AND FriendUserId = @FriendUserId;
END
ELSE
BEGIN
    INSERT INTO dbo.FriendConversationPreferences(UserId, FriendUserId, IsPinned, IsHidden, CreatedAt, UpdatedAt)
    VALUES(@UserId, @FriendUserId, COALESCE(@IsPinned, 0), COALESCE(@IsHidden, 0), GETDATE(), GETDATE());
END;";

            using (var connection = DbHelper.CreateConnection())
            using (var command = new SqlCommand(sql, connection))
            {
                command.Parameters.AddWithValue("@UserId", userId);
                command.Parameters.AddWithValue("@FriendUserId", friendUserId);
                command.Parameters.AddWithValue("@IsPinned", isPinned.HasValue ? (object)isPinned.Value : DBNull.Value);
                command.Parameters.AddWithValue("@IsHidden", isHidden.HasValue ? (object)isHidden.Value : DBNull.Value);
                connection.Open();
                try
                {
                    command.ExecuteNonQuery();
                    message = successMessage;
                    return true;
                }
                catch (SqlException ex)
                {
                    message = ex.Message;
                    return false;
                }
            }
        }

        private static IList<GiftTransactionInfo> GetGiftTransactions(string sql, int userId, int top)
        {
            var results = new List<GiftTransactionInfo>();
            using (var connection = DbHelper.CreateConnection())
            using (var command = new SqlCommand(sql, connection))
            {
                command.Parameters.AddWithValue("@Top", top);
                command.Parameters.AddWithValue("@UserId", userId);
                connection.Open();
                using (var reader = command.ExecuteReader())
                {
                    while (reader.Read())
                    {
                        results.Add(new GiftTransactionInfo
                        {
                            Id = Convert.ToInt32(reader["Id"]),
                            SenderUserId = Convert.ToInt32(reader["SenderUserId"]),
                            SenderDisplayName = Convert.ToString(reader["SenderDisplayName"]),
                            ReceiverUserId = Convert.ToInt32(reader["ReceiverUserId"]),
                            ReceiverDisplayName = Convert.ToString(reader["ReceiverDisplayName"]),
                            GiftName = Convert.ToString(reader["GiftName"]),
                            GiftIconText = Convert.ToString(reader["IconText"]),
                            Quantity = Convert.ToInt32(reader["Quantity"]),
                            TotalCoins = Convert.ToInt32(reader["TotalCoins"]),
                            Summary = reader["Summary"] == DBNull.Value ? string.Empty : Convert.ToString(reader["Summary"]),
                            CreatedAt = Convert.ToDateTime(reader["CreatedAt"])
                        });
                    }
                }
            }

            return results;
        }

        private static IList<FriendRequestInfo> GetFriendRequests(string sql, int userId)
        {
            var results = new List<FriendRequestInfo>();
            using (var connection = DbHelper.CreateConnection())
            using (var command = new SqlCommand(sql, connection))
            {
                command.Parameters.AddWithValue("@UserId", userId);
                connection.Open();
                using (var reader = command.ExecuteReader())
                {
                    while (reader.Read())
                    {
                        results.Add(new FriendRequestInfo
                        {
                            Id = Convert.ToInt32(reader["Id"]),
                            SenderUserId = Convert.ToInt32(reader["SenderUserId"]),
                            SenderDisplayName = Convert.ToString(reader["SenderDisplayName"]),
                            SenderPublicUserCode = GetString(reader, "SenderPublicUserCode"),
                            SenderAvatarUrl = GetString(reader, "SenderAvatarUrl"),
                            ReceiverUserId = Convert.ToInt32(reader["ReceiverUserId"]),
                            ReceiverDisplayName = Convert.ToString(reader["ReceiverDisplayName"]),
                            ReceiverPublicUserCode = GetString(reader, "ReceiverPublicUserCode"),
                            RequestMessage = reader["RequestMessage"] == DBNull.Value ? string.Empty : Convert.ToString(reader["RequestMessage"]),
                            Status = Convert.ToString(reader["Status"]),
                            CreatedAt = Convert.ToDateTime(reader["CreatedAt"]),
                            ReviewedAt = reader["ReviewedAt"] == DBNull.Value ? (DateTime?)null : Convert.ToDateTime(reader["ReviewedAt"])
                        });
                    }
                }
            }

            return results;
        }

        private static UserAccountInfo MapUser(SqlDataReader reader)
        {
            return new UserAccountInfo
            {
                Id = Convert.ToInt32(reader["Id"]),
                Username = Convert.ToString(reader["Username"]),
                DisplayName = Convert.ToString(reader["DisplayName"]),
                PublicUserCode = GetString(reader, "PublicUserCode"),
                Email = Convert.ToString(reader["Email"]),
                Phone = Convert.ToString(reader["Phone"]),
                Balance = reader["Balance"] == DBNull.Value ? 0M : Convert.ToDecimal(reader["Balance"]),
                RoleCode = Convert.ToString(reader["RoleCode"]),
                ReviewStatus = Convert.ToString(reader["ReviewStatus"]),
                ReviewRemark = reader["ReviewRemark"] == DBNull.Value ? string.Empty : Convert.ToString(reader["ReviewRemark"]),
                CreatedAt = Convert.ToDateTime(reader["CreatedAt"]),
                ReviewedAt = reader["ReviewedAt"] == DBNull.Value ? (DateTime?)null : Convert.ToDateTime(reader["ReviewedAt"])
            };
        }

        private static string NormalizePublicUserCode(string publicUserCode)
        {
            return (publicUserCode ?? string.Empty).Trim().ToUpperInvariant();
        }

        private static string NormalizeMomentVisibility(string visibility)
        {
            switch ((visibility ?? string.Empty).Trim())
            {
                case "Public":
                    return "Public";
                case "Private":
                    return "Private";
                default:
                    return "Friends";
            }
        }

        private static bool IsValidPublicUserCode(string publicUserCode)
        {
            if (string.IsNullOrWhiteSpace(publicUserCode) || publicUserCode.Length < 4 || publicUserCode.Length > 20)
            {
                return false;
            }

            foreach (var ch in publicUserCode)
            {
                if (!(char.IsLetterOrDigit(ch) || ch == '_'))
                {
                    return false;
                }
            }

            return true;
        }

        private static string GetString(SqlDataReader reader, string columnName)
        {
            for (var i = 0; i < reader.FieldCount; i++)
            {
                if (string.Equals(reader.GetName(i), columnName, StringComparison.OrdinalIgnoreCase))
                {
                    return reader.IsDBNull(i) ? string.Empty : Convert.ToString(reader.GetValue(i));
                }
            }

            return string.Empty;
        }

        private static RechargeRequestInfo MapRechargeRequest(SqlDataReader reader)
        {
            var paymentAccount = reader["PaymentAccount"] == DBNull.Value ? string.Empty : Convert.ToString(reader["PaymentAccount"]);
            return new RechargeRequestInfo
            {
                Id = Convert.ToInt32(reader["Id"]),
                UserId = Convert.ToInt32(reader["UserId"]),
                Username = Convert.ToString(reader["Username"]),
                DisplayName = Convert.ToString(reader["DisplayName"]),
                PaymentMethod = Convert.ToString(reader["PaymentMethod"]),
                Amount = Convert.ToDecimal(reader["Amount"]),
                PaymentAccount = paymentAccount,
                PaymentAccountMasked = MaskPaymentAccount(Convert.ToString(reader["PaymentMethod"]), paymentAccount),
                RequestStatus = Convert.ToString(reader["RequestStatus"]),
                ReviewRemark = reader["ReviewRemark"] == DBNull.Value ? string.Empty : Convert.ToString(reader["ReviewRemark"]),
                SubmittedAt = Convert.ToDateTime(reader["SubmittedAt"]),
                ReviewedAt = reader["ReviewedAt"] == DBNull.Value ? (DateTime?)null : Convert.ToDateTime(reader["ReviewedAt"])
            };
        }

        private static string MaskPaymentAccount(string paymentMethod, string paymentAccount)
        {
            if (string.IsNullOrWhiteSpace(paymentAccount))
            {
                return paymentMethod == "WeChat" ? "微信快捷充值" : paymentMethod == "ScanCode" ? "扫码支付" : string.Empty;
            }

            if (paymentAccount.Length <= 8)
            {
                return paymentAccount;
            }

            return paymentAccount.Substring(0, 4) + " **** **** " + paymentAccount.Substring(paymentAccount.Length - 4);
        }
    }
}
