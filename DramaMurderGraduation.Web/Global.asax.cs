using System;
using System.Web;
using DramaMurderGraduation.Web.Data;

namespace DramaMurderGraduation.Web
{
    public class Global : HttpApplication
    {
        protected void Application_Start(object sender, EventArgs e)
        {
            SqlDatabaseInitializer.EnsureDatabase();
        }
    }
}
