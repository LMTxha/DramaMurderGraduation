using System.Configuration;
using System.Data.SqlClient;

namespace DramaMurderGraduation.Web.Data
{
    public static class DbHelper
    {
        public static SqlConnection CreateConnection()
        {
            return new SqlConnection(ConfigurationManager.ConnectionStrings["DramaMurderDb"].ConnectionString);
        }
    }
}
