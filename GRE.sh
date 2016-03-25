



# Use em2 as a GRE physical network path #
# em2 IP: s01:10.168.1.14 s02:10.168.1.15 s05 #

ifconfig em2


# ip netns list
# ovs-vsctl show
# ip link | grep veth
# ip link show veth100
# ip netns exec red ip a

# on S01:

ovs-vsctl add-br mylabovs-gre
ovs-vsctl add-port mylabovs-gre gre0 -- set interface gre0 type=gre options:remote_ip=10.168.1.15

ip netns add red
ip link add veth100 type veth peer name veth101
ip link set veth100 netns red
ip netns exec red ip addr add 10.163.168.221/27 dev veth100
ip netns exec red ip link set veth100 up

ovs-vsctl add-port mylabovs-gre veth101
ip link set veth101 up
ovs-vsctl set port veth101 tag=501

# on S02:

ovs-vsctl add-br mylabovs-gre
ovs-vsctl add-port mylabovs-gre gre0 -- set interface gre0 type=gre options:remote_ip=10.168.1.14

ip netns add red
ip link add veth0 type veth peer name veth1
ip link set veth0 netns red
ip netns exec red ip addr add 10.163.168.222/27 dev veth0
ip netns exec red ip link set veth0 up
ip netns exec red ip a

ovs-vsctl add-port mylabovs-gre veth1
ip link set veth1 up
ovs-vsctl set port veth1 tag=501


