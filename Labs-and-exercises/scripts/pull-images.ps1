$images = $(cat images.txt)

Write-Output '* Pulling images'
foreach ($tag in $images) {
    Write-Output "** Processing tag: $tag"
    & docker pull $tag
}