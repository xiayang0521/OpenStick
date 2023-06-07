#!/bin/bash
#wifi 热点设置
wifiname="4G_UFI_123456"
carwifi="4G_Wifi_Car"
wifipasswd="12345678"
bridge='/etc/NetworkManager/system-connections/bridge.nmconnection'

function menu()
{
cat <<eof
    *************************************
                    菜单                 

                1.切换运行模式

                2.修改wifi热点名称&密码
            
                0.退出


    *************************************
eof
}
function num()
{
    read -p "请输入您需要操作的项目: " number
    case $number in
        1)
            swichmodel
            ;;
        2)
            change
            ;;
        0)
            exit 0
            ;;

    esac
}

function change()
{
read -p "请输入要修改的WIFI名称:" wifiname
read -p "请输入要修改的WIFI密码:" wifipasswd

if [ -f "$bridge" ];then
    echo "当前是随身WIFI模式，正在修改中，稍后会自动重启设备......"
    wifimodel
else
    echo "当前是遥控车模式，正在修改中，稍后会自动重启设备......"
    carname=wifiname
    carmodel
fi
}

function swichmodel()
{
cat <<eof
    *************************************
                    请选择运行模式                 

                1.遥控车模式(开启WIFI热点和USB HOST模式，启动遥控车程序)

                2.随身WIFI模式(开启WIFI热点和USB共享，不启动遥控车程序)
                
                3.连接路由器wifi
                
                0.退出


    *************************************
eof
read -p "请输入您需要操作的项目: " number
    case $number in
        1)
            carmodel
            ;;
        2)
            wifimodel
            ;;
        3)  
            clientmodel
            ;;
        0)
            exit 0
            ;;

    esac
}

function clientmodel(){
    #1.切换usb模式
    sed -i '6c #echo host > /sys/kernel/debug/usb/ci_hdrc.0/role' /usr/sbin/mobian-usb-gadget
   
    #2.关闭wifi热点
    rm -rf /etc/NetworkManager/system-connections/usb.nmconnection
    rm -rf /etc/NetworkManager/system-connections/wifi.nmconnection
    rm -rf /etc/NetworkManager/system-connections/bridge.nmconnection
    
    
    echo “连接无线路由器2.4g wifi设置，注意，如果是双频路由器，请使用2.4G频率的wifi，不能使用5G wifi”
    read -p "请输入无线路由器2.4Gwifi名字（比如：Openwrt_2.4G）:" wifi_home
    read -p "请输入对应密码:" passwd_home
    bridge=$(cat <<- EOF
[connection]
id=bridge
uuid=0332def0-cc09-4509-9929-97c92d4f4b7b
type=bridge
interface-name=nm-bridge
permissions=

[bridge]

[ipv4]
address1=192.168.68.1/24
dns-search=
method=manual

[ipv6]
addr-gen-mode=stable-privacy
dns-search=
method=auto

[proxy]
EOF
)

    wifi=$(cat <<- EOF
[connection]
id=${wifi_home}
uuid=010a2dc5-ec9b-4d6b-b465-5e12ef5c16e9
type=wifi
interface-name=wlan0
permissions=

[wifi]
mac-address-blacklist=
mode=infrastructure
ssid=${wifi_home}

[wifi-security]
auth-alg=open
key-mgmt=wpa-psk
psk=${passwd_home}

[ipv4]
dns-search=
method=auto

[ipv6]
addr-gen-mode=stable-privacy
dns-search=
method=auto

[proxy]

EOF
)

    usb=$(cat <<- EOF
[connection]
id=usb
uuid=fa0ad694-a11a-46bd-9417-0b66ea105cbc
type=ethernet
interface-name=usb0
master=0332def0-cc09-4509-9929-97c92d4f4b7b
permissions=
slave-type=bridge

[ethernet]
mac-address-blacklist=

[bridge-port]
EOF
)

    start=$(cat <<- EOF
#!/bin/sh -e
# 下面这条是要开机启动的命令
nmcli connection up USB
sleep 5
nmcli connection down USB
exit 0
EOF
)

    touch "bridge.nmconnection"
    echo "${bridge}" > bridge.nmconnection
    cp bridge.nmconnection /etc/NetworkManager/system-connections/bridge.nmconnection
    chmod 600 /etc/NetworkManager/system-connections/bridge.nmconnection
    touch "wifi.nmconnection"
    echo "${wifi}" > wifi.nmconnection
    cp wifi.nmconnection /etc/NetworkManager/system-connections/${wifi_home}.nmconnection
    chmod 600 /etc/NetworkManager/system-connections/${wifi_home}.nmconnection
    touch "usb.nmconnection"
    echo "${usb}" > usb.nmconnection
    cp usb.nmconnection /etc/NetworkManager/system-connections/usb.nmconnection
    chmod 600 /etc/NetworkManager/system-connections/usb.nmconnection
    echo "${start}" > /etc/rc.local
    echo "修改完成，WIFI：${wifi_home}，密码：${passwd_home}"
    echo "如果检查无误，请自行重启，如果有误请重新设置."
    nmcli connection down USB
    rm -rf bridge.nmconnection
    rm -rf wifi.nmconnection
    rm -rf usb.nmconnection
    #reboot
}


function wifimodel(){
    #1.切换usb模式
    sed -i '6c #echo host > /sys/kernel/debug/usb/ci_hdrc.0/role' /usr/sbin/mobian-usb-gadget
   
    #2.开启wifi热点
    rm -rf /etc/NetworkManager/system-connections/usb.nmconnection
    rm -rf /etc/NetworkManager/system-connections/wifi.nmconnection
    rm -rf /etc/NetworkManager/system-connections/bridge.nmconnection
    bridge=$(cat <<- EOF
[connection]
id=bridge
uuid=0332def0-cc09-4509-9929-97c92d4f4b7b
type=bridge
interface-name=nm-bridge
permissions=

[bridge]

[ipv4]
address1=192.168.68.1/24
dns-search=
method=manual

[ipv6]
addr-gen-mode=stable-privacy
dns-search=
method=auto

[proxy]
EOF
)

    wifi=$(cat <<- EOF
[connection]
id=wifi
uuid=46e2a2e7-2e43-4f61-9269-cf740351f557
type=wifi
interface-name=wlan0
master=0332def0-cc09-4509-9929-97c92d4f4b7b
permissions=
slave-type=bridge

[wifi]
band=bg
channel=8
mac-address-blacklist=
mode=ap
ssid=${wifiname}

[wifi-security]
key-mgmt=wpa-psk
psk=${wifipasswd}

[bridge-port]
EOF
)

    usb=$(cat <<- EOF
[connection]
id=usb
uuid=fa0ad694-a11a-46bd-9417-0b66ea105cbc
type=ethernet
interface-name=usb0
master=0332def0-cc09-4509-9929-97c92d4f4b7b
permissions=
slave-type=bridge

[ethernet]
mac-address-blacklist=

[bridge-port]
EOF
)

    start=$(cat <<- EOF
#!/bin/sh -e
# 下面这条是要开机启动的命令
nmcli connection up USB
sleep 5
nmcli connection down USB
exit 0
EOF
)

    touch "bridge.nmconnection"
    echo "${bridge}" > bridge.nmconnection
    cp bridge.nmconnection /etc/NetworkManager/system-connections/bridge.nmconnection
    chmod 600 /etc/NetworkManager/system-connections/bridge.nmconnection
    touch "wifi.nmconnection"
    echo "${wifi}" > wifi.nmconnection
    cp wifi.nmconnection /etc/NetworkManager/system-connections/wifi.nmconnection
    chmod 600 /etc/NetworkManager/system-connections/wifi.nmconnection
    touch "usb.nmconnection"
    echo "${usb}" > usb.nmconnection
    cp usb.nmconnection /etc/NetworkManager/system-connections/usb.nmconnection
    chmod 600 /etc/NetworkManager/system-connections/usb.nmconnection
    echo "${start}" > /etc/rc.local
    echo "修改完成，WIFI热点：${wifiname}，密码：${wifipasswd}"
    echo "设备重启中......"
    nmcli connection down USB
    rm -rf bridge.nmconnection
    rm -rf wifi.nmconnection
    rm -rf usb.nmconnection
    reboot
}

function carmodel(){
    #1.切换usb模式
    sed -i '6c echo host > /sys/kernel/debug/usb/ci_hdrc.0/role' /usr/sbin/mobian-usb-gadget
    
    #2.开启wifi热点
    rm -rf /etc/NetworkManager/system-connections/usb.nmconnection
    rm -rf /etc/NetworkManager/system-connections/wifi.nmconnection
    rm -rf /etc/NetworkManager/system-connections/bridge.nmconnection
    wifi=$(cat <<- EOF
[connection]
id=wifi
uuid=d4e61c73-514a-44ee-b395-99fcbbce8218
type=wifi
interface-name=wlan0
permissions=

[wifi]
mac-address-blacklist=
mode=ap
ssid=${carwifi}

[wifi-security]
key-mgmt=wpa-psk
psk=${wifipasswd}

[ipv4]
address1=192.168.68.1/24
dns-search=
method=manual

[ipv6]
addr-gen-mode=stable-privacy
dns-search=
method=auto

[proxy]
EOF
)

    start=$(cat <<- EOF
#!/bin/sh -e
# 下面这条是要开机启动的命令
nmcli connection up USB
sleep 30
cd /app/
nohup java -jar CameraPusher.jar > run.log 2>&1 &
exit 0
EOF
)

    touch "wifi.nmconnection"
    echo "${wifi}" > wifi.nmconnection
    cp wifi.nmconnection /etc/NetworkManager/system-connections/wifi.nmconnection
    chmod 600 /etc/NetworkManager/system-connections/wifi.nmconnection
    echo "${start}" > /etc/rc.local
    echo "修改完成，WIFI热点密码：${carwifi}，密码：${wifipasswd}"
    echo "设备重启中......"
    nmcli connection up USB
    rm -rf wifi.nmconnection
    reboot
}

function  main()
{
    while true
    do
        menu
        num
    done
}
main
