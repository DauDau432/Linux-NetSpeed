#!/usr/bin/env bash
PATH=/bin:/sbin:/usr/bin:/usr/sbin:/usr/local/bin:/usr/local/sbin:~/bin
export PATH

#=================================================
#  Yêu cầu hệ thống: CentOS 6/7, Debian 8/9, Ubuntu 16+
#  Mô tả: BBR + BBR bản sửa đổi Magic + BBRplus + Lotserver
#  Phiên bản: 1.4.0
#  Tác giả: Qianying, cx9208, DauDau432
#  Blog: https://www.939.me/
#  Nên sử dụng kernel trên 5.5 để mở trực tiếp bbr để có tốc độ tốt nhất
#=================================================

sh_ver="1.4.0"
github="raw.githubusercontent.com/DauDau432/Linux-NetSpeed/master"

Green_font_prefix="\033[32m" && Red_font_prefix="\033[31m" && Green_background_prefix="\033[42;37m" && Red_background_prefix="\033[41;37m" && Font_color_suffix="\033[0m"
Info="${Green_font_prefix}[Thông tin]${Font_color_suffix}"
Error="${Red_font_prefix}[Viết sai]${Font_color_suffix}"
Tip="${Green_font_prefix}[Chú ý]${Font_color_suffix}"

#Cài đặt hạt nhân BBR
installbbr(){
	kernel_version="4.11.8"
	if [[ "${release}" == "centos" ]]; then
		rpm --import http://${github}/bbr/${release}/RPM-GPG-KEY-elrepo.org
		yum install -y http://${github}/bbr/${release}/${version}/${bit}/kernel-ml-${kernel_version}.rpm
		yum remove -y kernel-headers
		yum install -y http://${github}/bbr/${release}/${version}/${bit}/kernel-ml-headers-${kernel_version}.rpm
		yum install -y http://${github}/bbr/${release}/${version}/${bit}/kernel-ml-devel-${kernel_version}.rpm
	elif [[ "${release}" == "debian" || "${release}" == "ubuntu" ]]; then
		mkdir bbr && cd bbr
		wget http://security.debian.org/debian-security/pool/updates/main/o/openssl/libssl1.1_1.1.1d-0+deb10u2_amd64.deb
		wget -N --no-check-certificate http://${github}/bbr/debian-ubuntu/linux-headers-${kernel_version}-all.deb
		wget -N --no-check-certificate http://${github}/bbr/debian-ubuntu/${bit}/linux-headers-${kernel_version}.deb
		wget -N --no-check-certificate http://${github}/bbr/debian-ubuntu/${bit}/linux-image-${kernel_version}.deb
	
		dpkg -i libssl1.1_1.1.1d-0+deb10u2_amd64.deb
		dpkg -i linux-headers-${kernel_version}-all.deb
		dpkg -i linux-headers-${kernel_version}.deb
		dpkg -i linux-image-${kernel_version}.deb
		cd .. && rm -rf bbr
	fi
	detele_kernel
	BBR_grub
	echo -e " ${Tip} Sau khi khởi động lại VPS, vui lòng chạy lại script để kích hoạt ${Red_font_prefix}BBR/BBR Magic đã được sửa đổi${Font_color_suffix}"
	stty erase '^H' && read -p " Bạn cần khởi động lại VPS trước khi có thể mở bản sửa đổi kỳ BBR/BBR Magic. Bạn có muốn khởi động lại ngay bây giờ không? [Y/n]: " yn
	[ -z "${yn}" ] && yn="y"
	if [[ $yn == [Yy] ]]; then
		echo -e " ${Info} Đang khởi động lại VPS..."
		reboot
	fi
}

#Cài đặt hạt nhân BBRplus
installbbrplus(){
	kernel_version="4.14.129-bbrplus"
	if [[ "${release}" == "centos" ]]; then
		wget -N --no-check-certificate https://${github}/bbrplus/${release}/${version}/kernel-${kernel_version}.rpm
		yum install -y kernel-${kernel_version}.rpm
		rm -f kernel-${kernel_version}.rpm
		kernel_version="4.14.129_bbrplus" #fix a bug
	elif [[ "${release}" == "debian" || "${release}" == "ubuntu" ]]; then
		mkdir bbrplus && cd bbrplus
		wget -N --no-check-certificate http://${github}/bbrplus/debian-ubuntu/${bit}/linux-headers-${kernel_version}.deb
		wget -N --no-check-certificate http://${github}/bbrplus/debian-ubuntu/${bit}/linux-image-${kernel_version}.deb
		dpkg -i linux-headers-${kernel_version}.deb
		dpkg -i linux-image-${kernel_version}.deb
		cd .. && rm -rf bbrplus
	fi
	detele_kernel
	BBR_grub
	echo -e " ${Tip} Sau khi khởi động lại VPS, vui lòng chạy lại script để kích hoạt${Red_font_prefix} BBRplus${Font_color_suffix}"
	stty erase '^H' && read -p " BBRplus cần được khởi động lại sau khi VPS được khởi động lại. Bạn có muốn khởi động lại bây giờ không? [Y/n]: " yn
	[ -z "${yn}" ] && yn="y"
	if [[ $yn == [Yy] ]]; then
		echo -e " ${Info} Đang khởi động lại VPS..."
		reboot
	fi
}

# Cài đặt nhân Lotserver
installlot(){
	if [[ "${release}" == "centos" ]]; then
		rpm --import http://${github}/lotserver/${release}/RPM-GPG-KEY-elrepo.org
		yum remove -y kernel-firmware
		yum install -y http://${github}/lotserver/${release}/${version}/${bit}/kernel-firmware-${kernel_version}.rpm
		yum install -y http://${github}/lotserver/${release}/${version}/${bit}/kernel-${kernel_version}.rpm
		yum remove -y kernel-headers
		yum install -y http://${github}/lotserver/${release}/${version}/${bit}/kernel-headers-${kernel_version}.rpm
		yum install -y http://${github}/lotserver/${release}/${version}/${bit}/kernel-devel-${kernel_version}.rpm
	elif [[ "${release}" == "ubuntu" ]]; then
		bash <(wget --no-check-certificate -qO- "http://${github}/Debian_Kernel.sh")
	elif [[ "${release}" == "debian" ]]; then
		bash <(wget --no-check-certificate -qO- "http://${github}/Debian_Kernel.sh")
	fi
	detele_kernel
	BBR_grub
	echo -e " ${Tip} Sau khi khởi động lại VPS, vui lòng chạy lại script để kích hoạt ${Red_font_prefix}Lotserver${Font_color_suffix}"
	stty erase '^H' && read -p " Lotserver cần được khởi động lại sau khi khởi động lại VPS. Bạn có muốn khởi động lại nó ngay bây giờ không? [Y/n]: " yn
	[ -z "${yn}" ] && yn="y"
	if [[ $yn == [Yy] ]]; then
		echo -e " ${Info} Đang khởi động lại VPS..."
		reboot
	fi
}

# Bật BBR
startbbr(){
	remove_all
	if [[ `echo ${kernel_version} | awk -F'.' '{print $1}'` -ge "5" ]]; then
		echo "net.core.default_qdisc=cake" >> /etc/sysctl.conf
		echo "net.ipv4.tcp_congestion_control=bbr" >> /etc/sysctl.conf
	else
		echo "net.core.default_qdisc=fq" >> /etc/sysctl.conf
		echo "net.ipv4.tcp_congestion_control=bbr" >> /etc/sysctl.conf
	fi
	sysctl -p
	echo -e " ${Info} BBR đã bật thành công！"
}

# Bật BBRplus
startbbrplus(){
	remove_all
	echo "net.core.default_qdisc=fq" >> /etc/sysctl.conf
	echo "net.ipv4.tcp_congestion_control=bbrplus" >> /etc/sysctl.conf
	sysctl -p
	echo -e " ${Info} BBRplus đã bật thành công！"
}

# Biên dịch và kích hoạt BBR magic
startbbrmod(){
	remove_all
	if [[ "${release}" == "centos" ]]; then
		yum install -y make gcc
		mkdir bbrmod && cd bbrmod
		wget -N --no-check-certificate http://${github}/bbr/tcp_tsunami.c
		echo "obj-m:=tcp_tsunami.o" > Makefile
		make -C /lib/modules/$(uname -r)/build M=`pwd` modules CC=/usr/bin/gcc
		chmod +x ./tcp_tsunami.ko
		cp -rf ./tcp_tsunami.ko /lib/modules/$(uname -r)/kernel/net/ipv4
		insmod tcp_tsunami.ko
		depmod -a
	else
		apt-get update
		if [[ "${release}" == "ubuntu" && "${version}" = "14" ]]; then
			apt-get -y install build-essential
			apt-get -y install software-properties-common
			add-apt-repository ppa:ubuntu-toolchain-r/test -y
			apt-get update
		fi
		apt-get -y install make gcc
		mkdir bbrmod && cd bbrmod
		wget -N --no-check-certificate http://${github}/bbr/tcp_tsunami.c
		echo "obj-m:=tcp_tsunami.o" > Makefile
		ln -s /usr/bin/gcc /usr/bin/gcc-4.9
		make -C /lib/modules/$(uname -r)/build M=`pwd` modules CC=/usr/bin/gcc-4.9
		install tcp_tsunami.ko /lib/modules/$(uname -r)/kernel
		cp -rf ./tcp_tsunami.ko /lib/modules/$(uname -r)/kernel/net/ipv4
		depmod -a
	fi
	

	echo "net.core.default_qdisc=fq" >> /etc/sysctl.conf
	echo "net.ipv4.tcp_congestion_control=tsunami" >> /etc/sysctl.conf
	sysctl -p
    cd .. && rm -rf bbrmod
	echo -e " ${Info} Đã khởi chạy thành công phiên bản Magic BBR！"
}

# Biên dịch và kích hoạt BBR magic
startbbrmod_nanqinlang(){
	remove_all
	if [[ "${release}" == "centos" ]]; then
		yum install -y make gcc
		mkdir bbrmod && cd bbrmod
		wget -N --no-check-certificate https://raw.githubusercontent.com/DauDau432/Linux-NetSpeed/master/bbr/centos/tcp_nanqinlang.c
		echo "obj-m := tcp_nanqinlang.o" > Makefile
		make -C /lib/modules/$(uname -r)/build M=`pwd` modules CC=/usr/bin/gcc
		chmod +x ./tcp_nanqinlang.ko
		cp -rf ./tcp_nanqinlang.ko /lib/modules/$(uname -r)/kernel/net/ipv4
		insmod tcp_nanqinlang.ko
		depmod -a
	else
		apt-get update
		if [[ "${release}" == "ubuntu" && "${version}" = "14" ]]; then
			apt-get -y install build-essential
			apt-get -y install software-properties-common
			add-apt-repository ppa:ubuntu-toolchain-r/test -y
			apt-get update
		fi
		apt-get -y install make gcc-4.9
		mkdir bbrmod && cd bbrmod
		wget -N --no-check-certificate https://raw.githubusercontent.com/DauDau432/Linux-NetSpeed/master/bbr/tcp_nanqinlang.c
		echo "obj-m := tcp_nanqinlang.o" > Makefile
		make -C /lib/modules/$(uname -r)/build M=`pwd` modules CC=/usr/bin/gcc-4.9
		install tcp_nanqinlang.ko /lib/modules/$(uname -r)/kernel
		cp -rf ./tcp_nanqinlang.ko /lib/modules/$(uname -r)/kernel/net/ipv4
		depmod -a
	fi
	

	echo "net.core.default_qdisc=fq" >> /etc/sysctl.conf
	echo "net.ipv4.tcp_congestion_control=nanqinlang" >> /etc/sysctl.conf
	sysctl -p
	echo -e " ${Info} Đã khởi chạy thành công phiên bản Magic BBR！"
}

# Bật Lotserver
startlotserver(){
	remove_all
	if [[ "${release}" == "centos" ]]; then
		yum install ethtool
	else
		apt-get update
		apt-get install ethtool
	fi
	bash <(wget --no-check-certificate -qO- https://raw.githubusercontent.com/DauDau432/lotServer/master/Install.sh) install
	sed -i '/advinacc/d' /appex/etc/config
	sed -i '/maxmode/d' /appex/etc/config
	echo -e "advinacc=\"1\"
maxmode=\"1\"">>/appex/etc/config
	/appex/bin/lotServer.sh restart
	start_menu
}

# gỡ cài đặt tất cả tăng tốc
remove_all(){
	rm -rf bbrmod
	sed -i '/net.core.default_qdisc/d' /etc/sysctl.conf
  sed -i '/net.ipv4.tcp_congestion_control/d' /etc/sysctl.conf
  sed -i '/fs.file-max/d' /etc/sysctl.conf
	sed -i '/net.core.rmem_default/d' /etc/sysctl.conf
	sed -i '/net.core.wmem_default/d' /etc/sysctl.conf
	sed -i '/net.core.somaxconn/d' /etc/sysctl.conf
	sed -i '/net.ipv4.tcp_syncookies/d' /etc/sysctl.conf
	sed -i '/net.ipv4.tcp_tw_reuse/d' /etc/sysctl.conf
	sed -i '/net.ipv4.tcp_tw_recycle/d' /etc/sysctl.conf
	sed -i '/net.ipv4.tcp_fin_timeout/d' /etc/sysctl.conf
	sed -i '/net.ipv4.tcp_keepalive_time/d' /etc/sysctl.conf
	sed -i '/net.ipv4.ip_local_port_range/d' /etc/sysctl.conf
	sed -i '/net.ipv4.tcp_max_tw_buckets/d' /etc/sysctl.conf
	sed -i '/net.ipv4.tcp_rmem/d' /etc/sysctl.conf
	sed -i '/net.ipv4.tcp_wmem/d' /etc/sysctl.conf
	sed -i '/net.ipv4.tcp_mtu_probing/d' /etc/sysctl.conf
	sed -i '/net.ipv4.ip_forward/d' /etc/sysctl.conf
	sed -i '/fs.inotify.max_user_instances/d' /etc/sysctl.conf
	sed -i '/net.ipv4.tcp_syncookies/d' /etc/sysctl.conf
	sed -i '/net.ipv4.tcp_fin_timeout/d' /etc/sysctl.conf
	sed -i '/net.ipv4.route.gc_timeout/d' /etc/sysctl.conf
	sed -i '/net.ipv4.tcp_synack_retries/d' /etc/sysctl.conf
	sed -i '/net.ipv4.tcp_syn_retries/d' /etc/sysctl.conf
	sed -i '/net.ipv4.tcp_timestamps/d' /etc/sysctl.conf
	sed -i '/net.ipv4.tcp_max_orphans/d' /etc/sysctl.conf
	sed -i '/net.core.rmem_max/d' /etc/sysctl.conf
	sed -i '/net.core.wmem_max/d' /etc/sysctl.conf
	sed -i '/net.ipv4.tcp_max_syn_backlog/d' /etc/sysctl.conf
	sed -i '/net.core.netdev_max_backlog/d' /etc/sysctl.conf
	sed -i '/net.ipv4.tcp_slow_start_after_idle/d' /etc/sysctl.conf
	sed -i '/net.ipv4.ip_forward/d' /etc/sysctl.conf
	if [[ -e /appex/bin/lotServer.sh ]]; then
		bash <(wget --no-check-certificate -qO- https://github.com/MoeClub/lotServer/raw/master/Install.sh) uninstall
	fi
	clear
	echo -e " ${Info} Hoàn thành tăng tốc server。"
	sleep 1s
}

# Tối ưu hóa cấu hình hệ thống
optimizing_system(){
	sed -i '/fs.file-max/d' /etc/sysctl.conf
	sed -i '/fs.inotify.max_user_instances/d' /etc/sysctl.conf
	sed -i '/net.ipv4.tcp_tw_reuse/d' /etc/sysctl.conf
	sed -i '/net.ipv4.ip_local_port_range/d' /etc/sysctl.conf
	sed -i '/net.ipv4.tcp_rmem/d' /etc/sysctl.conf
	sed -i '/net.ipv4.tcp_wmem/d' /etc/sysctl.conf
	sed -i '/net.core.somaxconn/d' /etc/sysctl.conf
	sed -i '/net.core.rmem_max/d' /etc/sysctl.conf
	sed -i '/net.core.wmem_max/d' /etc/sysctl.conf
	sed -i '/net.core.wmem_default/d' /etc/sysctl.conf
	sed -i '/net.ipv4.tcp_max_tw_buckets/d' /etc/sysctl.conf
	sed -i '/net.ipv4.tcp_max_syn_backlog/d' /etc/sysctl.conf
	sed -i '/net.core.netdev_max_backlog/d' /etc/sysctl.conf
 	sed -i '/net.ipv4.tcp_slow_start_after_idle/d' /etc/sysctl.conf
	sed -i '/net.ipv4.ip_forward/d' /etc/sysctl.conf
	echo "fs.file-max = 1000000
fs.inotify.max_user_instances = 8192
net.ipv4.tcp_tw_reuse = 1
net.ipv4.ip_local_port_range = 1024 65535
net.ipv4.tcp_rmem = 16384 262144 8388608
net.ipv4.tcp_wmem = 32768 524288 16777216
net.core.somaxconn = 8192
net.core.rmem_max = 16777216
net.core.wmem_max = 16777216
net.core.wmem_default = 2097152
net.ipv4.tcp_max_tw_buckets = 5000
net.ipv4.tcp_max_syn_backlog = 10240
net.core.netdev_max_backlog = 10240
net.ipv4.tcp_slow_start_after_idle = 0
# forward ipv4
net.ipv4.ip_forward = 1">>/etc/sysctl.conf
	sysctl -p
	echo "*               soft    nofile           1000000
*               hard    nofile          1000000">/etc/security/limits.conf
	echo "ulimit -SHn 1000000">>/etc/profile
	read -p " Cấu hình tối ưu hóa hệ thống chỉ có hiệu lực sau khi khởi động lại VPS. Bạn có muốn khởi động lại ngay bây giờ không? [Y/n]: " yn
	[ -z "${yn}" ] && yn="y"
	if [[ $yn == [Yy] ]]; then
		echo -e " ${Info} Đang khởi động lại VPS..."
		reboot
	fi
}
# cập nhật kịch bản
Update_Shell(){
	echo -e " Phiên bản hiện tại là [ ${sh_ver} ]，Bắt đầu tìm phiên bản mới nhất..."
	sh_new_ver=$(wget --no-check-certificate -qO- "http://${github}/tcp.sh"|grep 'sh_ver="'|awk -F "=" '{print $NF}'|sed 's/\"//g'|head -1)
	[[ -z ${sh_new_ver} ]] && echo -e " ${Error} Không phát hiện được phiên bản mới nhất !" && start_menu
	if [[ ${sh_new_ver} != ${sh_ver} ]]; then
		echo -e " phiên bản mới được tìm thấy[ ${sh_new_ver} ]，Cập nhật? [Y/n]"
		read -p " (mặc định: y):" yn
		[[ -z "${yn}" ]] && yn="y"
		if [[ ${yn} == [Yy] ]]; then
			wget -N --no-check-certificate http://${github}/tcp.sh && chmod +x tcp.sh
			echo -e " Tập lệnh đã được cập nhật lên phiên bản mới nhất[ ${sh_new_ver} ] !"
		else
			echo && echo "	Đã hủy..." && echo
		fi
	else
		echo -e " Hiện tại là phiên bản mới nhất[ ${sh_new_ver} ] !"
		sleep 5s
	fi
}

# Menu Bắt đầu
start_menu(){
clear
echo && echo -e " Tập lệnh quản lý cài đặt tăng tốc TCP ${Red_font_prefix}[v${sh_ver}]${Font_color_suffix}
 -- Đậu Đậu 5.0 | https://github.com/DauDau432/Linux-NetSpeed --
  
 ${Green_font_prefix}0.${Font_color_suffix} nâng cấp script
———————————— Quản lý mô-đun ————————————
 ${Green_font_prefix}1.${Font_color_suffix} Cài đặt mô-đun được sửa đổi BBR Magic / BBR
 ${Green_font_prefix}2.${Font_color_suffix} Cài đặt mô-đun của phiên bản BBRplus  
 ${Green_font_prefix}3.${Font_color_suffix} Cài đặt mô-đun Lotserver (Tốc độ sắc nét)
———————————— Quản lý tăng tốc ————————————
 ${Green_font_prefix}4.${Font_color_suffix} Sử dụng BBR để tăng tốc
 ${Green_font_prefix}5.${Font_color_suffix} Sử dụng bản sửa đổi BBR Magic để tăng tốc độ
 ${Green_font_prefix}6.${Font_color_suffix} Sử dụng bản sửa đổi BBR Magic violence để tăng tốc (một số hệ thống không được hỗ trợ)
 ${Green_font_prefix}7.${Font_color_suffix} Sử dụng phiên bản BBRplus để tăng tốc
 ${Green_font_prefix}8.${Font_color_suffix} Sử dụng Lotserver (tốc độ nhanh) để tăng tốc
———————————— Quản lý khác ————————————
 ${Green_font_prefix}9.${Font_color_suffix} Gỡ cài đặt tất cả tăng tốc
 ${Green_font_prefix}10.${Font_color_suffix} Tối ưu hóa cấu hình hệ thống
 ${Green_font_prefix}11.${Font_color_suffix} Thoát
————————————————————————————————" && echo

	check_status
	if [[ ${kernel_status} == "noinstall" ]]; then
		echo -e " Tình trạng hiện tại: ${Green_font_prefix}Chưa cài đặt${Font_color_suffix} mô-đun tăng tốc ${Red_font_prefix}Vui lòng cài đặt mô-đun trước${Font_color_suffix}"
	else
		echo -e " Tình trạng hiện tại: ${Green_font_prefix}Đã cài đặt${Font_color_suffix} ${_font_prefix}${kernel_status}${Font_color_suffix} mô-đun tăng tốc, ${Green_font_prefix}${run_status}${Font_color_suffix}"
		
	fi
echo
read -p " Lựa chọn của bạn là [0-11]: " num
case "$num" in
	0)
	Update_Shell
	;;
	1)
	check_sys_bbr
	;;
	2)
	check_sys_bbrplus
	;;
	3)
	check_sys_Lotsever
	;;
	4)
	startbbr
	;;
	5)
	startbbrmod
	;;
	6)
	startbbrmod_nanqinlang
	;;
	7)
	startbbrplus
	;;
	8)
	startlotserver
	;;
	9)
	remove_all
	;;
	10)
	optimizing_system
	;;
	11)
	exit 1
	;;
	*)
	clear
	echo -e " ${Error} Vui lòng nhập số chính xác [0-11]"
	sleep 5s
	start_menu
	;;
esac
}
############# Các thành phần quản lý nhân #############

# loại bỏ các hạt nhân thừa
detele_kernel(){
	if [[ "${release}" == "centos" ]]; then
		rpm_total=`rpm -qa | grep kernel | grep -v "${kernel_version}" | grep -v "noarch" | wc -l`
		if [ "${rpm_total}" > "1" ]; then
			echo -e " Phát hiện ${rpm_total} các mô-đun còn lại, bắt đầu gỡ cài đặt..."
			for((integer = 1; integer <= ${rpm_total}; integer++)); do
				rpm_del=`rpm -qa | grep kernel | grep -v "${kernel_version}" | grep -v "noarch" | head -${integer}`
				echo -e " Bắt đầu gỡ cài đặt ${rpm_del} hạt nhân..."
				rpm --nodeps -e ${rpm_del}
				echo -e " Gỡ cài đặt ${rpm_del} Quá trình gỡ mô-đun đã hoàn tất, hãy tiếp tục..."
			done
			echo --nodeps -e " Quá trình gỡ cài đặt kernel hoàn tất, hãy tiếp tục..."
		else
			echo -e " Đã phát hiện số lõi không chính xác, vui lòng kiểm tra !" && exit 1
		fi
	elif [[ "${release}" == "debian" || "${release}" == "ubuntu" ]]; then
		deb_total=`dpkg -l | grep linux-image | awk '{print $2}' | grep -v "${kernel_version}" | wc -l`
		if [ "${deb_total}" > "1" ]; then
			echo -e " Phát hiện ${deb_total} các mô-đun còn lại, bắt đầu gỡ cài đặt..."
			for((integer = 1; integer <= ${deb_total}; integer++)); do
				deb_del=`dpkg -l|grep linux-image | awk '{print $2}' | grep -v "${kernel_version}" | head -${integer}`
				echo -e " Bắt đầu gỡ cài đặt ${deb_del} mô-đun..."
				apt-get purge -y ${deb_del}
				echo -e " Gỡ cài đặt ${deb_del} Quá trình gỡ mô-đun đã hoàn tất, hãy tiếp tục..."
			done
			echo -e " Quá trình gỡ cài đặt kernel hoàn tất, hãy tiếp tục..."
		else
			echo -e " Đã phát hiện số lõi không chính xác, vui lòng kiểm tra !" && exit 1
		fi
	fi
}

#更新引导
BBR_grub(){
	if [[ "${release}" == "centos" ]]; then
        if [[ ${version} = "6" ]]; then
            if [ ! -f "/boot/grub/grub.conf" ]; then
                echo -e " ${Error} /boot/grub/grub.conf không tìm thấy, vui lòng kiểm tra."
                exit 1
            fi
            sed -i 's/^default=.*/default=0/g' /boot/grub/grub.conf
        elif [[ ${version} = "7" ]]; then
            if [ ! -f "/boot/grub2/grub.cfg" ]; then
                echo -e " ${Error} /boot/grub2/grub.cfg không tìm thấy, vui lòng kiểm tra."
                exit 1
            fi
            grub2-set-default 0
        fi
    elif [[ "${release}" == "debian" || "${release}" == "ubuntu" ]]; then
        /usr/sbin/update-grub
    fi
}

############# Các thành phần quản lý nhân #############



############# Các thành phần kiểm tra hệ thống #############

#检查系统
check_sys(){
	if [[ -f /etc/redhat-release ]]; then
		release="centos"
	elif cat /etc/issue | grep -q -E -i "debian"; then
		release="debian"
	elif cat /etc/issue | grep -q -E -i "ubuntu"; then
		release="ubuntu"
	elif cat /etc/issue | grep -q -E -i "centos|red hat|redhat"; then
		release="centos"
	elif cat /proc/version | grep -q -E -i "debian"; then
		release="debian"
	elif cat /proc/version | grep -q -E -i "ubuntu"; then
		release="ubuntu"
	elif cat /proc/version | grep -q -E -i "centos|red hat|redhat"; then
		release="centos"
    fi
}

#检查Linux版本
check_version(){
	if [[ -s /etc/redhat-release ]]; then
		version=`grep -oE  "[0-9.]+" /etc/redhat-release | cut -d . -f 1`
	else
		version=`grep -oE  "[0-9.]+" /etc/issue | cut -d . -f 1`
	fi
	bit=`uname -m`
	if [[ ${bit} = "x86_64" ]]; then
		bit="x64"
	else
		bit="x32"
	fi
}

# Kiểm tra các yêu cầu hệ thống để cài đặt bbr
check_sys_bbr(){
	check_version
	if [[ "${release}" == "centos" ]]; then
		if [[ ${version} -ge "6" ]]; then
			installbbr
		else
			echo -e " ${Error} Mô-đun BBR không hỗ trợ hệ thống hiện tại ${release} ${version} ${bit} !" && exit 1
		fi
	elif [[ "${release}" == "debian" ]]; then
		if [[ ${version} -ge "8" ]]; then
			installbbr
		else
			echo -e " ${Error} Mô-đun BBR không hỗ trợ hệ thống hiện tại ${release} ${version} ${bit} !" && exit 1
		fi
	elif [[ "${release}" == "ubuntu" ]]; then
		if [[ ${version} -ge "14" ]]; then
			installbbr
		else
			echo -e " ${Error} Mô-đun BBR không hỗ trợ hệ thống hiện tại ${release} ${version} ${bit} !" && exit 1
		fi
	else
		echo -e " ${Error} Mô-đun BBR không hỗ trợ hệ thống hiện tại ${release} ${version} ${bit} !" && exit 1
	fi
}

check_sys_bbrplus(){
	check_version
	if [[ "${release}" == "centos" ]]; then
		if [[ ${version} -ge "6" ]]; then
			installbbrplus
		else
			echo -e " ${Error} Mô-đun BBRplus không hỗ trợ hệ thống hiện tại ${release} ${version} ${bit} !" && exit 1
		fi
	elif [[ "${release}" == "debian" ]]; then
		if [[ ${version} -ge "8" ]]; then
			installbbrplus
		else
			echo -e " ${Error} Mô-đun BBRplus không hỗ trợ hệ thống hiện tại ${release} ${version} ${bit} !" && exit 1
		fi
	elif [[ "${release}" == "ubuntu" ]]; then
		if [[ ${version} -ge "14" ]]; then
			installbbrplus
		else
			echo -e " ${Error} Mô-đun BBRplus không hỗ trợ hệ thống hiện tại ${release} ${version} ${bit} !" && exit 1
		fi
	else
		echo -e " ${Error} Mô-đun BBRplus không hỗ trợ hệ thống hiện tại ${release} ${version} ${bit} !" && exit 1
	fi
}


# Kiểm tra các yêu cầu hệ thống để cài đặt Lotusever
check_sys_Lotsever(){
	check_version
	if [[ "${release}" == "centos" ]]; then
		if [[ ${version} == "6" ]]; then
			kernel_version="2.6.32-504"
			installlot
		elif [[ ${version} == "7" ]]; then
			yum -y install net-tools
			kernel_version="3.10.0-327"
			installlot
		else
			echo -e " ${Error} Lotsever không hỗ trợ hệ thống hiện tại ${release} ${version} ${bit} !" && exit 1
		fi
	elif [[ "${release}" == "debian" ]]; then
		if [[ ${version} = "7" || ${version} = "8" ]]; then
			if [[ ${bit} == "x64" ]]; then
				kernel_version="3.16.0-4"
				installlot
			elif [[ ${bit} == "x32" ]]; then
				kernel_version="3.2.0-4"
				installlot
			fi
		elif [[ ${version} = "9" ]]; then
			if [[ ${bit} == "x64" ]]; then
				kernel_version="4.9.0-4"
				installlot
			fi
		else
			echo -e " ${Error} Lotsever không hỗ trợ hệ thống hiện tại ${release} ${version} ${bit} !" && exit 1
		fi
	elif [[ "${release}" == "ubuntu" ]]; then
		if [[ ${version} -ge "12" ]]; then
			if [[ ${bit} == "x64" ]]; then
				kernel_version="4.8.0-36"
				installlot
			elif [[ ${bit} == "x32" ]]; then
				kernel_version="3.13.0-29"
				installlot
			fi
		else
			echo -e " ${Error} Lotsever không hỗ trợ hệ thống hiện tại ${release} ${version} ${bit} !" && exit 1
		fi
	else
		echo -e " ${Error} Lotsever không hỗ trợ hệ thống hiện tại ${release} ${version} ${bit} !" && exit 1
	fi
}

check_status(){
	kernel_version=`uname -r | awk -F "-" '{print $1}'`
	kernel_version_full=`uname -r`
	if [[ ${kernel_version_full} = "4.14.129-bbrplus" ]]; then
		kernel_status="BBRplus"
	elif [[ ${kernel_version} = "3.10.0" || ${kernel_version} = "3.16.0" || ${kernel_version} = "3.2.0" || ${kernel_version} = "4.8.0" || ${kernel_version} = "3.13.0"  || ${kernel_version} = "2.6.32" || ${kernel_version} = "4.9.0" ]]; then
		kernel_status="Lotserver"
	elif [[ `echo ${kernel_version} | awk -F'.' '{print $1}'` == "4" ]] && [[ `echo ${kernel_version} | awk -F'.' '{print $2}'` -ge 9 ]] || [[ `echo ${kernel_version} | awk -F'.' '{print $1}'` -ge "5" ]]; then
		kernel_status="BBR"
	else 
		kernel_status="noinstall"
	fi

	if [[ ${kernel_status} == "Lotserver" ]]; then
		if [[ -e /appex/bin/lotServer.sh ]]; then
			run_status=`bash /appex/bin/lotServer.sh status | grep "LotServer" | awk  '{print $3}'`
			if [[ ${run_status} = "running!" ]]; then
				run_status=" Đã bật thành công"
			else 
				run_status=" không thể kích hoạt"
			fi
		else 
			run_status=" Mô-đun tăng tốc chưa được cài đặt"
		fi
	elif [[ ${kernel_status} == "BBR" ]]; then
		run_status=`grep "net.ipv4.tcp_congestion_control" /etc/sysctl.conf | awk -F "=" '{gsub("^[ \t]+|[ \t]+$", "", $2);print $2}'`
		if [[ ${run_status} == "bbr" ]]; then
			run_status=`lsmod | grep "bbr" | awk '{print $1}'`
			if [[ ${run_status} == "tcp_bbr" ]]; then
				run_status=" BBR đã bật thành công"
			else 
				run_status=" BBR không khởi động được"
			fi
		elif [[ ${run_status} == "tsunami" ]]; then
			run_status=`lsmod | grep "tsunami" | awk '{print $1}'`
			if [[ ${run_status} == "tcp_tsunami" ]]; then
				run_status=" Bản sửa đổi BBR Magic đã bật thành công"
			else 
				run_status=" Không thể sửa đổi BBR Magic"
			fi
		elif [[ ${run_status} == "nanqinlang" ]]; then
			run_status=`lsmod | grep "nanqinlang" | awk '{print $1}'`
			if [[ ${run_status} == "tcp_nanqinlang" ]]; then
				run_status=" Đã khởi chạy thành công bản sửa đổi BBR Magic violence"
			else 
				run_status=" Không thể khởi động bản sửa đổi BBR Magic violence"
			fi
		else 
			run_status=" Mô-đun tăng tốc chưa được cài đặt"
		fi
	elif [[ ${kernel_status} == "BBRplus" ]]; then
		run_status=`grep "net.ipv4.tcp_congestion_control" /etc/sysctl.conf | awk -F "=" '{gsub("^[ \t]+|[ \t]+$", "", $2);print $2}'`
		if [[ ${run_status} == "bbrplus" ]]; then
			run_status=`lsmod | grep "bbrplus" | awk '{print $1}'`
			if [[ ${run_status} == "tcp_bbrplus" ]]; then
				run_status=" BBRplus đã bật thành công"
			else 
				run_status=" BBRplus không khởi động được"
			fi
		else 
			run_status=" Mô-đun tăng tốc chưa được cài đặt"
		fi
	fi
}

############# Các thành phần kiểm tra hệ thống #############
check_sys
check_version
[[ ${release} != "debian" ]] && [[ ${release} != "ubuntu" ]] && [[ ${release} != "centos" ]] && echo -e " ${Error} Script này không hỗ trợ hệ thống hiện tại ${release} !" && exit 1
start_menu

