VERSION=3.6.2

sudo apt-get purge -y maven
if ! [ -e apache-maven-$VERSION-bin.tar.gz ]; then (curl -OL http://mirror.olnevhost.net/pub/apache/maven/maven-3/$VERSION/binaries/apache-maven-$VERSION-bin.tar.gz); fi
sudo rm -rf /usr/local/apache-maven-$VERSION
sudo tar -zxf apache-maven-$VERSION-bin.tar.gz -C /usr/local/
sudo ln -s /usr/local/apache-maven-$VERSION/bin/mvn /usr/bin/mvn
echo "Maven is on version `mvn -v`"
