# test-changesets
test changesets for version management

## Lessons learned
- When creating the project for the first time, set the version in package.json to 0.0.0.
- The github action requires the following permissions
```
 contents: write
      pull-requests: write
      packages: write
```
- The github action also requires the permission to create pull requests 
project settings -> actions -> General -> Workflow permissions -> Choose whether GitHub Actions can create pull requests or submit approving pull request reviews.