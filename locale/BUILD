package(default_visibility = ["//:__subpackages__"])

load("//base:distro.bzl", "DISTRO_PACKAGES", "DISTRO_SUFFIXES")
load("//:checksums.bzl", "ARCHITECTURES")
load(":locale.bzl", "locale")

DISTRO_SUFFIXES = DISTRO_SUFFIXES if "_debian11" in DISTRO_SUFFIXES else DISTRO_SUFFIXES + ["_debian11"]

[
    locale(
        name = "locale_" + arch + distro_suffix,
        deb = DISTRO_PACKAGES[arch][distro_suffix]["libc-bin"],
    )
    for arch in ARCHITECTURES
    for distro_suffix in DISTRO_SUFFIXES
]
