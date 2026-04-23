using System;
using System.Web.UI.WebControls;
using DramaMurderGraduation.Web.Data;

namespace DramaMurderGraduation.Web
{
    public partial class ScriptsListPage : System.Web.UI.Page
    {
        private readonly ContentRepository _repository = new ContentRepository();

        protected void Page_Load(object sender, EventArgs e)
        {
            if (!IsPostBack)
            {
                BindGenres();
                BindScripts();
            }
        }

        protected void btnSearch_Click(object sender, EventArgs e)
        {
            BindScripts();
        }

        private void BindGenres()
        {
            ddlGenres.Items.Clear();
            ddlGenres.Items.Add(new ListItem("全部题材", string.Empty));

            foreach (var genre in _repository.GetGenres())
            {
                ddlGenres.Items.Add(new ListItem(genre.Name, genre.Id.ToString()));
            }
        }

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
