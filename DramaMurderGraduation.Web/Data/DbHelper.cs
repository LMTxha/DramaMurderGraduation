using System.Configuration;
using System.Data.SqlClient;

namespace DramaMurderGraduation.Web.Data
{
    /// <summary>
    /// 数据库连接工厂。
    /// 项目中的仓储类都通过这里创建 SqlConnection，连接字符串统一来自 Web.config 的 DramaMurderDb。
    /// 这样后续切换 LocalDB、远程 SQL Server 或调整连接参数时，只需要维护配置文件。
    /// </summary>
    public static class DbHelper
    {
        /// <summary>
        /// 创建一个尚未打开的 SQL Server 连接。
        /// 调用方负责使用 using 释放连接，并在真正执行命令前调用 Open()。
        /// </summary>
        public static SqlConnection CreateConnection()
        {
            return new SqlConnection(ConfigurationManager.ConnectionStrings["DramaMurderDb"].ConnectionString);
        }
    }
}
