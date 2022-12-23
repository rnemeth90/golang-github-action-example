# Summary

Basic Go http web server running on port 8080 used to illustrate GitHub Actions as Continuous Deployment pipeline.

# GitHub Workflow for building OCI image

[github-actions-buildOCI.yml](.github/workflows/github-actions-buildOCI.yml) creates an Image base on busybox:glibc using [Dockerfile](dockerfile).

This is triggered by creating a tag that looks like the semantic tag that starts with "v" (e.g. vX.Y.Z)

```
newtag=v1.0.1; git tag $newtag && git push origin $newtag
```

The image is published at these locations:
* [Docker Hub](https://hub.docker.com/r/ryannemeth/golang-github-action-example)


# Github Workflow for creating static binary release

[github-actions-release.yml](.github/workflows/github-actions-release.yml) creates a statically compiled GoLang binary along with Release Notes consisting of the recent git commit messages.

This is triggered by creating a tag that looks like the semantic tag that starts with "r" (e.g. rX.Y.Z)

```
newtag=r1.0.1; git tag $newtag && git push origin $newtag
```


# Creating tag

```
newtag=v1.0.1
git commit -a -m "changes for new tag $newtag" && git push
git tag $newtag && git push origin $newtag
```

# Deleting tag

```
# delete local tag, then remote
todel=v1.0.1
git tag -d $todel && git push origin :refs/tags/$todel
```

# Deleting release

```
todel=r1.0.1

# delete release and remote tag
gh release delete $todel --cleanup-tag -y

# delete local tag
git tag -d $todel
```