#!/bin/bash
set -e

BUSYBOX_VERSION="1.36.1"
WORKDIR="$(cd "$(dirname "$0")" && pwd)"
MUSL_INSTALL="${WORKDIR}/../musl/install"
BUILDDIR="${WORKDIR}/build"

mkdir -p "${BUILDDIR}"

# Скачиваем
if [ ! -f "busybox-${BUSYBOX_VERSION}.tar.bz2" ]; then
    wget "https://busybox.net/downloads/busybox-${BUSYBOX_VERSION}.tar.bz2"
fi

# Распаковываем
tar xf "busybox-${BUSYBOX_VERSION}.tar.bz2" -C "${BUILDDIR}"
cd "${BUILDDIR}/busybox-${BUSYBOX_VERSION}"

# Копируем наш конфиг
cp "${WORKDIR}/busybox-config" .config

# Статическая сборка с musl
export CC="${MUSL_INSTALL}/bin/musl-gcc"
export CFLAGS="-static -Os -s"
export LDFLAGS="-static"

make oldconfig
make -j$(nproc) CC="${CC}"
make install CONFIG_PREFIX="${WORKDIR}/install"

# Проверяем, что статический
echo "Проверка:"
file "${WORKDIR}/install/bin/busybox"
ldd "${WORKDIR}/install/bin/busybox" 2>&1 || echo "(ожидаемо не динамический)"

cp "${WORKDIR}/install/bin/busybox" "${WORKDIR}/busybox-static"
echo "Готово: ${WORKDIR}/busybox-static"
