# Used to transfer git repo from one platform to another

repoName=adminweb
srcRepoURL=git@gitee.com:gicmccdev/${repoName}.git
tgtRepoURL=git@code.aliyun.com:GI-CMCC/${repoName}.git
tgtRepoAlias=aliyun

git clone ${srcRepoURL} ${repoName}
cd ${repoName}

git remote add ${tgtRepoAlias} ${tgtRepoURL}
git branch --all | grep -v remotes/origin/HEAD | sed -n 's/remotes\/origin\///p' | while read branchName; do
  git checkout ${branchName}
  git push aliyun ${branchName}
done

cd ..
rm -Rf ${repoName}
