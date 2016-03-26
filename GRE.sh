
1. 配置网卡

# Use em7 on s03&s05 + em1 on S01&s02 as a GRE physical network path #
# IP: s01_em1:192.168.4.1/24 s02_em1:192.168.4.2/24 s03_em7:192.168.4.3/24 s05_em7: 192.168.4.5/24 

ifconfig em1
ifconfig em7

# add IP address for em1 on s01/s02

vim /etc/network/interfaces

# on S01
#This NIC is used for MyLAB GRE tunnel
auto em1
iface em1 inet static
        address 192.168.4.1
        netmask 255.255.255.0
        gateway 192.168.4.254

# on S02
#This NIC is used for MyLAB GRE tunnel
auto em1
iface em1 inet static
        address 192.168.4.2
        netmask 255.255.255.0
        gateway 192.168.4.254

# 不用ifdown和ifup就起来了。

2. 利用ns 测试 GRE tunnel

# ip netns list
# ovs-vsctl show
# ip link | grep veth
# ip link show veth100
# ip netns exec red ip a

# on S01:

ovs-vsctl add-br mylabovs-gre
ovs-vsctl add-port mylabovs-gre gre0 -- set interface gre0 type=gre options:remote_ip=192.168.4.2

ip netns add red
ip link add veth100 type veth peer name veth101
ip link set veth100 netns red
ip netns exec red ip addr add 10.163.168.201/27 dev veth100
ip netns exec red ip link set veth100 up

ovs-vsctl add-port mylabovs-gre veth101
ip link set veth101 up
ovs-vsctl set port veth101 tag=501

ip netns exec red ping -c 4 10.163.168.202
ip netns exec red tcpdump

# on S02:

ovs-vsctl add-br mylabovs-gre
ovs-vsctl add-port mylabovs-gre gre0 -- set interface gre0 type=gre options:remote_ip=192.168.4.1

ip netns add red
ip link add veth100 type veth peer name veth101
ip link set veth100 netns red
ip netns exec red ip addr add 10.163.168.202/27 dev veth100
ip netns exec red ip link set veth100 up

ovs-vsctl add-port mylabovs-gre veth101
ip link set veth101 up
ovs-vsctl set port veth101 tag=501

ip netns exec red ping -c 4 10.163.168.201
ip netns exec red tcpdump

3. 连接ceebr3 到 GRE OVS。

# to avoid risk of forming loop, just add the ceebr3.

# on S01:

ip link add ceebr3_p0 type veth peer name mylabovs_gre_p0
ip link set ceebr3_p0 up
ip link set mylabovs_gre_p0 up

# be noticed that ceebr3 is KVM bridge.
# brctl show ceebr3
# ifconfig ceebr3_p0

brctl addif ceebr3 ceebr3_p0

ovs-vsctl add-port mylabovs-gre mylabovs_gre_p0
ovs-vsctl set port mylabovs_gre_p0 tag=501

ip netns exec red ping -c 4 10.163.168.219

# if troubleshooting needed
# Ubuntu check route
netstat -nr


!!!!
ip netns exec red tcpdump



