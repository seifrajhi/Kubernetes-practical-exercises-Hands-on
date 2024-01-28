function Convert-ToBase64 {
	param (
		[parameter(ValueFromPipeline)]
		[string] $text,
		[switch] $d
	)
	if ($d){
		[Text.Encoding]::UTF8.GetString([Convert]::FromBase64String($text))
	}
	else {
		[Convert]::ToBase64String([System.Text.Encoding]::UTF8.GetBytes($text))
	}
}

# base64
Set-Alias base64  Convert-ToBase64

# grep
Set-Alias -Name grep -Value Select-String

# use the real curl
Remove-Item Alias:curl -ErrorAction Ignore
