function notification -d 'Windows notification'
    argparse 't/title=' 'b/body=' -- $argv
    or return

    set kernel (uname --kernel-release)
    if not string match --quiet --regex 'microsoft.*WSL' $kernel
        echo "Not Windows, skipping..."
        return
    end

    if set -q _flag_body
        set bodyText $_flag_body
    else
        set bodyText ""
    end

    if set --query _flag_title
        set titleText $_flag_title
    else
        echo "Usage: notification -t <title> -b <body>"
        return
    end

    powershell.exe '
    $titleText = "'$titleText'"
    $bodyText = "'$bodyText'"

    [Windows.UI.Notifications.ToastNotificationManager, Windows.UI.Notifications, ContentType = WindowsRuntime] > $null
    $template = [Windows.UI.Notifications.ToastNotificationManager]::GetTemplateContent([Windows.UI.Notifications.ToastTemplateType]::ToastText02)

    # Convert to .NET type for XML manipulation
    $toastXml = [xml] $template.GetXml()

    $subjectNode = $toastXml.GetElementsByTagName("text")[0]
    $bodyNode = $toastXml.GetElementsByTagName("text")[1]
    $subjectNode.AppendChild($toastXml.CreateTextNode($titleText)) > $null
    $bodyNode.AppendChild($toastXml.CreateTextNode($bodyText)) > $null

    # Convert back to WinRT type
    $xml = New-Object Windows.Data.Xml.Dom.XmlDocument
    $xml.LoadXml($toastXml.OuterXml)

    $toast = [Windows.UI.Notifications.ToastNotification]::new($xml)
    $toast.Tag = "PowerShell"
    $toast.Group = "PowerShell"
    $toast.ExpirationTime = [DateTimeOffset]::Now.AddMinutes(5)

    [Windows.UI.Notifications.ToastNotificationManager]::CreateToastNotifier("PowerShell").Show($toast)
    '
end
