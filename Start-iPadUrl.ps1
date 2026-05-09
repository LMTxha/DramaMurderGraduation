param(
    [int]$IisPort = 5090,
    [int]$ProxyPort = 8090,
    [switch]$RestartIisExpress
)

$ErrorActionPreference = "Stop"

if (-not $PSBoundParameters.ContainsKey("RestartIisExpress")) {
    $RestartIisExpress = $true
}

$repoRoot = Split-Path -Parent $MyInvocation.MyCommand.Path
$webRoot = Join-Path $repoRoot "DramaMurderGraduation.Web"
$iisExpress = "${env:ProgramFiles}\IIS Express\iisexpress.exe"

if (-not (Test-Path $iisExpress)) {
    $iisExpress = "${env:ProgramFiles(x86)}\IIS Express\iisexpress.exe"
}

if (-not (Test-Path $iisExpress)) {
    throw "IIS Express was not found. Please install IIS Express or Visual Studio with web development tools."
}

if (-not (Test-Path $webRoot)) {
    throw "Web root was not found: $webRoot"
}

function Stop-ProjectIisExpress {
    Get-CimInstance Win32_Process -Filter "name='iisexpress.exe'" |
        Where-Object {
            ($_.CommandLine -like "*$webRoot*") -or
            ($_.CommandLine -match "/port:$IisPort(\s|$)")
        } |
        ForEach-Object {
            Stop-Process -Id $_.ProcessId -Force -ErrorAction SilentlyContinue
        }
}

if ($RestartIisExpress) {
    Stop-ProjectIisExpress
    Start-Sleep -Milliseconds 600
}

$ip = Get-NetIPAddress -AddressFamily IPv4 |
    Where-Object {
        $_.IPAddress -notlike "127.*" -and
        $_.InterfaceAlias -notmatch "VMware|Virtual|VPN|Radmin|Clash|Loopback|Docker|Hyper-V" -and
        $_.PrefixOrigin -ne "WellKnown"
    } |
    Sort-Object @{Expression = { if ($_.InterfaceAlias -match "WLAN|Wi-Fi|以太网|Ethernet") { 0 } else { 1 } }} |
    Select-Object -First 1 -ExpandProperty IPAddress

if (-not $ip) {
    throw "No usable LAN IPv4 address was found. Make sure this computer is connected to Wi-Fi or Ethernet."
}

$iisReady = $false
try {
    $response = Invoke-WebRequest -Uri "http://localhost:$IisPort/Login.aspx" -UseBasicParsing -TimeoutSec 3
    $iisReady = $response.StatusCode -eq 200
} catch {
    $iisReady = $false
}

if (-not $iisReady) {
    Start-Process -FilePath $iisExpress -ArgumentList "/path:`"$webRoot`"", "/port:$IisPort", "/clr:v4.0" -WindowStyle Hidden
    Start-Sleep -Seconds 3
}

$source = @"
using System;
using System.IO;
using System.Linq;
using System.Net;
using System.Net.Sockets;
using System.Text;
using System.Threading.Tasks;

public sealed class LanHttpProxy
{
    private readonly int listenPort;
    private readonly string targetHost;
    private readonly int targetPort;
    private TcpListener listener;

    public LanHttpProxy(int listenPort, string targetHost, int targetPort)
    {
        this.listenPort = listenPort;
        this.targetHost = targetHost;
        this.targetPort = targetPort;
    }

    public void Start()
    {
        listener = new TcpListener(IPAddress.Any, listenPort);
        listener.Start();

        while (true)
        {
            var client = listener.AcceptTcpClient();
            Task.Run(() => Handle(client));
        }
    }

    private void Handle(TcpClient client)
    {
        using (client)
        using (var upstream = new TcpClient())
        {
            upstream.Connect(targetHost, targetPort);

            var clientStream = client.GetStream();
            var upstreamStream = upstream.GetStream();
            var firstRequest = ReadHeaderAndBufferedBody(clientStream);

            if (firstRequest.Length == 0)
            {
                return;
            }

            var requestText = Encoding.GetEncoding("ISO-8859-1").GetString(firstRequest);
            var headerEnd = requestText.IndexOf("\r\n\r\n", StringComparison.Ordinal);
            if (headerEnd >= 0)
            {
                var header = requestText.Substring(0, headerEnd);
                var body = requestText.Substring(headerEnd + 4);
                var lines = header.Split(new[] { "\r\n" }, StringSplitOptions.None).ToList();
                var hostIndex = lines.FindIndex(x => x.StartsWith("Host:", StringComparison.OrdinalIgnoreCase));
                if (hostIndex >= 0)
                {
                    lines[hostIndex] = "Host: localhost:" + targetPort;
                }
                else
                {
                    lines.Insert(1, "Host: localhost:" + targetPort);
                }

                requestText = string.Join("\r\n", lines) + "\r\n\r\n" + body;
                firstRequest = Encoding.GetEncoding("ISO-8859-1").GetBytes(requestText);
            }

            upstreamStream.Write(firstRequest, 0, firstRequest.Length);

            var clientToServer = Task.Run(() => CopyStream(clientStream, upstreamStream));
            var serverToClient = Task.Run(() => CopyStream(upstreamStream, clientStream));
            Task.WaitAny(clientToServer, serverToClient);
        }
    }

    private static byte[] ReadHeaderAndBufferedBody(NetworkStream stream)
    {
        var buffer = new byte[8192];
        using (var memory = new MemoryStream())
        {
            while (true)
            {
                var read = stream.Read(buffer, 0, buffer.Length);
                if (read <= 0)
                {
                    break;
                }

                memory.Write(buffer, 0, read);
                var bytes = memory.ToArray();
                if (FindHeaderEnd(bytes) >= 0)
                {
                    return bytes;
                }
            }

            return memory.ToArray();
        }
    }

    private static int FindHeaderEnd(byte[] bytes)
    {
        for (var i = 0; i <= bytes.Length - 4; i++)
        {
            if (bytes[i] == 13 && bytes[i + 1] == 10 && bytes[i + 2] == 13 && bytes[i + 3] == 10)
            {
                return i;
            }
        }

        return -1;
    }

    private static void CopyStream(Stream input, Stream output)
    {
        var buffer = new byte[81920];
        try
        {
            while (true)
            {
                var read = input.Read(buffer, 0, buffer.Length);
                if (read <= 0)
                {
                    return;
                }

                output.Write(buffer, 0, read);
            }
        }
        catch
        {
        }
    }
}
"@

if (-not ([System.Management.Automation.PSTypeName]"LanHttpProxy").Type) {
    Add-Type -TypeDefinition $source
}

$url = "http://$ip`:$ProxyPort/Login.aspx"
Write-Host ""
Write-Host "Open this URL on iPad:"
Write-Host $url
Write-Host ""
Write-Host "Keep this PowerShell window open while testing."
Write-Host ""

$proxy = [LanHttpProxy]::new($ProxyPort, "localhost", $IisPort)
$proxy.Start()
