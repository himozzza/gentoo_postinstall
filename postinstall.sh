#!/bin/bash

set_passwd_root="yes"                                                           # Set ROOT passwd. Comment to disable.
add_new_user="yes"                                                              # Add new USER. Comment to disable.
user="ivan"                                                                     # Set Username.
sudo_nopasswd="yes"                                                             # Set nopasswd sudo. Comment to disable.
#---------------
services_enable="yes"                                                           # Set enable NetworkManager, bluetooth, sshd with start computer. Comment to disable.
services_list=("NetworkManager" "bluetooth" "sshd" "dbus-broker" "pipewire")    # List services to upload whith start.
#---------------
set_locales="yes"                                                               # Set Locales. Comment to disable.
locales=("en_US.UTF-8 UTF-8" "ru_RU.UTF-8 UTF-8")                               # Set Locale list.
locale_default="ru_RU"                                                          # Set Locale default.
#---------------
layout_hotkey="yes"                                                             # Set layout hotkey. Shift+Alt by default. Comment to disable.
hostname="gentoo"                                                               # Set Hostname.



if [[ $(whoami) == "root" ]]; then
    echo $hostname > /etc/hostname
    function root_passwd {
        echo -en "\nROOT passwd :) \n"
        passwd 1> /dev/null
        echo -en "\n"
    }

    function nopasswd_sudo {
        if ! sed -i "s/# %wheel ALL=(ALL:ALL) NOPASSWD: ALL/%wheel ALL=(ALL:ALL) NOPASSWD: ALL/g" /etc/sudoers; then
            echo -en "SUDO not installed.\nPlease run 'emerge --ask sudo' and restart this script.\nExit...\n\n"
            exit
        else
            return
        fi
    }

    function locales_settings {
        for locale in "${locales[@]}"; do
            if grep "${locale}" /etc/locale.gen &> /dev/null; then
                echo -en "Locale '$locale' already installed.\nSkipped.\n\n"
                continue
            else
                echo "${locale}" >> /etc/locale.gen
                continue
            fi
        done
        locale-gen &> /dev/null
        if ! eselect locale list | grep $locale_default 1> /dev/null; then
            echo -en "Locale not found.\nExit...\n\n"
            exit
        else
            localeset=$(eselect locale list | grep $locale_default | cut -b 4)
            eselect locale set "$localeset" 1> /dev/null
        fi
    }

    function user_add {
        if ! useradd -m -G tty,disk,mem,wheel,news,console,audio,cdrom,tape,dialout,video,cdrw,usb,input,users,portage,sshd,render,kvm,polkitd,plugdev,flatpak,colord,gdm,geoclue -s /bin/bash $user 1> /dev/null; then
            echo -en "Failed to append USER.\nExit...\n\n"
            exit
        else
            echo -en "USER passwd :) \n"
            passwd $user 1> /dev/null
        fi
    }



    if [[ $set_passwd_root == "yes" ]]; then
        root_passwd
    fi

    if [[ $sudo_nopasswd == "yes" ]]; then
        nopasswd_sudo
    fi

    if [[ $set_locales == "yes" ]]; then
        locales_settings "$(locales)" $locale_default
    fi

    if [[ $add_new_user == "yes" ]]; then
        user_add $user
    fi

    echo -en "Fine! Process complete.\nPlease login to USER and restart this script. :)\n\n"
elif [[ $(whoami) == "$user" ]]; then
    function services {
        for service in "${services_list[@]}"; do
            if [[ "$service" == "dbus-broker" ]]; then
                systemctl disable dbus
                systemctl --global enable "$service"
                continue
            elif [[ "$service" == "pipewire" ]]; then
                pa_client=$(grep "autospawn" /etc/pulse/client.conf)
                pa_daemon=$(grep "daemonize" /etc/pulse/daemon.conf)
                if ! sudo sed -i "s/${pa_daemon}/daemonize = no/g" /etc/pulse/daemon.conf 1> /dev/null; then
                    continue
                else
                    continue
                fi
                sudo sed -i "s/${pa_client}/autospawn = no/g" /etc/pulse/client.conf
                systemctl --user disable --now pulseaudio.socket pulseaudio.service
                systemctl --user enable --now pipewire.socket pipewire-pulse.socket wireplumber.service
                systemctl --user mask pulseaudio.socket pulseaudio.service
            else
                systemctl enable "$service"
                continue
            fi
        done
    }

    function layout {
        gsettings set org.gnome.desktop.wm.keybindings switch-input-source "['<Shift>Alt_L']"
        gsettings set org.gnome.desktop.wm.keybindings switch-input-source-backward "['<Alt>Shift_L']"
    }

    if [[ $services_enable == "yes" ]]; then    # Start enable services.
        services "${services_list[@]}"
    fi
    if [[ $layout_hotkey == "yes" ]];then       # Set layout hotkey.
    layout
    fi

    echo -en "\nComplete! :)\n\n"
fi
