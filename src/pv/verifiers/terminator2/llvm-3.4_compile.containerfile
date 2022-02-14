FROM ubuntu:20.04

RUN apt-get update && \
    DEBIAN_FRONTEND=noninteractive apt-get upgrade -y && \
    DEBIAN_FRONTEND=noninteractive apt-get install -y \
    build-essential cmake git ninja-build python libgmp-dev \
    clang gcc-multilib mono-complete mono-xbuild nuget \
    fsharp python3-psutil python3-ply


# build clang 3.6.2
RUN cd /opt && git clone --depth 1 --branch release/3.6.x https://github.com/llvm/llvm-project.git llvm-project-3.6 && \
    mkdir /opt/llvm-project-3.6/build && \
    ln -s /usr/include/locale.h /usr/include/xlocale.h && \
    ln -s /opt/llvm-project-3.6/clang /opt/llvm-project-3.6/llvm/tools && \
    ln -s /opt/llvm-project-3.6/lld /opt/llvm-project-3.6/llvm/tools && \
    ln -s /opt/llvm-project-3.6/libcxx /opt/llvm-project-3.6/llvm/projects && \
    ln -s /opt/llvm-project-3.6/libcxxabi /opt/llvm-project-3.6/llvm/projects && \
    ln -s /opt/llvm-project-3.6/clang-tools-extra/ /opt/llvm-project-3.6/clang/tools/extra && \
    sed -i 's/bool hasMD() const { return MDMap; }/bool hasMD() const { return static_cast<bool>(MDMap); }/g' \
             /opt/llvm-project-3.6/llvm/include/llvm/IR/ValueMap.h && \
    cd /opt/llvm-project-3.6/build && \
    cmake -DCMAKE_BUILD_TYPE=Release -DLLVM_DEFAULT_TARGET_TRIPLE=x86_64-pc-linux-gnu -G "Unix Makefiles" ../llvm && \
    make -j8 && make install && \
    ln -s /usr/lib/gcc/x86_64-linux-gnu/9/libgcc.a /usr/lib/x86_64-linux-gnu && \
    ln -s /usr/lib/gcc/x86_64-linux-gnu/9/libgcc_s.so /usr/lib/x86_64-linux-gnu && \
    ln -s /usr/lib/gcc/x86_64-linux-gnu/9/libgcc_eh.a /usr/lib/x86_64-linux-gnu && \
    ln -s /usr/lib/gcc/x86_64-linux-gnu/9/crtend.o /usr/lib/x86_64-linux-gnu && \
    ln -s /usr/lib/gcc/x86_64-linux-gnu/9/crtendS.o /usr/lib/x86_64-linux-gnu && \
    ln -s /usr/lib/gcc/x86_64-linux-gnu/9/crtbegin.o /usr/lib/x86_64-linux-gnu && \
    ln -s /usr/lib/gcc/x86_64-linux-gnu/9/crtbeginS.o /usr/lib/x86_64-linux-gnu && \
    ln -s /usr/lib/gcc/x86_64-linux-gnu/9/crtbeginT.o /usr/lib/x86_64-linux-gnu && \
    ln -s /usr/lib/gcc/x86_64-linux-gnu/9/libstdc++.a /usr/lib/x86_64-linux-gnu && \
    ln -s /usr/lib/gcc/x86_64-linux-gnu/9/libstdc++.so /usr/lib/x86_64-linux-gnu && \
    ldconfig && make clean


# clang++ doesn't work with gnu stdlib so we need to rewrite a mini bash script that uses libcxx from llvm project
RUN mv /usr/local/bin/clang++ /usr/local/bin/_clang++ && \
    echo "#!/bin/bash\n_clang++ -stdlib=libc++ \$@" > /usr/local/bin/clang++ && \
    chmod +x /usr/local/bin/clang++

COPY llvm-3.4_compile.sh compile.sh
RUN chmod +x compile.sh
ENTRYPOINT ["./compile.sh"]
CMD [""]
