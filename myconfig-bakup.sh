#/bin/bash
#param 1:
#get:       backup config
#set:       recover config

FILES=`basename $0`
FILES=$FILES' .vimrc 
.bashrc
.zshrc
.profile
.vnc/xstartup
.gitconfig
.oh-my-zsh
.vim
.vimrc
.tmux.conf
.tmux-plugin
'
MYSMB_CONF="
[homes]\n
    comment = workdir\n
    browseable = yes\n
    guest ok = no\n
    writable = yes\n
    valid users = %S\n
    create mask = 0755\n
    directory mask = 0755\n
"
APT_SOFTWARE="tmux vim samba ranger "

backup_settting()
{
    echo 'backup settings'
    #echo $FILES
    tar -czvPf ronnie-config-`date +%Y%m%d-%H%M`.tgz $FILES

}



update_aptsourcelist()
{
    #apt source.  force set
    APT_LIST=" #apt update   \n
    deb https://mirrors.tuna.tsinghua.edu.cn/ubuntu/ xenial main restricted universe multiverse \n
    # deb-src https://mirrors.tuna.tsinghua.edu.cn/ubuntu/ xenial main restricted universe multiverse \n
    deb https://mirrors.tuna.tsinghua.edu.cn/ubuntu/ xenial-updates main restricted universe multiverse \n
    # deb-src https://mirrors.tuna.tsinghua.edu.cn/ubuntu/ xenial-updates main restricted universe multiverse \n
    deb https://mirrors.tuna.tsinghua.edu.cn/ubuntu/ xenial-backports main restricted universe multiverse \n
    # deb-src https://mirrors.tuna.tsinghua.edu.cn/ubuntu/ xenial-backports main restricted universe multiverse \n
    deb https://mirrors.tuna.tsinghua.edu.cn/ubuntu/ xenial-security main restricted universe multiverse \n
    # deb-src https://mirrors.tuna.tsinghua.edu.cn/ubuntu/ xenial-security main restricted universe multiverse \n
    "
    if [ ! -f /etc/apt/sources.list.baks ]; then
        cp /etc/apt/sources.list  /etc/apt/sources.list.baks
        echo 'backup sourcelist file'
    fi
    echo -e $APT_LIST  > /etc/apt/sources.list
}

recover_settting()
{
    echo 'recover settings'
    update_aptsourcelist
    apt-get update
    apt-get install $APT_SOFTWARE
    
    #samba: add my samba directory
    ret=`grep -c 'workdir' /etc/samba/smb.conf`
    if [ $ret -eq 0 ]; then
        echo 'update samba conf.'
        sudo cat mysmb.conf >> /etc/samba/smb.conf
    fi
    smbpasswd -a ronnie
    service smbd restart
}

case $1 in
get)
    backup_settting
    ;;
set)
    recover_settting
    ;;
*)
    echo 'not set the operation.'
    ;;
esac


exit




