# Settings
$url = "https://peakbagger.com/list.aspx?lid=21319&cid=20972"
$exportDir = "E:\GPS\"
$exportName = "peakbaggerlist"


$lid = ($url -Split {$_ -eq "=" -or $_ -eq "&" -or $_ -eq "?"})[2]
cd $exportDir

[xml]$xml = Invoke-WebRequest "https://peakbagger.com/Async/LLL.aspx?lid=$lid"

$xml.ts.t | ForEach-Object {
    [pscustomobject]@{
        Name = $_.n
        Latitude = $_.a
        Longitude = $_.o
    }
}

$kml = 

@"
<?xml version="1.0" encoding="utf-8"?>
<kml xmlns="http://www.opengis.net/kml/2.2" xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" xmlns:kmlx="http://www.google.com/kml/ext/2.2" xmlns:atom="http://www.w3.org/2005/Atom" xmlns:gpxx="http://www.garmin.com/xmlschemas/GpxExtensions/v3">
<Document>
	<Style id="point">
		<IconStyle>
			<scale>0.9</scale>
			<Icon>
				<href>http://maps.google.com/mapfiles/kml/shapes/placemark_circle.png</href>
			</Icon>
		</IconStyle>
	</Style>
	<Folder>
		<name>Waypoints</name>
        $(
            $xml.ts.t | ForEach-Object {
		        '<Placemark>
			        <name>{0}</name>
			        <Style>
				        <IconStyle>
					        <scale>0.9</scale>
					        <Icon>
						        <href>http://maps.google.com/mapfiles/kml/pushpin/blue-pushpin.png</href>
					        </Icon>
				        </IconStyle>
			        </Style>
			        <Point>
				        <extrude>0</extrude>
				        <altitudeMode>clampToGround</altitudeMode>
				        <coordinates>{1},{2}</coordinates>
			        </Point>
		        </Placemark>
                ' -f $_.n, $_.o, $_.a
            }
        )
    </Folder>
</Document>
</kml>
"@

$kml | Out-File -Force -Encoding ascii ( "$exportDir$exportName.kml")