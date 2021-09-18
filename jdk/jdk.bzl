def _jdk_repository_impl(ctx):
    ctx.report_progress("Downloading JDKs")

    files = []
    for url in ctx.attr.urls:
        # https://download.java.net/java/GA/jdk17/0d483333a00540d886896bac774ff48b/35/GPL/openjdk-17_linux-x64_bin.tar.gz
        # https://cdn.azul.com/zulu/bin/zulu17.28.13-ca-jre17.0.0-linux_x64.tar.gz
        
        file_name = url[url.rfind("/")+1:]
        folder_name = file_name.replace(".tar.gz", "")

        ctx.report_progress("Downloading JDK: {}".format(file_name))

        result = ctx.download(
            url=url,
            output=file_name,
        )

        ctx.report_progress("Repackaging JDK: {}".format(file_name))

        # Extract data from the original file
        result = ctx.extract(file_name)
        # Remove the original file
        result = ctx.execute(["rm",  "-f", file_name])
        # Package data into the root of a new archive
        result = ctx.execute(["tar", "-czf", file_name, "-C", "./" + folder_name + "/", "."])
        # Remove original folder
        result = ctx.execute(["rm", "-rf", folder_name])
        
        files.append('"{}"'.format(file_name))

    ctx.file("BUILD.bazel", 'exports_files([{}])'.format(",".join(files)))

_jdk_repository = repository_rule(
    implementation = _jdk_repository_impl,
    attrs = {
        "urls": attr.string_list(
            mandatory=True,
            allow_empty=False,
        ),
    }
)

def jdk_repository(**kwargs):
    return _jdk_repository(
        name="jdks",
        **kwargs,
    )