#!/bin/sh
echo "eXperDB-Management-Agent stop run .. "

SCRIPTPATH=$(cd "$(dirname "$0")" && pwd)
PROJECT_HOME=${SCRIPTPATH%/*}

JAVAC=`which javac`
JAVA_HOME=`readlink -f $JAVAC | sed "s:/bin/javac::"`

#JAVA_HOME=$PROJECT_HOME/java/jdk1.8.0_91
LOG_DIR=$PROJECT_HOME/logs
APP_HOME=$PROJECT_HOME/classes
APP_HOME=$PROJECT_HOME/classes/*:$APP_HOME
LIB=$PROJECT_HOME/lib/*
JAVA_CLASSPATH=$APP_HOME:$LIB
MAIN_CLASS=com.k4m.dx.tcontrol.DaemonStart


$JAVA_HOME/bin/java -Du=eXperDB-Management-Agent -Dlog.base=$LOG_DIR -classpath $JAVA_CLASSPATH $MAIN_CLASS -shutdown

