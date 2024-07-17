FROM alpine:edge

# Install dependencies
RUN apk add --no-cache python3 py3-pip xvfb x11vnc openbox xterm \
    gtk+3.0 gdk-pixbuf libnotify gobject-introspection \
    py3-gobject3 py3-cairo py3-mutagen py3-geoip2 \
    python3-dev build-base cairo-dev pkgconfig \
    gobject-introspection-dev \
    tigervnc

# Set up a user
RUN adduser -D guacuser
USER guacuser
WORKDIR /home/guacuser

# Create virtual environment and install Nicotine+
RUN python3 -m venv /home/guacuser/nicotine-venv && \
    . /home/guacuser/nicotine-venv/bin/activate && \
    pip install --upgrade pip && \
    pip install --no-cache-dir nicotine-plus && \
    deactivate

# Set up VNC
RUN mkdir -p /home/guacuser/.vnc && \
    echo "password" | vncpasswd -f > /home/guacuser/.vnc/passwd && \
    chmod 600 /home/guacuser/.vnc/passwd

# Create xstartup file to launch Nicotine+ in fullscreen
RUN echo '#!/bin/sh' > /home/guacuser/.vnc/xstartup && \
    echo 'Xvfb :1 -screen 0 1280x800x24 &' >> /home/guacuser/.vnc/xstartup && \
    echo 'export DISPLAY=:1' >> /home/guacuser/.vnc/xstartup && \
    echo 'openbox &' >> /home/guacuser/.vnc/xstartup && \
    echo '. /home/guacuser/nicotine-venv/bin/activate' >> /home/guacuser/.vnc/xstartup && \
    echo 'nicotine --fullscreen &' >> /home/guacuser/.vnc/xstartup && \
    echo 'x11vnc -display :1 -forever -usepw -create' >> /home/guacuser/.vnc/xstartup && \
    chmod +x /home/guacuser/.vnc/xstartup

EXPOSE 5900

CMD ["/bin/sh", "-c", "/home/guacuser/.vnc/xstartup"]
