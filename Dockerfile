# Use the official Colab base image
FROM gcr.io/deeplearning-platform-release/base-cpu

# Set the environment variables
ENV USER=user
ENV PASSWORD=root
ENV DEBIAN_FRONTEND=noninteractive

# Install required packages
RUN apt-get update && \
    apt-get install -y sudo && \
    apt-get install -y wget && \
    apt-get install -y xfce4 desktop-base xfce4-terminal && \
    apt-get install -y xscreensaver && \
    apt-get install -y google-chrome-stable

# Create user, add to sudo group, set password, and change shell
RUN useradd -m $USER && \
    adduser $USER sudo && \
    echo "$USER:$PASSWORD" | chpasswd && \
    sed -i 's/\/bin\/sh/\/bin\/bash/g' /etc/passwd

# Install Chrome Remote Desktop
RUN wget https://dl.google.com/linux/direct/chrome-remote-desktop_current_amd64.deb && \
    dpkg --install chrome-remote-desktop_current_amd64.deb && \
    apt-get install --assume-yes --fix-broken

# Configure desktop environment
RUN bash -c 'echo "exec /etc/X11/Xsession /usr/bin/xfce4-session" > /etc/chrome-remote-desktop-session' && \
    apt remove --assume-yes gnome-terminal && \
    apt install --assume-yes xscreensaver && \
    systemctl disable lightdm.service

# Finalize setup
RUN adduser $USER chrome-remote-desktop

# Expose necessary ports
EXPOSE 3389 5901

# Start Chrome Remote Desktop service
CMD ["bash", "-c", "service chrome-remote-desktop start"]

# Command to start Chrome Remote Desktop host
CMD ["bash", "-c", "DISPLAY= /opt/google/chrome-remote-desktop/start-host --code='4/0AfJohXl4fyifo3KF_Cl0DqzzlsAMqn3jgAClWxF4A4wlTyBXJajk_WzQjZJKPQBykgnJ-g' --redirect-url='https://remotedesktop.google.com/_/oauthredirect' --name=$(hostname)"]
