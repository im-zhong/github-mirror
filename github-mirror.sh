#! /bin/bash

# 这条命令太牛逼了，从github查询仓库列表，然后在gitea全部创建出来
# gh repo list | awk '{print $1}' | cut -d '/' -f 2 | while read line; do echo "$line"; 

# 我感觉这个东西可以实现 太简单了
# 我们要获得的就是仓库的名字和仓库的private还是public

# 我们有一个工作目录，我们不管在哪里被调用 都cd到这个目录
# cd $HOME/usr/git-mirror

username="im-zhong"
gitea_api="https://git.zhong-server.com/api/v1"

gh repo list --public | awk '{print $1}' | cut -d '/' -f 2 | while read reponame; 
do
  echo $reponame
  # check if repo is cloned
  if [ -d ./${reponame}.git ]; then
    echo $reponame exist
  else
    echo $reponame dose not exists
    git clone --bare git@github.com:${username}/${reponame}.git
  fi

  curl -X POST \
    -H "Authorization: token ${giteatoken}" \
    -H "Content-Type: application/json" \
    -d "{\"name\": \"${reponame}\", \"private\": false}" \
    https://git.zhong-server.com/api/v1/user/repos \

  # 不对 我们还需要创建仓库
  # 不论如何 到了这里 我们肯定已经有一个 repo.git 文件夹了
  # 我们cd进去
  cd ${reponame}.git
  # update
  git fetch git@github.com:${username}/${reponame}.git
  # push mirror
  git push --mirror git@git.zhong-server.com:/zhangzhong/${reponame}.git
  cd ..
done

gh repo list --private | awk '{print $1}' | cut -d '/' -f 2 | while read reponame; 
do
  echo $reponame
  # check if repo is cloned
  if [ -d ./${reponame}.git ]; then
    echo $reponame exist
  else
    echo $reponame dose not exists
    git clone --bare git@github.com:${username}/${reponame}.git
  fi

  curl -X POST \
    -H "Authorization: token ${giteatoken}" \
    -H "Content-Type: application/json" \
    -d "{\"name\": \"${reponame}\", \"private\": true}" \
    https://git.zhong-server.com/api/v1/user/repos \

  cd ${reponame}.git
  # update
  git fetch git@github.com:${username}/${reponame}.git
  # push mirror
  git push --mirror git@git.zhong-server.com:/zhangzhong/${reponame}.git
  cd ..

done


# 这个脚本必须工作在某个目录下面 并且这些目录下面就放着我所有的github仓库
# 一旦上面的仓库创建完成之后，我就会进入下面的工作
# 我会cd进去所有的仓库 如果没有clone --bare的 我们就clone一下
# 然后我们 git fetch
# 然后我们就可以进行一个git push --mirror
# 完美 看似困难的任务其实只需要一个脚本，和一个配置，自动执行的配置即可
# git clone   
