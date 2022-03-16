function New-XmlSchema
{
    [CmdletBinding()]
    Param
    (
        [Parameter(Mandatory)]
        [ValidateScript({ Test-Path -Path $_ })]
        [ValidatePattern('\.kml')]
        [string]$XmlExample
    ) 

    $item = Get-Item $XmlExample
    $dir = $item.Directory
    $name = $item.Name
    $baseName = $item.BaseName

    ## build the schema path by replacing '.xml' with '.xsd'
    $SchemaPath = "$dir\$baseName.xsd"

    try
    {
        $dataSet = New-Object -TypeName System.Data.DataSet
        $dataSet.ReadXml($XmlExample) | Out-Null
        $dataSet.WriteXmlSchema($SchemaPath)
        
        ## show the resulted schema file
        Get-Item $SchemaPath
    }
    catch
    {
        $err = $_.Exception.Message
        Write-Host "Failed to create XML schema for $XmlExample`nDetails: $err" -ForegroundColor Red
    }
}

New-XmlSchema -XmlExample 'E:\GPS\SierraPeaksSectionGarmin.kml'