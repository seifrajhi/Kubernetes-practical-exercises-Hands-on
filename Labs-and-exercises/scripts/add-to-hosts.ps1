param (
	[string] $domain,
	[string] $ip='127.0.0.1'
)

if ($ip -eq 'localhost') {
	$ip='127.0.0.1'
}

Add-Content -Value "$ip  $domain" -Path C:/windows/system32/drivers/etc/hosts