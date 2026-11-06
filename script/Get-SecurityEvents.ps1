param(
    [ValidateRange(1, 720)]
    [int]$Hours = 24,

    [string]$ExportPath
)

$EventIDs = @(4624, 4625, 4740, 4768, 4771, 4776)
$StartTime = (Get-Date).AddHours(-$Hours)

function Get-EventField {
    param(
        [xml]$EventXml,
        [string]$FieldName
    )

    $Field = $EventXml.Event.EventData.Data |
        Where-Object { $_.Name -eq $FieldName } |
        Select-Object -First 1

    if ($null -ne $Field) {
        return $Field.'#text'
    }

    return $null
}

$Events = @(
    Get-WinEvent -FilterHashtable @{
        LogName   = 'Security'
        Id        = $EventIDs
        StartTime = $StartTime
    } -ErrorAction SilentlyContinue
)

$Results = @(
    foreach ($Event in $Events) {
        [xml]$Xml = $Event.ToXml()

        $AccountField = switch ($Event.Id) {
            4740 { 'TargetUserName' }
            4771 { 'TargetUserName' }
            4776 { 'TargetUserName' }
            4768 { 'TargetUserName' }
            default { 'TargetUserName' }
        }

        $IpField = switch ($Event.Id) {
            4740 { 'CallerComputerName' }
            4771 { 'IpAddress' }
            4768 { 'IpAddress' }
            default { 'IpAddress' }
        }

        [PSCustomObject]@{
            TimeCreated = $Event.TimeCreated
            EventID     = $Event.Id
            Computer    = $Event.MachineName
            Account     = Get-EventField $Xml $AccountField
            Source      = Get-EventField $Xml $IpField
            LogonType   = Get-EventField $Xml 'LogonType'
            Status      = Get-EventField $Xml 'Status'
            SubStatus   = Get-EventField $Xml 'SubStatus'
        }
    }
)

Write-Host "`nSecurity Event Summary"

$Results |
    Group-Object EventID |
    Sort-Object Count -Descending |
    Select-Object Name, Count |
    Format-Table -AutoSize

Write-Host "`nRecent Security Events"

$Results |
    Select-Object -First 20 |
    Format-Table -AutoSize

if ($ExportPath) {
    $Results | Export-Csv -Path $ExportPath -NoTypeInformation
    Write-Host "`nCSV exported to: $ExportPath"
}
