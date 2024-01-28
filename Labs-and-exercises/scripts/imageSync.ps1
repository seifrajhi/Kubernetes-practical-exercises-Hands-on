$images = $(cat images.txt)

Write-Output '* Syncing images'
foreach ($tag in $images) {
    Write-Output "** Processing tag: $tag"
    & docker pull $tag

    $newTag = "courselabs.azurecr.io/$tag"
    Write-Output "** Tagging as: $newTag"
    & docker tag $tag $newTag
    
    Write-Output "** Pushing: $newTag"
    & docker push $newTag
}

# This copies the images used in the labs to an ACR registry
# Use for students who can't access Docker Hub
# All `image:` references in specs need to be prefixe with `courselabs.azurecr.io/`

# FOR ADMIN: to make the repo accessible
# `az acr update --name courselabs --anonymous-pull-enabled`

# And to make it private again:
# `az acr update --name courselabs --anonymous-pull-enabled false`