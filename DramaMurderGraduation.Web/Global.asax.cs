using System;
using System.Web;
using DramaMurderGraduation.Web.Data;

namespace DramaMurderGraduation.Web
{
    /// <summary>
    /// ASP.NET Web Forms 应用程序入口。
    /// Global.asax 生命周期早于普通页面，用来放置全站只需要初始化一次的逻辑。
    /// </summary>
    public class Global : HttpApplication
    {
        /// <summary>
        /// 站点启动时确保数据库存在、基础表结构完整，并执行增量迁移。
        /// 如果数据库已经初始化，SqlDatabaseInitializer 内部会用锁和标记避免重复执行。
        /// </summary>
        protected void Application_Start(object sender, EventArgs e)
        {
            SqlDatabaseInitializer.EnsureDatabase();
        }
    }
}
