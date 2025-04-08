# test-changesets
> test changesets for version management
> src: https://github.com/changesets/changesets

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

## Init changesets for first time use
 `npx @changesets/cli init`

## Adding a changeset
`npx changeset`

## Enable automerge
[src](https://github.com/changesets/action/issues/310#issuecomment-2770423999)
- enable automerge for the repo in settings.
- update the github action to toggle the auto merge when checks complete

```yml
- name: Enable auto-merge for Changesets PRs
        if: steps.changesets.outputs.hasChangesets
        run: gh pr --repo "$REPO" merge --auto --merge "$PR_NUM"
        env:
          GITHUB_TOKEN: ${{ secrets.GITHUB_TOKEN }}
          PR_NUM: ${{ steps.changesets.outputs.pullRequestNumber }}
          REPO: ${{ github.repository }}
```

For auto merge to be available, branch protection rules need to be set with at least 1 required status check, as explained [here](https://github.com/orgs/community/discussions/53088#discussioncomment-5992953)

When a job gets created with the `GITHUB_TOKEN`, the `on:pull_request` will not get triggered, as explained [here](https://github.com/orgs/community/discussions/65321#discussioncomment-6861423)
