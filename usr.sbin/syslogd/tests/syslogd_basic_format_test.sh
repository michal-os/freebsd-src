#-
# SPDX-License-Identifier: BSD-2-Clause
#
# Copyright (c) 2024 Michal Scigocki <michal.os@hotmail.com>
#

. $(atf_get_srcdir)/syslogd_format_test_common.sh

# Basic format tests
# Single server, logging to local socket
setup_basic_format_test()
{
    local format="$1"
    local logfile="$2"
    local server_port="${SYSLOGD_UDP_PORT_1}"

    printf "user.debug\t${logfile}\n" > "$(config_filename ${server_port})"
    syslogd_start_on_port "${server_port}" -O "${format}" -N -s

    syslogd_log -p user.debug -t "${TAG}" \
        -h "$(local_socket_filename ${server_port})" \
        -H "${HOSTNAME}" "${MSG}"
}

atf_test_case "O_flag_bsd_basic" "cleanup"
O_flag_bsd_basic_head()
{
    atf_set descr "bsd log format test on local syslog message"
    set_common_atf_metadata_with_progs "logger"
}
O_flag_bsd_basic_body()
{
    local format="bsd"
    local logfile="${PWD}/O_flag_${format}.log"

    setup_basic_format_test "${format}" "${logfile}"

    atf_check -s exit:0 -o match:"${REGEX_RFC3164_LOGFILE}" cat "${logfile}"
}
O_flag_bsd_basic_cleanup()
{
    syslogd_stop_on_port "${SYSLOGD_UDP_PORT_1}"
}

atf_test_case "O_flag_rfc3164_basic" "cleanup"
O_flag_rfc3164_basic_head()
{
    atf_set descr "rfc3164 log format test on local syslog message"
    set_common_atf_metadata_with_progs "logger"
}
O_flag_rfc3164_basic_body()
{
    local format="rfc3164"
    local logfile="${PWD}/O_flag_${format}.log"

    setup_basic_format_test "${format}" "${logfile}"

    atf_check -s exit:0 -o match:"${REGEX_RFC3164_LOGFILE}" cat "${logfile}"
}
O_flag_rfc3164_basic_cleanup()
{
    syslogd_stop_on_port "${SYSLOGD_UDP_PORT_1}"
}

atf_test_case "O_flag_strict_basic" "cleanup"
O_flag_strict_basic_head()
{
    atf_set descr "strict log format test on local syslog message"
    set_common_atf_metadata_with_progs "logger"
}
O_flag_strict_basic_body()
{
    local format="strict"
    local logfile="${PWD}/O_flag_${format}.log"

    setup_basic_format_test "${format}" "${logfile}"

    atf_check -s exit:0 -o match:"${REGEX_RFC3164_LOGFILE}" cat "${logfile}"
}
O_flag_strict_basic_cleanup()
{
    syslogd_stop_on_port "${SYSLOGD_UDP_PORT_1}"
}

atf_test_case "O_flag_rfc3164strict_basic" "cleanup"
O_flag_rfc3164strict_basic_head()
{
    atf_set descr "rfc3164-strict log format test on local syslog message"
    set_common_atf_metadata_with_progs "logger"
}
O_flag_rfc3164strict_basic_body()
{
    local format="rfc3164-strict"
    local logfile="${PWD}/O_flag_${format}.log"

    setup_basic_format_test "${format}" "${logfile}"

    atf_check -s exit:0 -o match:"${REGEX_RFC3164_LOGFILE}" cat "${logfile}"
}
O_flag_rfc3164strict_basic_cleanup()
{
    syslogd_stop_on_port "${SYSLOGD_UDP_PORT_1}"
}

atf_test_case "O_flag_syslog_basic" "cleanup"
O_flag_syslog_basic_head()
{
    atf_set descr "syslog log format test on local syslog message"
    set_common_atf_metadata_with_progs "logger"
}
O_flag_syslog_basic_body()
{
    local format="syslog"
    local logfile="${PWD}/O_flag_${format}.log"

    setup_basic_format_test "${format}" "${logfile}"

    atf_check -s exit:0 -o match:"${REGEX_RFC5424_LOGFILE}" cat "${logfile}"
}
O_flag_syslog_basic_cleanup()
{
    syslogd_stop_on_port "${SYSLOGD_UDP_PORT_1}"
}

atf_test_case "O_flag_rfc5424_basic" "cleanup"
O_flag_rfc5424_basic_head()
{
    atf_set descr "rfc5424 log format test on local syslog message"
    set_common_atf_metadata_with_progs "logger"
}
O_flag_rfc5424_basic_body()
{
    local format="rfc5424"
    local logfile="${PWD}/O_flag_${format}.log"

    setup_basic_format_test "${format}" "${logfile}"

    atf_check -s exit:0 -o match:"${REGEX_RFC5424_LOGFILE}" cat "${logfile}"
}
O_flag_rfc5424_basic_cleanup()
{
    syslogd_stop_on_port "${SYSLOGD_UDP_PORT_1}"
}

atf_init_test_cases()
{
    atf_add_test_case "O_flag_bsd_basic"
    atf_add_test_case "O_flag_rfc3164_basic"
    atf_add_test_case "O_flag_strict_basic"
    atf_add_test_case "O_flag_rfc3164strict_basic"
    atf_add_test_case "O_flag_syslog_basic"
    atf_add_test_case "O_flag_rfc5424_basic"
}
