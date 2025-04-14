# test-changesets-automerge
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

# Enable release on merge
There here are some options:
[ ] Use the [changesets action](https://github.com/changesets/action) provided by changesets, and then set up automerge once the release should be merged.
[ ] use auto-publish github [action](https://github.com/JamilOmar/autopublish-changesets-action)
[X] Build a custom job

This repo tried a few implantations to get auto release working, and ended up using the *`Build a custom job`* option.

## Using the provided changesets action with automerge
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

## Using custom job
> use a custom job to check if there are changesets, and if so, build and release the package.

The step `Check for changesets` uses changesets `changeset status`.  
But this is not working as expected, as detailed [here](https://github.com/changesets/changesets/issues/1036) with a pr to fix it [here](https://github.com/changesets/changesets/pull/1345).

```yml
  jobs:
  release:
    name: Release
    runs-on: ubuntu-latest

    permissions:
      contents: write
      packages: write

    outputs:
      hasChanges: ${{ steps.changesets.outputs.hasChanges }}

    steps:
      - name: Checkout Repo
        uses: actions/checkout@v4

      - name: Check for changesets
        id: changesets
        # currently doesn't work correctly, see https://github.com/changesets/changesets/issues/1036
        # old check: pnpm run version:hasChanges
        run: |
          if [ $(ls .changeset/*.md | wc -l) -eq 1 ]; then
            echo "No changesets found."
            echo "hasChanges=false" >> $GITHUB_OUTPUT
          else
            echo "New changesets has been found."
            echo "hasChanges=true" >> $GITHUB_OUTPUT
          fi

      - name: Setup Node.js ${{ env.node_version }}
        uses: actions/setup-node@v4
        with:
          node-version: ${{ env.node_version }}
          registry-url: 'https://npm.pkg.github.com'

      - uses: pnpm/action-setup@v4
      
      - name: Install Dependencies
        run: pnpm install

      - name: Build
        if: steps.changesets.outputs.hasChanges == 'true'
        run: pnpm build

      - name: Setup git user info
        run: | 
          git config user.name "github-actions[bot]"
          git config user.email "41898282+github-actions[bot]@users.noreply.github.com"   

      - name: Publish to GitHub Packages
        if: steps.changesets.outputs.hasChanges == 'true'
        run: |
          pnpm run version:bump
          pnpm ci:publish
          git push --follow-tags
        env:
          GITHUB_TOKEN: ${{ secrets.GITHUB_TOKEN }}
          NPM_TOKEN: ${{ secrets.GITHUB_TOKEN }}
          NODE_AUTH_TOKEN: ${{ secrets.GITHUB_TOKEN }}
```

## Testing pre-releases