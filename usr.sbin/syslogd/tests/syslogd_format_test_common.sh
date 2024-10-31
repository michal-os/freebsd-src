#-
# SPDX-License-Identifier: BSD-2-Clause
#
# Copyright (c) 2024 Michal Scigocki <michal.os@hotmail.com>
#

. $(atf_get_srcdir)/syslogd_test_common.sh

readonly SYSLOGD_UDP_PORT_1="5140"
readonly SYSLOGD_UDP_PORT_2="5141"
readonly SYSLOGD_UDP_PORT_3="5142"

# REGEX Components
readonly PRI="<15>"
readonly VERSION="1"
readonly DATE_RFC3164="[A-Z][a-z]{2} [ 1-3][0-9]"
readonly TIMESPEC_RFC5424="[:TZ0-9\.\+\-]{20,32}|\-" # Simplified TIMESPEC
readonly TIME_RFC3164="([0-9]{2}:){2}[0-9]{2}"
readonly HOSTNAME="example.test"
readonly TAG="test_tag"
readonly MSG="test_log_message"

# Test REGEX
readonly REGEX_RFC3164="${DATE_RFC3164} ${TIME_RFC3164} ${HOSTNAME} ${TAG}: ${MSG}"
readonly REGEX_RFC3164_LOGFILE="^${REGEX_RFC3164}$"
readonly REGEX_RFC3164_PAYLOAD="${PRI}${REGEX_RFC3164}$"

readonly REGEX_RFC3164_LEGACY="${DATE_RFC3164} ${TIME_RFC3164} Forwarded from ${HOSTNAME}: ${TAG}: ${MSG}"
readonly REGEX_RFC3164_LEGACY_LOGFILE="^${REGEX_RFC3164_LEGACY}$"
readonly REGEX_RFC3164_LEGACY_PAYLOAD="${PRI}${REGEX_RFC3164_LEGACY}$"

readonly REGEX_RFC5424="${PRI}${VERSION} ${TIMESPEC_RFC5424} ${HOSTNAME} ${TAG} - - - ${MSG}"
readonly REGEX_RFC5424_LOGFILE="^${REGEX_RFC5424}$"
readonly REGEX_RFC5424_PAYLOAD="${REGEX_RFC5424}$"

# Filename helper functions
config_filename()
{ local port="$1"; echo "${PWD}/syslog_${port}.conf"; }

local_socket_filename()
{ local port="$1"; echo "${PWD}/log_${port}.sock"; }

pid_filename()
{ local port="$1"; echo "${PWD}/syslogd_${port}.pid"; }

local_privsocket_filename()
{ local port="$1"; echo "${PWD}/logpriv_${port}.sock"; }

confirm_INET_support_or_skip()
{
    if ! sysctl kern.conftxt | grep -qw INET ; then
        atf_skip "Running kernel does not support INET"
    fi
}

set_common_atf_metadata_with_progs()
{
    atf_set require.user root
    atf_set timeout 5
    if [ "$#" != "0" ]; then
        atf_set require.progs "$@"
    fi
}

# Start a private syslogd instance on specified port.
syslogd_start_on_port()
{
    local port="$1"
    shift 1

    syslogd \
        -b ":${port}" \
        -C \
        -d \
        -f "$(config_filename ${port})" \
        -H \
        -p "$(local_socket_filename ${port})" \
        -P "$(pid_filename ${port})" \
        -S "$(local_privsocket_filename ${port})" \
        $@ \
        &

    # Give syslogd a bit of time to spin up.
    wait_for_syslogd_socket_or_fail "$(local_socket_filename ${port})"
}

# Stop a private syslogd instance on specified port.
syslogd_stop_on_port()
{
    local port="$1"

    pid=$(cat "$(pid_filename ${port})")
    if pkill -F "$(pid_filename ${port})"; then
        wait "${pid}"
        rm -f "$(pid_filename ${port})" \
            "$(local_socket_filename ${port})" \
            "$(local_privsocket_filename ${port})"
    fi
}

syslogd_stop_on_ports()
{
    local ports="$@"

    for port in "${ports}"; do
        syslogd_stop_on_port "${port}"
    done
}
