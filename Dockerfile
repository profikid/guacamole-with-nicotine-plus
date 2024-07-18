FROM alpine:edge

# Install dependencies
RUN apk add --no-cache python3 py3-pip xvfb x11vnc openbox xterm \
    gtk+3.0 gdk-pixbuf libnotify gobject-introspection \
    py3-gobject3 py3-cairo py3-mutagen py3-geoip2 \
    python3-dev build-base cairo-dev pkgconfig \
    gobject-introspection-dev \
    tigervnc xorg-server

# Set up X11 unix socket directory
RUN mkdir -p /tmp/.X11-unix && chmod 1777 /tmp/.X11-unix

# Set up a user
RUN adduser -D guacuser
USER guacuser
WORKDIR /home/guacuser

# Create virtual environment and install Nicotine+
RUN python3 -m venv /home/guacuser/nicotine-venv && \
    . /home/guacuser/nicotine-venv/bin/activate && \
    pip install --upgrade pip && \
    pip install --no-cache-dir nicotine-plus pyxdg && \
    deactivate

# Set up VNC
RUN mkdir -p /home/guacuser/.vnc && \
    echo "password" | vncpasswd -f > /home/guacuser/.vnc/passwd && \
    chmod 600 /home/guacuser/.vnc/passwd

# Create necessary files and directories
RUN touch /home/guacuser/.Xauthority && \
    mkdir -p /home/guacuser/.config/openbox

# Create .xinitrc file
RUN echo '#!/bin/sh' > /home/guacuser/.xinitrc && \
    echo 'openbox-session &' >> /home/guacuser/.xinitrc && \
    echo '. /home/guacuser/nicotine-venv/bin/activate' >> /home/guacuser/.xinitrc && \
    echo 'nicotine &' >> /home/guacuser/.xinitrc && \
    echo 'exec xterm' >> /home/guacuser/.xinitrc

# Create xstartup file to launch X server and Nicotine+
RUN echo '#!/bin/sh' > /home/guacuser/.vnc/xstartup && \
    echo 'Xvfb :0 -screen 0 1280x800x24 &' >> /home/guacuser/.vnc/xstartup && \
    echo 'export DISPLAY=:0' >> /home/guacuser/.vnc/xstartup && \
    echo 'x11vnc -display :0 -forever -usepw -create &' >> /home/guacuser/.vnc/xstartup && \
    echo 'sleep 1' >> /home/guacuser/.vnc/xstartup && \
    echo 'openbox-session &' >> /home/guacuser/.vnc/xstartup && \
    echo '. /home/guacuser/nicotine-venv/bin/activate' >> /home/guacuser/.vnc/xstartup && \
    echo 'nicotine &' >> /home/guacuser/.vnc/xstartup && \
    echo 'exec xterm' >> /home/guacuser/.vnc/xstartup && \
    chmod +x /home/guacuser/.vnc/xstartup

EXPOSE 5900

CMD ["/bin/sh", "-c", "/home/guacuser/.vnc/xstartup"]
