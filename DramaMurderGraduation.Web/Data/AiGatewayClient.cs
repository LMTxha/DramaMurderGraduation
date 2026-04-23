using System;
using System.Collections.Generic;
using System.Configuration;
using System.Diagnostics;
using System.IO;
using System.Linq;
using System.Net;
using System.Text;
using System.Web.Script.Serialization;
using DramaMurderGraduation.Web.Models;

namespace DramaMurderGraduation.Web.Data
{
    public class AiGatewayClient
    {
        private const string DefaultSystemPrompt = "你是雾城剧本研究所内置的 AI 助手。回答要直接、准确、可执行，优先使用中文，适合玩家选本、门店运营、预约沟通、文案生成和问题检索场景。";

        public IList<AiProviderOptionInfo> GetProviders()
        {
            return new List<AiProviderOptionInfo>
            {
                BuildProvider("nvidia", "NVIDIA NIM", "NVIDIA", "AiNvidiaBaseUrl", "AiNvidiaApiKey", "AiNvidiaDefaultModel", "qwen/qwen2.5-coder-32b-instruct"),
                BuildProvider("doubao", "豆包", "火山引擎", "AiDoubaoBaseUrl", "AiDoubaoApiKey", "AiDoubaoDefaultModel", "doubao-pro-32k"),
                BuildProvider("kimi", "Kimi", "Moonshot", "AiKimiBaseUrl", "AiKimiApiKey", "AiKimiDefaultModel", "moonshot-v1-8k"),
                BuildProvider("qwen-cn", "Qwen", "北京", "AiQwenCnBaseUrl", "AiQwenCnApiKey", "AiQwenCnDefaultModel", "qwen-plus"),
                BuildProvider("qwen-intl", "Qwen", "新加坡", "AiQwenIntlBaseUrl", "AiQwenIntlApiKey", "AiQwenIntlDefaultModel", "qwen-plus"),
                BuildProvider("qwen-us", "Qwen", "美东", "AiQwenUsBaseUrl", "AiQwenUsApiKey", "AiQwenUsDefaultModel", "qwen-plus"),
                BuildProvider("zhipu", "智谱", "GLM", "AiZhipuBaseUrl", "AiZhipuApiKey", "AiZhipuDefaultModel", "glm-4-plus"),
                BuildProvider("deepseek", "DeepSeek", "DeepSeek", "AiDeepSeekBaseUrl", "AiDeepSeekApiKey", "AiDeepSeekDefaultModel", "deepseek-chat"),
                BuildProvider("tencent-yuanbao", "腾讯元宝", "腾讯", "AiTencentYuanbaoBaseUrl", "AiTencentYuanbaoApiKey", "AiTencentYuanbaoDefaultModel", "hunyuan-turbos-latest")
            };
        }

        public AiResponseInfo AskQuestion(string providerKey, string model, string prompt, bool deepThinking, IEnumerable<AiConversationEntryInfo> history)
        {
            var provider = GetProviders().FirstOrDefault(item => string.Equals(item.Key, providerKey, StringComparison.OrdinalIgnoreCase));
            if (provider == null)
            {
                return new AiResponseInfo { Success = false, ErrorMessage = "未找到所选 AI 提供商。" };
            }

            var selectedModel = string.IsNullOrWhiteSpace(model) ? provider.DefaultModel : model.Trim();
            if (string.IsNullOrWhiteSpace(provider.BaseUrl))
            {
                return new AiResponseInfo { Success = false, ProviderDisplayName = provider.DisplayName, Model = selectedModel, ErrorMessage = provider.DisplayName + " 的 base_url 未配置，请先在 Web.config 中补齐。" };
            }

            if (!provider.Enabled)
            {
                return new AiResponseInfo { Success = false, ProviderDisplayName = provider.DisplayName, Model = selectedModel, ErrorMessage = provider.DisplayName + " 的 API Key 未配置，请先在 Web.config 中填写。" };
            }

            if (string.IsNullOrWhiteSpace(prompt))
            {
                return new AiResponseInfo { Success = false, ProviderDisplayName = provider.DisplayName, Model = selectedModel, ErrorMessage = "请输入你要咨询的问题。" };
            }

            var stopwatch = Stopwatch.StartNew();
            var serializer = new JavaScriptSerializer { MaxJsonLength = int.MaxValue };
            var payload = new Dictionary<string, object>
            {
                { "model", selectedModel },
                { "messages", BuildMessages(history, prompt, deepThinking) },
                { "temperature", string.Equals(provider.Key, "nvidia", StringComparison.OrdinalIgnoreCase) ? 0.2 : (deepThinking ? 0.5 : 0.7) },
                { "stream", false }
            };
            if (string.Equals(provider.Key, "nvidia", StringComparison.OrdinalIgnoreCase))
            {
                payload["top_p"] = 0.7;
                payload["max_tokens"] = 1024;
            }

            try
            {
                ServicePointManager.SecurityProtocol = SecurityProtocolType.Tls12;
                var request = (HttpWebRequest)WebRequest.Create(BuildChatCompletionsUrl(provider.BaseUrl));
                request.Method = "POST";
                request.ContentType = "application/json";
                request.Accept = "application/json";
                request.Headers[HttpRequestHeader.Authorization] = "Bearer " + provider.ApiKey;
                request.UserAgent = "DramaMurderGraduation-AI";
                request.Timeout = 90000;
                request.ReadWriteTimeout = 90000;

                var requestBody = Encoding.UTF8.GetBytes(serializer.Serialize(payload));
                using (var requestStream = request.GetRequestStream())
                {
                    requestStream.Write(requestBody, 0, requestBody.Length);
                }

                using (var response = (HttpWebResponse)request.GetResponse())
                using (var responseStream = response.GetResponseStream())
                using (var reader = new StreamReader(responseStream ?? Stream.Null, Encoding.UTF8))
                {
                    var responseText = reader.ReadToEnd();
                    var content = ExtractAssistantContent(serializer.DeserializeObject(responseText));
                    stopwatch.Stop();

                    if (string.IsNullOrWhiteSpace(content))
                    {
                        return new AiResponseInfo { Success = false, ProviderDisplayName = provider.DisplayName, Model = selectedModel, DurationMs = stopwatch.ElapsedMilliseconds, ErrorMessage = "AI 已返回响应，但没有解析到可展示的内容。" };
                    }

                    return new AiResponseInfo { Success = true, ProviderDisplayName = provider.DisplayName, Model = selectedModel, DurationMs = stopwatch.ElapsedMilliseconds, Content = content.Trim() };
                }
            }
            catch (WebException ex)
            {
                stopwatch.Stop();
                return new AiResponseInfo { Success = false, ProviderDisplayName = provider.DisplayName, Model = selectedModel, DurationMs = stopwatch.ElapsedMilliseconds, ErrorMessage = ReadErrorMessage(ex, serializer) };
            }
            catch (Exception ex)
            {
                stopwatch.Stop();
                return new AiResponseInfo { Success = false, ProviderDisplayName = provider.DisplayName, Model = selectedModel, DurationMs = stopwatch.ElapsedMilliseconds, ErrorMessage = "AI 请求失败：" + ex.Message };
            }
        }

        private static AiProviderOptionInfo BuildProvider(string key, string displayName, string regionLabel, string baseUrlKey, string apiKeyKey, string modelKey, string fallbackModel)
        {
            return new AiProviderOptionInfo
            {
                Key = key,
                DisplayName = displayName,
                RegionLabel = regionLabel,
                BaseUrl = ConfigurationManager.AppSettings[baseUrlKey],
                ApiKey = ConfigurationManager.AppSettings[apiKeyKey],
                DefaultModel = string.IsNullOrWhiteSpace(ConfigurationManager.AppSettings[modelKey]) ? fallbackModel : ConfigurationManager.AppSettings[modelKey]
            };
        }

        private static string BuildChatCompletionsUrl(string baseUrl)
        {
            return (baseUrl ?? string.Empty).Trim().TrimEnd('/') + "/chat/completions";
        }
        private static List<Dictionary<string, object>> BuildMessages(IEnumerable<AiConversationEntryInfo> history, string prompt, bool deepThinking)
        {
            var messages = new List<Dictionary<string, object>>
            {
                new Dictionary<string, object> { { "role", "system" }, { "content", BuildSystemPrompt(deepThinking) } }
            };

            if (history != null)
            {
                var usableHistory = history.Where(x => !x.IsError && (x.Role == "user" || x.Role == "assistant")).ToList();
                foreach (var item in usableHistory.Skip(Math.Max(0, usableHistory.Count - 8)))
                {
                    messages.Add(new Dictionary<string, object> { { "role", item.Role }, { "content", item.Content ?? string.Empty } });
                }
            }

            messages.Add(new Dictionary<string, object> { { "role", "user" }, { "content", prompt } });
            return messages;
        }

        private static string BuildSystemPrompt(bool deepThinking)
        {
            var configured = ConfigurationManager.AppSettings["AiDefaultSystemPrompt"];
            var prompt = string.IsNullOrWhiteSpace(configured) ? DefaultSystemPrompt : configured.Trim();
            return deepThinking ? prompt + " 回答前先拆解问题，列出关键假设，给出分步推理和明确建议。" : prompt;
        }

        private static string ReadErrorMessage(WebException ex, JavaScriptSerializer serializer)
        {
            if (ex.Response == null)
            {
                return "AI 请求失败：" + ex.Message;
            }

            using (var stream = ex.Response.GetResponseStream())
            using (var reader = new StreamReader(stream ?? Stream.Null, Encoding.UTF8))
            {
                var body = reader.ReadToEnd();
                if (string.IsNullOrWhiteSpace(body))
                {
                    return "AI 请求失败：" + ex.Message;
                }

                try
                {
                    var root = serializer.DeserializeObject(body) as Dictionary<string, object>;
                    if (root != null && root.ContainsKey("error"))
                    {
                        var error = root["error"] as Dictionary<string, object>;
                        if (error != null && error.ContainsKey("message"))
                        {
                            return Convert.ToString(error["message"]);
                        }
                    }
                }
                catch
                {
                }

                return body;
            }
        }
        private static string ExtractAssistantContent(object rootObject)
        {
            var root = rootObject as Dictionary<string, object>;
            if (root == null || !root.ContainsKey("choices"))
            {
                return string.Empty;
            }

            var choices = root["choices"] as object[];
            if (choices == null || choices.Length == 0)
            {
                return string.Empty;
            }

            var firstChoice = choices[0] as Dictionary<string, object>;
            if (firstChoice == null || !firstChoice.ContainsKey("message"))
            {
                return string.Empty;
            }

            var message = firstChoice["message"] as Dictionary<string, object>;
            if (message == null)
            {
                return string.Empty;
            }

            if (message.ContainsKey("content"))
            {
                return NormalizeContent(message["content"]);
            }

            if (message.ContainsKey("reasoning_content"))
            {
                return NormalizeContent(message["reasoning_content"]);
            }

            return string.Empty;
        }

        private static string NormalizeContent(object content)
        {
            if (content == null)
            {
                return string.Empty;
            }

            var text = content as string;
            if (!string.IsNullOrWhiteSpace(text))
            {
                return text;
            }

            var contentArray = content as object[];
            if (contentArray == null || contentArray.Length == 0)
            {
                return Convert.ToString(content) ?? string.Empty;
            }

            var builder = new StringBuilder();
            foreach (var item in contentArray)
            {
                var dictionary = item as Dictionary<string, object>;
                if (dictionary == null)
                {
                    var rawText = Convert.ToString(item);
                    if (!string.IsNullOrWhiteSpace(rawText))
                    {
                        builder.AppendLine(rawText);
                    }
                    continue;
                }

                if (dictionary.ContainsKey("text"))
                {
                    builder.AppendLine(Convert.ToString(dictionary["text"]));
                }
                else if (dictionary.ContainsKey("content"))
                {
                    builder.AppendLine(Convert.ToString(dictionary["content"]));
                }
            }

            return builder.ToString().Trim();
        }
    }
}
