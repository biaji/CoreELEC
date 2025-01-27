# SPDX-License-Identifier: GPL-2.0-or-later
# Copyright (C) 2009-2016 Stephan Raue (stephan@openelec.tv)
# Copyright (C) 2018-present Team LibreELEC (https://libreelec.tv)

PKG_NAME="SDL2"
PKG_VERSION="2.0.22"
PKG_SHA256="fe7cbf3127882e3fc7259a75a0cb585620272c51745d3852ab9dd87960697f2e"
PKG_LICENSE="GPL"
PKG_SITE="https://www.libsdl.org/"
PKG_URL="https://www.libsdl.org/release/${PKG_NAME}-${PKG_VERSION}.tar.gz"
PKG_DEPENDS_TARGET="toolchain alsa-lib systemd dbus"
PKG_LONGDESC="A cross-platform multimedia library designed to provide fast access to the graphics framebuffer and audio device. "
PKG_BUILD_FLAGS="+pic"

if [ "${TARGET_ARCH}" = "x86_64" ]; then
  PKG_DEPENDS_TARGET+=" nasm:host"
  PKG_SDL2_X86ASM="-DASSEMBLY=ON"
else
  # Only x86(-64) and ppc assembly present as of 2.0.8
  PKG_SDL2_X86ASM="-DASSEMBLY=OFF"
fi

PKG_CMAKE_OPTS_TARGET="-DSDL_STATIC=ON \
                       -DSDL_SHARED=OFF \
                       -DLIBC=ON \
                       -DGCC_ATOMICS=ON \
                       ${PKG_SDL2_X86ASM} \
                       -DALTIVEC=OFF \
                       -DOSS=OFF \
                       -DALSA=ON \
                       -DALSA_SHARED=ON \
                       -DESD=OFF \
                       -DESD_SHARED=OFF \
                       -DARTS=OFF \
                       -DARTS_SHARED=OFF \
                       -DNAS=OFF \
                       -DNAS_SHARED=ON \
                       -DSNDIO=OFF \
                       -DDISKAUDIO=OFF \
                       -DDUMMYAUDIO=OFF \
                       -DVIDEO_WAYLAND=OFF \
                       -DVIDEO_WAYLAND_QT_TOUCH=ON \
                       -DWAYLAND_SHARED=OFF \
                       -DVIDEO_MIR=OFF \
                       -DMIR_SHARED=OFF \
                       -DVIDEO_COCOA=OFF \
                       -DVIDEO_DIRECTFB=OFF \
                       -DDIRECTFB_SHARED=OFF \
                       -DFUSIONSOUND=OFF \
                       -DFUSIONSOUND_SHARED=OFF \
                       -DVIDEO_DUMMY=OFF \
                       -DINPUT_TSLIB=OFF \
                       -DPTHREADS=ON \
                       -DPTHREADS_SEM=ON \
                       -DDIRECTX=OFF \
                       -DSDL_DLOPEN=ON \
                       -DCLOCK_GETTIME=OFF \
                       -DRPATH=OFF \
		       -DVIDEO_KMSDRM=OFF \
                       -DRENDER_D3D=OFF"

if [ "${DISPLAYSERVER}" = "x11" ]; then
  PKG_DEPENDS_TARGET+=" libX11 libXrandr"

  PKG_CMAKE_OPTS_TARGET="${PKG_CMAKE_OPTS_TARGET} \
                         -DVIDEO_X11=ON \
                         -DX11_SHARED=ON \
                         -DVIDEO_X11_XCURSOR=OFF \
                         -DVIDEO_X11_XINERAMA=OFF \
                         -DVIDEO_X11_XINPUT=OFF \
                         -DVIDEO_X11_XRANDR=ON \
                         -DVIDEO_X11_XSCRNSAVER=OFF \
                         -DVIDEO_X11_XSHAPE=OFF \
                         -DVIDEO_X11_XVM=OFF"
else
  PKG_CMAKE_OPTS_TARGET="${PKG_CMAKE_OPTS_TARGET} \
                         -DVIDEO_X11=OFF"
fi

if [ ! "${OPENGL}" = "no" ]; then
  PKG_DEPENDS_TARGET+=" ${OPENGL}"

  PKG_CMAKE_OPTS_TARGET="${PKG_CMAKE_OPTS_TARGET} \
                         -DVIDEO_OPENGL=ON \
                         -DVIDEO_OPENGLES=OFF"
else
  PKG_CMAKE_OPTS_TARGET="${PKG_CMAKE_OPTS_TARGET} \
                         -DVIDEO_OPENGL=OFF \
                         -DVIDEO_OPENGLES=ON"
fi

if [ "${PULSEAUDIO_SUPPORT}" = yes ]; then
  PKG_DEPENDS_TARGET+=" pulseaudio"

  PKG_CMAKE_OPTS_TARGET="${PKG_CMAKE_OPTS_TARGET} \
                         -DPULSEAUDIO=ON \
                         -DPULSEAUDIO_SHARED=ON"
else
  PKG_CMAKE_OPTS_TARGET="${PKG_CMAKE_OPTS_TARGET} \
                         -DPULSEAUDIO=OFF \
                         -DPULSEAUDIO_SHARED=OFF"
fi

post_makeinstall_target() {
  sed -e "s:\(['=\" ]\)/usr:\\1${SYSROOT_PREFIX}/usr:g" -i ${SYSROOT_PREFIX}/usr/bin/sdl2-config

  rm -rf ${INSTALL}/usr/bin
}
