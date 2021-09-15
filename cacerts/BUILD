package(default_visibility = ["//:__subpackages__"])

load("//base:distro.bzl", "DISTRO_SUFFIXES")
load("//:checksums.bzl", "ARCHITECTURES")
load(":cacerts.bzl", "cacerts")
load(":java.bzl", "cacerts_java")

DISTRO_SUFFIXES = DISTRO_SUFFIXES if "_debian11" in DISTRO_SUFFIXES else DISTRO_SUFFIXES + ["_debian11"]

[
    cacerts_java(
        name = "cacerts_java_" + arch + distro_suffix,
        cacerts_tar = "//base:cacerts_" + arch + distro_suffix,
    )
    for arch in ARCHITECTURES
    for distro_suffix in DISTRO_SUFFIXES
]
