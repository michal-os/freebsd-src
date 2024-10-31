#-
# SPDX-License-Identifier: BSD-2-Clause
#
# Copyright (c) 2021, 2023 The FreeBSD Foundation
#
# This software was developed by Mark Johnston under sponsorship from
# the FreeBSD Foundation.
#
# This software was developed by Jake Freeland under sponsorship from
# the FreeBSD Foundation.
#

# Simple logger(1) wrapper.
syslogd_log()
{
    atf_check -s exit:0 -o empty -e empty logger $*
}

wait_for_syslogd_socket_or_fail()
{
    local socket_filename="$1"

    while [ "$((i+=1))" -le 20 ]; do
        [ -S "${socket_filename}" ] && return
        sleep 0.1
    done
    atf_fail "timed out waiting for syslogd to start"
}
