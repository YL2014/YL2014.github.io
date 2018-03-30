if [ ! -d "/tmp/github" ]
  mkdir /tmp/github
  chmod -R 777 /tmp/github
fi

cp -R ./public/ /tmp/github

if [ ! -d "/tmp/YL2014.github.io" ]
  git clone git@github.com:YL2014/YL2014.github.io.git
  chmod -R 777 /tmp/YL2014.github.io
fi

cd /tmp/YL2014.github.io

git pull origin master

cp -R /tmp/github/ /tmp/YL2014.github.io

git add . && git commit -am "add articles" && git push origin master
