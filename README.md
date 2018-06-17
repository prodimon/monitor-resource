# monitor-resource
#### required package
```bash
apt update
apt install imagemagick rrdtool zip
```
#### Install
```bash
curl https://codeload.github.com/prodimon/monitor-resource/zip/master --output master.zip
unzip master.zip
rm master.zip
```
#### Added crontab
```bash
* * * * * cd /root/monitor-resource-master && ./main.sh
0 0 * * * cd /root/monitor-resource-master && ./main.sh report 1day dima-bannik@mail.ru > /dev/null 2>&1
```
