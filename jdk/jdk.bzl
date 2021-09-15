def _jdk_repository_impl(ctx):
    ctx.report_progress("Downloading JDKs")

    files = []
    for url in ctx.attr.urls:
        # https://download.java.net/java/GA/jdk17/0d483333a00540d886896bac774ff48b/35/GPL/openjdk-17_linux-x64_bin.tar.gz
        file_name = url[url.rfind("/")+1:]

        ctx.report_progress("Downloading JDK: {}".format(file_name))

        result = ctx.download(
            url=url,
            output=file_name,
        )
        
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