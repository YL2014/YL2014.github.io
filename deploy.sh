if [ ! -d "$JENKINS_HOME/tmp/github" ]
  mkdir $JENKINS_HOME/tmp/github
  chmod -R 777 $JENKINS_HOME/tmp/github
fi

cp -R ./public/ $JENKINS_HOME/tmp/github

if [ ! -d "$JENKINS_HOME/tmp/YL2014.github.io" ]
  git clone git@github.com:YL2014/YL2014.github.io.git
  chmod -R 777 $JENKINS_HOME/tmp/YL2014.github.io
fi

cd $JENKINS_HOME/tmp/YL2014.github.io

git pull origin master

cp -R $JENKINS_HOME/tmp/github/ $JENKINS_HOME/tmp/YL2014.github.io

git add . && git commit -am "add articles" && git push origin master
