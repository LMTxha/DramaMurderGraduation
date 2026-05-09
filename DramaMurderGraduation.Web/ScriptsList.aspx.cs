using System;
using System.Web.UI.WebControls;
using DramaMurderGraduation.Web.Data;

namespace DramaMurderGraduation.Web
{
    /// <summary>
    /// ScriptsList.aspx 页面后台逻辑，负责当前 Web Forms 页面的权限校验、数据绑定和事件处理。
    /// </summary>
    public partial class ScriptsListPage : System.Web.UI.Page
    {
        private readonly ContentRepository _repository = new ContentRepository();

        /// <summary>
        /// 页面生命周期入口，负责权限校验和首次加载时的数据初始化。
        /// </summary>
        protected void Page_Load(object sender, EventArgs e)
        {
            if (!IsPostBack)
            {
                BindGenres();
                BindScripts();
            }
        }

        /// <summary>
        /// 处理页面按钮点击事件，并根据当前表单输入刷新或提交业务数据。
        /// </summary>
        protected void btnSearch_Click(object sender, EventArgs e)
        {
            BindScripts();
        }

        /// <summary>
        /// 绑定页面展示数据到对应控件。
        /// </summary>
        private void BindGenres()
        {
            ddlGenres.Items.Clear();
            ddlGenres.Items.Add(new ListItem("全部题材", string.Empty));

            foreach (var genre in _repository.GetGenres())
            {
                ddlGenres.Items.Add(new ListItem(genre.Name, genre.Id.ToString()));
            }
        }

        /// <summary>
        /// 绑定页面展示数据到对应控件。
        /// </summary>
        private void BindScripts()
        {
            int? genreId = null;
            if (int.TryParse(ddlGenres.SelectedValue, out var parsedGenreId))
            {
                genreId = parsedGenreId;
            }

            var scripts = _repository.GetScripts(txtKeyword.Text.Trim(), genreId);
            litResultCount.Text = scripts.Count.ToString();
            rptScripts.DataSource = scripts;
            rptScripts.DataBind();
        }
    }
}
