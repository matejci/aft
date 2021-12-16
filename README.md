# takko web :taco:

![takko gif](/app/assets/images/takko-animated-logo.gif)

## Starting up the Web Server
Running the server on http://localhost:3000
```
foreman start -f Procfile.dev -p 3000
```
Runs the following:
```
web: bundle exec rails s
webpacker: ./bin/webpack-dev-server
```

## Elasticsearch
```
brew install elasticsearch
brew services start elasticsearch
```


## API Endpoints
https://takko-staging-env.herokuapp.com/api/docs


## Heroku ENVS, deployment strategy and git flow

We have 3 environments where Takko is deployed:
- Dev - https://takko-dev-env.herokuapp.com
- Staging - https://takko-staging-env.herokuapp.com
- Production - https://takko.herokuapp.com

There are two important git branches: `staging` and `master`

#### DEV Heroku environment is used in cases:
- when we want to test current (incomplete) work inside Heroku env
- if we are introducing breaking change for iOS app and we don't want to break STAGING env
  (In that case one of iOS devs will point iOS app to DEV env to adjust his work and 'catch up' with latest backend version. Once that happens, we need to merge our feature branch to `staging` and deploy it there.)
- it's ok to deploy your feature branch here, while WIP
- once feature is completed new merge request of feature branch to `staging` should be created
  (PR should be merged as soon as it is approved. In case it introduces breaking changes, merging can be postponed until those are handled on iOS side)

#### STAGING Heroku environment
- should contain latest working code of `staging` branch
- features that are not yet deployed in PROD, but are needed for iOS in order to complete their (current sprint) work

#### PRODUCTION deployments
Once we want to release new version, we need to:
1. we create new release branch off of `staging`

```shell
    git checkout staging
    git pull origin staging
    git checkout -b "release_yyyy_mm_dd"
```
2. we check for any breaking changes and discard those unless we want to deploy them as well

3. we push newly created branch to origin and we deploy newly created branch

```shell
    git push origin release_yyyy_mm_dd
    git push <prod> release_yyyy_mm_dd:master
```

4. once we do some basic tests on production and see everything went well, we merge release branch to `master`

If during the sprint we need to deploy hotfix to PROD Heroku env, we are going to find most recent `release_yyyy_mm_dd` branch on git repository (https://github.com/Content-Creators/takko-web/branches) and then create a new branch off of it with `hotfix_x` suffix, where `x` is the number of hotfix we are deploying for that release version.
example:
- let's say most recent release branch is named `release_2021_06_09`, when we are creating our first hotfix, we'll do it like this:

```shell
git checkout release_2021_06_09
git checkout -b "release_2021_06_09_hotfix_1"
...
# commit changes
git push origin release_2021_06_09_hotfix_1
git push <prod> release_2021_06_09_hotfix_1
```

* **IMPORTANT **after deploying to PROD, make sure that your hotfix is merged to `master` and `staging` branches!

If there is a need for another hofix deploy, we're going to repeat the process as when we were deploying first hotfix, but now instead of most recent `release` branch, we are going to use most recent `hotfix` release branch.
