using System;
using System.IO;
using System.Linq;
using System.Web;
using System.Web.UI.WebControls;

namespace DramaMurderGraduation.Web
{
    /// <summary>
    /// 统一处理 Web Forms 文件上传的辅助类。
    /// 负责校验附件类型和大小，并把文件保存到按业务分类和月份划分的 Uploads 目录。
    /// </summary>
    public static class UploadHelper
    {
        // 只允许项目页面实际会展示或下载的常见图片、音视频和文档格式，降低误传可执行文件的风险。
        private static readonly string[] AllowedExtensions =
        {
            ".jpg", ".jpeg", ".png", ".gif", ".webp",
            ".mp3", ".wav", ".m4a", ".aac", ".mp4", ".webm",
            ".pdf", ".doc", ".docx", ".txt"
        };

        /// <summary>
        /// 尝试保存上传控件中的文件。
        /// 没有选择文件时视为成功；校验失败时返回 false，并通过 error 给出页面可展示的错误原因。
        /// </summary>
        public static bool TrySave(FileUpload upload, string category, out string relativeUrl, out string error)
        {
            relativeUrl = string.Empty;
            error = string.Empty;

            if (upload == null || !upload.HasFile)
            {
                return true;
            }

            if (upload.PostedFile.ContentLength > 20 * 1024 * 1024)
            {
                error = "附件不能超过 20MB。";
                return false;
            }

            var extension = Path.GetExtension(upload.FileName)?.ToLowerInvariant();
            if (string.IsNullOrWhiteSpace(extension) || !AllowedExtensions.Contains(extension))
            {
                error = "附件格式不支持，请上传图片、音频、视频或常用文档。";
                return false;
            }

            var safeCategory = string.IsNullOrWhiteSpace(category) ? "common" : category.Trim();
            var monthFolder = DateTime.Now.ToString("yyyyMM");
            var virtualFolder = "~/Uploads/Friends/" + safeCategory + "/" + monthFolder;
            var absoluteFolder = HttpContext.Current.Server.MapPath(virtualFolder);
            Directory.CreateDirectory(absoluteFolder);

            var fileName = Guid.NewGuid().ToString("N") + extension;
            var absolutePath = Path.Combine(absoluteFolder, fileName);
            upload.SaveAs(absolutePath);

            relativeUrl = "Uploads/Friends/" + safeCategory + "/" + monthFolder + "/" + fileName;
            return true;
        }
    }
}
