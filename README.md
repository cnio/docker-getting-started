# docker
docker getting started, just for beginners.

## 首先运行一个容器
```
sudo docker run -i -t ubuntu /bin/bash
```
`-i` 表示保证容器的stdin是开启的
`-t` 表示docker为要创建的容器分配一个为tty终端

ubuntu为一个基础（base）镜像，它由Docker公司提供，保存在Docker Hub上。

命令执行过程Docker会检查本地是否有ubuntu镜像，如果本地没有则会连接Docker Hub,查看是否存在此镜像。一旦找到则下载该镜像并保存到本地宿主机上。
`/bin/bash` 告诉Docker在新容器中运行什么命令，此命令将启动一个Bash shell.
```
root@ba9bfd860610:/#
```
## 基本命令
### 容器的主机名
```
root@ba9bfd860610:/# hostname
ba9bfd860610
```
可以看到，容器的主机名就是该容器的ID。

检查容器的/etc/hosts文件
```
root@ba9bfd860610:/# cat /etc/hosts 
172.17.0.2	ba9bfd860610
127.0.0.1	localhost
::1	localhost ip6-localhost ip6-loopback
fe00::0	ip6-localnet
ff00::0	ip6-mcastprefix
ff02::1	ip6-allnodes
ff02::2	ip6-allrouters
```

检查容器的接口
```
root@ba9bfd860610:/# ip a
1: lo: <LOOPBACK,UP,LOWER_UP> mtu 65536 qdisc noqueue state UNKNOWN group default 
    link/loopback 00:00:00:00:00:00 brd 00:00:00:00:00:00
    inet 127.0.0.1/8 scope host lo
       valid_lft forever preferred_lft forever
    inet6 ::1/128 scope host 
       valid_lft forever preferred_lft forever
7: eth0: <BROADCAST,MULTICAST,UP,LOWER_UP> mtu 1500 qdisc noqueue state UP group default 
    link/ether 02:42:ac:11:00:02 brd ff:ff:ff:ff:ff:ff
    inet 172.17.0.2/16 scope global eth0
       valid_lft forever preferred_lft forever
    inet6 fe80::42:acff:fe11:2/64 scope link 
       valid_lft forever preferred_lft forever
```
```
root@ba9bfd860610:/# ps -aux
USER       PID %CPU %MEM    VSZ   RSS TTY      STAT START   TIME COMMAND
root         1  0.0  0.0  18168  2024 ?        Ss   09:47   0:00 /bin/bash
root        37  0.0  0.0  15564  1144 ?        R+   11:07   0:00 ps -aux
```
发现和一个全新的linux一模一样，干坏事？反正我啥都不知道！

### 查看当前系统中容器的列表
```
sudo docker ps -a
```
```
CONTAINER ID        IMAGE               COMMAND                  CREATED             STATUS                      PORTS               NAMES
ba9bfd860610        ubuntu              "/bin/bash"              About an hour ago   Up About an hour                                clever_swirles
a951fffc02ca        jenkins             "/bin/tini -- /usr/lo"   10 weeks ago        Exited (0) 10 weeks ago                         stupefied_panini
43d3d6cd4a29        jenkins             "/bin/tini -- /usr/lo"   10 weeks ago        Exited (143) 10 weeks ago                       myjenkins
2ca796fbf65d        node                "/bin/bash"              11 weeks ago        Exited (0) 11 weeks ago                         jolly_hopper
77cb113e8ea2        redis               "/entrypoint.sh redis"   11 weeks ago        Exited (0) 11 weeks ago                         redis-server
8a3900a20bb6        ubuntu              "/bin/bash"              11 weeks ago        Exited (127) 11 weeks ago                       insane_kilby
d042ee95a5e4        cnio/node           "/bin/bash"              11 weeks ago        Exited (0) 11 weeks ago                         gigantic_varahamihira
92d1ee5fe4bc        node                "/bin/bash"              11 weeks ago        Exited (127) 11 weeks ago                       cocky_bohr
```
`-a` 会列出所有容器，包括正在运行的和停止的。
`-l`只会列出最后一次运行的容器包括正在运行的和停止的。
```
➜  ~  sudo docker ps -l
CONTAINER ID        IMAGE               COMMAND             CREATED             STATUS              PORTS               NAMES
ba9bfd860610        ubuntu              "/bin/bash"         About an hour ago   Up About an hour                        clever_swirles
```  
### 容器命名
`--name 参数`
```
sudo docker run --name [a-zA-Z0-9_.-]
```
示例
```
➜  ~  sudo docker run --name cnio -it ubuntu /bin/bash 
root@1db35eb3c722:/# 
```
这样就又启动了新容器。
```
➜  ~  sudo docker ps -a
CONTAINER ID        IMAGE               COMMAND                  CREATED             STATUS                          PORTS               NAMES
1db35eb3c722        ubuntu              "/bin/bash"              5 minutes ago       Exited (0) About a minute ago                       cnio
```

### 重新启动已经停止的容器
#### start
如，`cnio`为停止的容器名
```
sudo docker start [cnio/或ID]
```
#### attach 
比如此时有个ID`ba9bfd860610` 的容器，重新启动它后并不会进入shell，如果想进入shell可以使用`attach` 命令(`ba9bfd860610` 容器必须已经启动)。如果并没有马上进入shell，可能需要按下`Ctrl+C`，如下:
```
➜  ~  sudo docker start ba9bfd860610
ba9bfd860610
➜  ~  sudo docker attach ba9bfd860610
^C
root@ba9bfd860610:/# 
```
### 创建守护式容器
```
➜  ~  sudo docker run --name daemon-c -d ubuntu /bin/sh -c "while true; do echo ur handsome; sleep 1; done"
9729d9ca13024e6d420a09574653d76fe19a1d595032cb55823f346313857d16
➜  ~  
```
#### 日志
1.如下命令会输出最后几条日志项并返回
```
sudo docker logs daemon-c
```

2.这命令并不会退出执行状态，多按一个`Ctrl+C`，与上一命令从效果上来看区别不大。
```
sudo docker logs -f daemon-c
```
3.如果只想跟踪日志的某一段，只需在tail命令后加入-lines标志即可。
如获取最后10条日志：
```
sudo docker logs --tail 10 daemon-c
```
4.跟踪最新日志(日志会动态输出到shell)
```
sudo docker logs --tail 0 -f daemon-c
```
### 查看容器内的进程
注意此时是在宿主机上执行命令，如果已经在某个容器中了，则使用linux自带 `ps -aux` 查看进程就可以了。
```
sudo docker top daemon-c
```

### 在容器内部启动新进程
```
sudo docker exec
```
示例：如创建了一个`a.txt` 空文件
```
sudo docker exec -d daemon-c touch a.txt
```
`-d`表示需要运行一个后台进程。

打开shell查看：
```
sudo docker exec -i -t daemon-c /bin/bash
```
> 注意 `docker exec `是在Docker 1.3引入的，早期版本不支持


### 停止守护进程
```
sudo docker stop daemon-c
```
`docker stop`会向Docker容器发送`sigterm`信号，而docker kill 可以快速停止某容器，它发送的是`sigkill`信号。

### 深入容器
```
sudo docker inspect daemon-c
```
### 删除容器
#### 删除某一个容器
```
sudo docker rm [cnio]
```
#### 删除所有
```
sudo docker rm 'docker ps -a -q'
```
`-a`表示列出所有容器，`-q` 则表示只需要返回容器的ID而不会返回容器的其他信息。这样就得到了容器ID列表，并传给`docker rm`命令，从而达到删除所有容器的目的。

### 列出镜像
```
sudo docker images
```
```
➜  ~  sudo docker images
REPOSITORY          TAG                 IMAGE ID            CREATED             VIRTUAL SIZE
cnio/node-pm2       latest              a8cef9262907        11 weeks ago        644.3 MB
cnio/node           latest              79058a98ed36        11 weeks ago        642.7 MB
redis               latest              0c4334bed751        11 weeks ago        151.3 MB
node                latest              285fd945c0b6        3 months ago        642.7 MB
jenkins             latest              988e2e1b7418        3 months ago        707.9 MB
ubuntu              latest              89d5d8e8bafb        3 months ago        187.9 MB
<none>              <none>              38bbdcdf22d3        3 months ago        292.5 MB

```

本地镜像存放在Docker宿主机的`/var/lib/docker` 目录下。
每个镜像都保存在所采用的存储驱动目录下面（如aufs或devicemapper）
也可以在/var/lib/docker/containers目录看到所有的容器。
```
➜  lib  sudo ls docker
[sudo] password for joes: 
aufs      graph   network      tmp    volumes
containers  linkgraph.db  repositories-aufs  trust
```

### 拉取镜像
```
sudo docker pull image_name
```
默认情况下，会下载latest标签的镜像。如果想使用某个版本的镜像，可以在镜像名前后面加上`：`和`版本号`

```
sudo docker pull ubuntu:12.04
```
### 搜索镜像
```
sudo docker search image_name
```
```
➜  ~  sudo docker search nginx
NAME                      DESCRIPTION                                     STARS     OFFICIAL   AUTOMATED
nginx                     Official build of Nginx.                        2398      [OK]       
jwilder/nginx-proxy       Automated Nginx reverse proxy for docker c...   550                  [OK]
richarvey/nginx-php-fpm   Container running Nginx + PHP-FPM capable ...   158                  [OK]
maxexcloo/nginx-php       Docker framework container with Nginx and ...   56                   [OK]

```
其中搜索结果包括官方镜像和用户镜像。拉取用户镜像时要加上用户名
示例：
```
sudo docker pull jwilder/nginx-proxy 
```

## 构建镜像
### docker commit
不推荐使用，而应该使用b更灵活更强大的DockerFile来构建。
#### 注册DockerHub
[https://hub.docker.com](https://hub.docker.com)
#### 登陆DockerHub
```
$ sudo docker login
Username (cnio): 

WARNING: login credentials saved in /home/joes/.docker/config.json
Login Succeeded
```
其中`/.docker/config.json`里面记录了Login信息