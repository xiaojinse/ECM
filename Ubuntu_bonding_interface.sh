
# bonding mode: 0. round robin，1.active-backup

# 设置 bonding mode：# 在该文件中加入以下内容：miimon是用来进行链路监测的。
# 比如:miimon=100，那么系统每100ms监测一次链路连接状态，如果有一条线路不通就转入另一条线路。

vi /etc/modules
bonding mode=1 miimon=100

# 网卡配置信息

vi /etc/network/interfaces





