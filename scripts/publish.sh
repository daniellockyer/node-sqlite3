function publish() {
    if [[ ${PUBLISHABLE:-false} == true ]] && [[ ${COMMIT_MESSAGE} =~ "[publish binary]" ]]; then
        CFLAGS="${CFLAGS:-} -include $(pwd)/src/gcc-preinclude.h" CXXFLAGS="${CXXFLAGS:-} -include $(pwd)/src/gcc-preinclude.h" node-pre-gyp rebuild  --clang=1
        node-pre-gyp package testpackage
        node-pre-gyp-github publish
        make clean
    fi
}
