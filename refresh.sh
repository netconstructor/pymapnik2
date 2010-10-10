#!/usr/bin/env bash


# Copyright (C) 2010, Mathieu PASQUET <mpa@makina-corpus.com>
# All rights reserved.
#
# Redistribution and use in source and binary forms, with or without
# modification, are permitted provided that the following conditions are met:
#
# 1. Redistributions of source code must retain the above copyright notice,
#    this list of conditions and the following disclaimer.
# 2. Redistributions in binary form must reproduce the above copyright
#    notice, this list of conditions and the following disclaimer in the
#    documentation and/or other materials provided with the distribution.
# 3. Neither the name of the <ORGANIZATION> nor the names of its
#    contributors may be used to endorse or promote products derived from
#    this software without specific prior written permission.
#
# THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS"
# AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE
# IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE
# ARE DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT OWNER OR CONTRIBUTORS BE
# LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR
# CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF
# SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS
# INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN
# CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE)
# ARISING IN ANY WAY OUT OF THE USE OF THIS SOFTWARE, EVEN IF ADVISED OF THE
# POSSIBILITY OF SUCH DAMAGE.




w="${1:-../../dependencies/mapnik-0.7/mapnik-0.7-r2271}"
frsync() {
    echo rsync $@
    rsync $@
}

# refresh code
frsync -a  $w/bindings/python/*pp cpp/
frsync -a --exclude=.svn ${w}/agg/include/ agg/include/
# refresh tests
frsync -a --exclude=.svn ${w}/tests/python_tests/ src/mapnik/tests/python_tests/
# refresg test resources
for i in $(grep -r "../data" src/mapnik/tests/python_tests/ \
    |sed -re "s:.*('|\")../data:../data:g" \
    |sed -re "s/(\"|').*//g"\
    |sort -u\
    |grep -v 'python_tests' \
    |sed -re "s/%s/*/g" \
    |grep -v "does_not_exi" \
    |grep -v "broken.png" \
    |grep -v ":" \
    );do
    dest=src/mapnik/tests/python_tests/$i
    ddest=$(dirname ${dest//*/aaaa})
    #echo "--> $i: $dest  / $ddest"
    if [[ ! -d $ddest ]];then
        mkdir -p $ddest || exit -1
    fi
    for j in ${w}/tests/python_tests/$i;do
        fdest=src/mapnik/$(echo $j|sed -re "s:(.*)(tests/python_tests/.*)/[^/]*:\2:g")
        if [[ ! -d $fdest ]];then
            mkdir -p $fdest
        fi
        frsync -a --exclude=.svn $j  $fdest/$(basename $j)
    done
done
# vim:set et sts=4 ts=4 tw=0: