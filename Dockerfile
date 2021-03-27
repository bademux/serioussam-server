#download once for multiarch build
FROM scratch as caching-downloader
ADD https://github.com/ptitSeb/Serious-Engine/archive/d11af2bad8fc216a4408cf2fc658227599130e10.zip /target.zip

FROM alpine:3.13.3 as builder
RUN apk add --no-cache --update bash libarchive-tools flex bison cmake build-base coreutils libvorbis-dev libogg-dev zlib-dev sdl2-dev
COPY --from=caching-downloader / /tmp
WORKDIR /build
RUN mkdir target && bsdtar -zxvf /tmp/target.zip --strip-components=1 -C target
#Hackfix for https://github.com/ptitSeb/Serious-Engine/issues/27
RUN printf ''\
'@@ -107,0 +108 @@\n'\
'+        if (module == NULL) DoOpen(fnm.FileName()+fnm.FileExt());\n'\
| patch target/Sources/Engine/Base/Unix/UnixDynamicLoader.cpp && \
    printf ''\
'@@ -274 +274 @@\n'\
'-  _pFileSystem->GetExecutablePath(strExePath, sizeof (strExePath)-1);\n'\
'+ _pFileSystem->GetUserDirectory(strExePath, sizeof (strExePath)-1);\n'\
| patch target/Sources/Engine/Engine.cpp
RUN cmake target/Sources -DCMAKE_BUILD_TYPE=RelWithDebInfo -DBUILD_DEDICATED_SERVER=TRUE && \ 
    make GameMP EntitiesMP Shaders SeriousSamDedicated -j$(nproc)

FROM alpine:3.13.3
MAINTAINER bademux
RUN apk add --no-cache --update libstdc++ sdl2 libgcc
ENV LD_LIBRARY_PATH="$LD_LIBRARY_PATH:/usr/local/lib64:/usr/local/lib"
EXPOSE 25600/udp
EXPOSE 25600/tcp
COPY --from=builder /build/SeriousSamDedicated /usr/local/bin/
COPY --from=builder /build/Debug /usr/local/lib64/
RUN adduser user --disabled-password
USER user
ENTRYPOINT ["SeriousSamDedicated", "DefaultCoop"]
