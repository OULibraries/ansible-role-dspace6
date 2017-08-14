## Configuration

. /opt/oulib/dspace/etc/conf.sh

#
# build dspace as an unprivleged user
#
if [[ $EUID -eq 0 ]]; then
    echo "Please don't run as root"
    exit
fi


if [ ! -d $DSPACE_SRC ]; then
    echo "No src dir, cloning with default branch."
    git clone ${DSPACE_GIT} ${DSPACE_SRC}
fi



cd ${DSPACE_SRC}
#$MAVEN  -Dmaven.repo.local=/vagrant/m2 -Dmirage2.on=true -Denv=$MAVEN_PROFILE -Dskiptests package
$MAVEN  -Dmirage2.on=true -Denv=$MAVEN_PROFILE -Dskiptests package
OUT=$?
if [ $OUT -eq 0 ];then
   echo "Maven Update successful"
else
   exit $OUT
fi

#
# Install to srv as root
# 
cd ${DSPACE_SRC}/dspace/target/dspace-installer
if [ -d ${DSPACE_RUN} ];then
        sudo $ANT  -Doverwrite=true update clean_backups
else
        sudo $ANT fresh_install
fi
OUT=$?
if [ $OUT -eq 0 ];then
   echo "ANT Update successful"
else
   exit $OUT
fi

# make sure tomcat can open files that it needs to use
sudo chown -R tomcat:tomcat ${DSPACE_RUN} 
