# Build
```bash
docker build . -t bademux/serioussam-server
```

# Run
Install with Steam binaries

```bash
#prepare
GAME_DIR="$HOME/.steam/debian-installation/steamapps/common/Serious Sam Classic The Second Encounter"
mkdir -p "$GAME_DIR/serioussam" #Game attemts to write into mounted directory
touch "$GAME_DIR/Bin/libEntitiesMP.so" # for some reason SSServer attemts to open libEntitiesMP.so
curl -L https://github.com/ptitSeb/Serious-Engine/raw/master/SE1_10.gro -o "$GAME_DIR/SE1_10.gro"
#run
docker run -it -p 25600:25600/udp -p 25600:25600/tcp \
  -v "$GAME_DIR":"/home/user/.local/share/Serious Engine" \
  bademux/serioussam-server DefaultCoop
```

# Sources
https://github.com/bademux/serioussam-server

# Docker Registry
https://hub.docker.com/r/bademux/serioussam-server

# Refs
https://github.com/ptitSeb/Serious-Engine

