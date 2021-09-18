package(default_visibility = ["//visibility:public"])

load("//base:distro.bzl", "DISTRO_PACKAGES", "DISTRO_SUFFIXES")
load("@io_bazel_rules_docker//container:container.bzl", "container_image")
load("@io_bazel_rules_docker//contrib:test.bzl", "container_test")
load("@io_bazel_rules_docker//java:image.bzl", "java_image")
load("@package_bundle_amd64_debian10//file:packages.bzl", versions_amd64_debian10 = "versions")
load("@package_bundle_amd64_debian11//file:packages.bzl", versions_amd64_debian11 = "versions")
load("@bazel_tools//tools/build_defs/pkg:pkg.bzl", "pkg_tar")
load("//cacerts:java.bzl", "cacerts_java")
load("//java:jre_ver.bzl", "jre_ver")

DISTRO_SUFFIXES = DISTRO_SUFFIXES if "_debian11" in DISTRO_SUFFIXES else DISTRO_SUFFIXES + ["_debian11"]

DISTRO_VERSIONS = {
    "_debian10": versions_amd64_debian10,
    "_debian11": versions_amd64_debian11,
}

JAVA_DISTROS = {
    "java11": "_debian10",
    "java17": "_debian11",
}

USERS = [
    "root",
    "nonroot",
]

pkg_tar(
    name = "java17_jre_layer",
    package_dir = "/usr/lib/jvm/",
    deps = ["@jdks//:zulu17.28.13-ca-jre17.0.0-linux_x64.tar.gz"],
    #symlinks = { "/usr/lib/jvm/java-17-openjdk-amd64": "/jdk-17" },
    mode = "0644",
)

pkg_tar(
    name = "java17_jdk_layer",
    package_dir = "/usr/lib/jvm/",
    deps = ["@jdks//:zulu17.28.13-ca-jdk17.0.0-linux_x64.tar.gz"],
    #symlinks = { "/usr/lib/jvm/java-17-openjdk-amd64": "/jdk-17" },
    mode = "0644",
)

[
    container_image(
        name = "java_base" + mode + "_" + user + distro_suffix,
        base = ("//cc:cc" if (not ("debug" in mode)) else "//cc:debug") + "_" + user + "_amd64" + distro_suffix,
        debs = [
            DISTRO_PACKAGES["amd64"][distro_suffix]["zlib1g"],
            DISTRO_PACKAGES["amd64"][distro_suffix]["libjpeg62-turbo"],
            DISTRO_PACKAGES["amd64"][distro_suffix]["libpng16-16"],
            DISTRO_PACKAGES["amd64"][distro_suffix]["liblcms2-2"],
            DISTRO_PACKAGES["amd64"][distro_suffix]["libfreetype6"],
            DISTRO_PACKAGES["amd64"][distro_suffix]["fonts-dejavu-core"],
            DISTRO_PACKAGES["amd64"][distro_suffix]["fontconfig-config"],
            DISTRO_PACKAGES["amd64"][distro_suffix]["libexpat1"],
            DISTRO_PACKAGES["amd64"][distro_suffix]["libfontconfig1"],
            DISTRO_PACKAGES["amd64"][distro_suffix]["libuuid1"],
            DISTRO_PACKAGES["amd64"][distro_suffix]["libgraphite2-3"],
            DISTRO_PACKAGES["amd64"][distro_suffix]["libharfbuzz0b"],
            DISTRO_PACKAGES["amd64"][distro_suffix]["libglib2.0-0"],
            DISTRO_PACKAGES["amd64"][distro_suffix]["libpcre3"],
        ],
        env = {"LANG": "C.UTF-8"},
        tars = [
            "//cacerts:cacerts_java_amd64" + distro_suffix,
            "//locale:locale_amd64" + distro_suffix,
        ],
    )
    for mode in [
        "",
        "_debug",
    ]
    for user in USERS
    for distro_suffix in DISTRO_SUFFIXES
]

[
    container_image(
        name = rule_name + "_" + user + distro_suffix,
        base = ":java_base" + ("_debug" if ("debug" in rule_name) else "") + "_" + user + distro_suffix,
        debs = [DISTRO_PACKAGES["amd64"][distro_suffix][deb] for deb in java_debs],
        # We expect users to use:
        # cmd = ["/path/to/deploy.jar", "--option1", ...]
        entrypoint = [
            "/usr/bin/java",
            "-jar",
        ],
        env = {"JAVA_VERSION": jre_ver(DISTRO_VERSIONS[distro_suffix][java_debs[0]])},
        symlinks = {"/usr/bin/java": java_executable_path},
    )
    for (distro_suffix, rule_name, java_debs, java_executable_path) in [
        (
            "_debian10",
            "java11",
            ["openjdk-11-jre-headless"],
            "/usr/lib/jvm/java-11-openjdk-amd64/bin/java",
        ),
        (
            "_debian10",
            "java11_debug",
            [
                "openjdk-11-jre-headless",
                "openjdk-11-jdk-headless",
            ],
            "/usr/lib/jvm/java-11-openjdk-amd64/bin/java",
        ),
    ]
    for user in USERS
]

[
    container_image(
        name = rule_name + "_" + user + distro_suffix,
        base = ":java_base" + ("_debug" if ("debug" in rule_name) else "") + "_" + user + distro_suffix,
        debs = [DISTRO_PACKAGES["amd64"][distro_suffix][deb] for deb in java_debs],
        # We expect users to use:
        # cmd = ["/path/to/deploy.jar", "--option1", ...]
        entrypoint = [
            "/usr/bin/java",
            "-jar",
        ],
        env = {"JAVA_VERSION": "17"},
        symlinks = {"/usr/bin/java": java_executable_path},
        tars = [
            java_layer,
        ]
    )
    for (distro_suffix, rule_name, java_layer, java_debs, java_executable_path) in [
        (
            "_debian11",
            "java17",
            ":java17_jre_layer",
            [],
            "/usr/lib/jvm/bin/java",
        ),
        (
            "_debian11",
            "java17_debug",
            ":java17_jdk_layer",
            [],
            "/usr/lib/jvm/bin/java",
        ),
    ]
    for user in USERS
]

[
    container_test(
        name = "java_base" + mode + "_" + user + distro_suffix + "_test",
        configs = ["testdata/java_base" + mode + ".yaml"],
        image = ":java_base" + mode + "_" + user + distro_suffix,
        tags = [
            "amd64",
            "manual",
        ],
    )
    for mode in [
        "",
        "_debug",
    ]
    for user in USERS
    for distro_suffix in DISTRO_SUFFIXES
]

[
    container_test(
        name = java_version + "_" + user + distro_suffix + "_test",
        configs = ["testdata/" + java_version + distro_suffix + ".yaml"],
        image = ":" + java_version + "_" + user + distro_suffix,
        tags = [
            "amd64",
            "manual",
        ],
    )
    for user in USERS
    for java_version, distro_suffix in JAVA_DISTROS.items()
]

[
    container_test(
        name = java_version + "_debug_" + user + distro_suffix + "_test",
        configs = ["testdata/" + java_version + "_debug" + distro_suffix + ".yaml"],
        image = ":" + java_version + "_debug_" + user + distro_suffix,
        tags = [
            "amd64",
            "manual",
        ],
    )
    for user in USERS
    for java_version, distro_suffix in JAVA_DISTROS.items()
]

RULE_NAMES = [
    java_version + "_" + user + distro_suffix
    for user in USERS
    for java_version, distro_suffix in JAVA_DISTROS.items()
]

[
    java_image(
        name = "check_certs_" + rule_name,
        srcs = ["testdata/CheckCerts.java"],
        base = "//java:" + rule_name,
        main_class = "testdata.CheckCerts",
    )
    for rule_name in RULE_NAMES
]

[
    container_test(
        name = "check_certs_" + rule_name + "_test",
        configs = ["testdata/" + rule_name + "_certs.yaml"],
        image = ":check_certs_" + rule_name,
        tags = [
            "amd64",
            "manual",
        ],
    )
    for rule_name in RULE_NAMES
]

[
    java_image(
        name = "check_encoding_" + rule_name,
        srcs = ["testdata/CheckEncoding.java"],
        base = "//java:" + rule_name,
        main_class = "testdata.CheckEncoding",
    )
    for rule_name in RULE_NAMES
]

[
    container_test(
        name = "check_encoding_" + rule_name + "_test",
        configs = ["testdata/" + rule_name + "_encoding.yaml"],
        image = ":check_encoding_" + rule_name,
        tags = [
            "amd64",
            "manual",
        ],
    )
    for rule_name in RULE_NAMES
]

JAVA_IMAGES = {
    "{REGISTRY}/{PROJECT_ID}/distroless:java17-root": "//java:java17_root_debian11",
    "{REGISTRY}/{PROJECT_ID}/distroless:java17-nonroot": "//java:java17_nonroot_debian11",
    "{REGISTRY}/{PROJECT_ID}/distroless:java17-root-debug": "//java:java17_debug_root_debian11",
    "{REGISTRY}/{PROJECT_ID}/distroless:java17-nonroot-debug": "//java:java17_debug_nonroot_debian11",
}

load("@io_bazel_rules_docker//container:container.bzl", "container_bundle")

container_bundle(
    name = "java_image_bundle",
    images = JAVA_IMAGES,
)

load("@io_bazel_rules_docker//contrib:push-all.bzl", "container_push")

container_push(
    name = "publish",
    bundle = ":java_image_bundle",
    format = "Docker",
    # Push images sequentially, to avoid a bug in rules_docker related to
    # pushing many images in parallel.
    # https://github.com/bazelbuild/rules_docker/issues/525
    sequential = True,
)