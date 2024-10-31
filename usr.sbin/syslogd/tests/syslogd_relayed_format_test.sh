#-
# SPDX-License-Identifier: BSD-2-Clause
#
# Copyright (c) 2024 Michal Scigocki <michal.os@hotmail.com>
#

. $(atf_get_srcdir)/syslogd_format_test_common.sh

# Relayed messages tests
# [Host] ---UDP--> [Relay] ---UDP--> [Central]
setup_relayed_format_test()
{
    local format="$1"
    local logfile="$2"
    local pcapfile="$3"
    local server_port_1="${SYSLOGD_UDP_PORT_1}"
    local server_port_2="${SYSLOGD_UDP_PORT_2}"
    local server_port_3="${SYSLOGD_UDP_PORT_3}"

    confirm_INET_support_or_skip

    # Begin packet capture for single packet
    tcpdump --immediate-mode -c 1 -i lo0 -w "${pcapfile}" dst port \
        "${server_port_1}" &
    tcpdump_pid="$!"

    # Start first (central) server: receive UDP, log to file
    printf "user.debug\t${logfile}\n" > "$(config_filename ${server_port_1})"
    syslogd_start_on_port "${server_port_1}" -O "${format}"

    # Start second (relay) server: send UDP, log to central server
    printf "user.debug\t@127.0.0.1:${server_port_1}\n" \
        > "$(config_filename ${server_port_2})"
    syslogd_start_on_port "${server_port_2}" -O "${format}"

    # Start third logging host: send UDP, log to relay server
    printf "user.debug\t@127.0.0.1:${server_port_2}\n" \
        > "$(config_filename ${server_port_3})"
    syslogd_start_on_port "${server_port_3}" -O "${format}"

    # Send test syslog message
    syslogd_log -p user.debug -t "${TAG}" -h 127.0.0.1 \
        -P "${server_port_3}" -H "${HOSTNAME}" "${MSG}"

    wait "${tcpdump_pid}"  # Wait for packet capture to finish
}

atf_test_case "O_flag_bsd_relayed" "cleanup"
O_flag_bsd_relayed_head()
{
    atf_set descr "bsd log format test on a relayed syslog message"
    set_common_atf_metadata_with_progs "logger" "tcpdump"
}
O_flag_bsd_relayed_body()
{
    local format="bsd"
    local logfile="${PWD}/${format}_relayed_message.log"
    local pcapfile="${PWD}/${format}_message_forwarding.pcap"

    setup_relayed_format_test "${format}" "${logfile}" "${pcapfile}"

    atf_expect_fail "known issue with the legacy bsd/rfc3164 format"
    atf_check -s exit:0 -o match:"${REGEX_RFC3164_LOGFILE}" cat "${logfile}"
    atf_check -s exit:0 -e ignore -o match:"${REGEX_RFC3164_PAYLOAD}" \
        tcpdump -A -r "${pcapfile}"
}
O_flag_bsd_relayed_cleanup()
{
    syslogd_stop_on_ports \
        "${SYSLOGD_UDP_PORT_1}" \
        "${SYSLOGD_UDP_PORT_2}" \
        "${SYSLOGD_UDP_PORT_3}"
}

atf_test_case "O_flag_rfc3164_relayed" "cleanup"
O_flag_rfc3164_relayed_head()
{
    atf_set descr "rfc3164 log format test on a relayed syslog message"
    set_common_atf_metadata_with_progs "logger" "tcpdump"
}
O_flag_rfc3164_relayed_body()
{
    local format="rfc3164"
    local logfile="${PWD}/${format}_relayed_message.log"
    local pcapfile="${PWD}/${format}_message_forwarding.pcap"

    setup_relayed_format_test "${format}" "${logfile}" "${pcapfile}"

    atf_expect_fail "known issue with the legacy bsd/rfc3164 format"
    atf_check -s exit:0 -o match:"${REGEX_RFC3164_LOGFILE}" cat "${logfile}"
    atf_check -s exit:0 -e ignore -o match:"${REGEX_RFC3164_PAYLOAD}" \
        tcpdump -A -r "${pcapfile}"
}
O_flag_rfc3164_relayed_cleanup()
{
    syslogd_stop_on_ports \
        "${SYSLOGD_UDP_PORT_1}" \
        "${SYSLOGD_UDP_PORT_2}" \
        "${SYSLOGD_UDP_PORT_3}"
}

atf_test_case "O_flag_strict_relayed" "cleanup"
O_flag_strict_relayed_head()
{
    atf_set descr "strict log format test on a relayed syslog message"
    set_common_atf_metadata_with_progs "logger" "tcpdump"
}
O_flag_strict_relayed_body()
{
    local format="strict"
    local logfile="${PWD}/${format}_relayed_message.log"
    local pcapfile="${PWD}/${format}_message_forwarding.pcap"

    setup_relayed_format_test "${format}" "${logfile}" "${pcapfile}"

    atf_check -s exit:0 -o match:"${REGEX_RFC3164_LOGFILE}" cat "${logfile}"
    atf_check -s exit:0 -e ignore -o match:"${REGEX_RFC3164_PAYLOAD}" \
        tcpdump -A -r "${pcapfile}"
}
O_flag_strict_relayed_cleanup()
{
    syslogd_stop_on_ports \
        "${SYSLOGD_UDP_PORT_1}" \
        "${SYSLOGD_UDP_PORT_2}" \
        "${SYSLOGD_UDP_PORT_3}"
}

atf_test_case "O_flag_rfc3164strict_relayed" "cleanup"
O_flag_rfc3164strict_relayed_head()
{
    atf_set descr "rfc3164-strict log format test on a relayed syslog message"
    set_common_atf_metadata_with_progs "logger" "tcpdump"
}
O_flag_rfc3164strict_relayed_body()
{
    local format="rfc3164-strict"
    local logfile="${PWD}/${format}_relayed_message.log"
    local pcapfile="${PWD}/${format}_message_forwarding.pcap"

    setup_relayed_format_test "${format}" "${logfile}" "${pcapfile}"

    atf_check -s exit:0 -o match:"${REGEX_RFC3164_LOGFILE}" cat "${logfile}"
    atf_check -s exit:0 -e ignore -o match:"${REGEX_RFC3164_PAYLOAD}" \
        tcpdump -A -r "${pcapfile}"
}
O_flag_rfc3164strict_relayed_cleanup()
{
    syslogd_stop_on_ports \
        "${SYSLOGD_UDP_PORT_1}" \
        "${SYSLOGD_UDP_PORT_2}" \
        "${SYSLOGD_UDP_PORT_3}"
}

atf_test_case "O_flag_syslog_relayed" "cleanup"
O_flag_syslog_relayed_head()
{
    atf_set descr "syslog log format test on a relayed syslog message"
    set_common_atf_metadata_with_progs "logger" "tcpdump"
}
O_flag_syslog_relayed_body()
{
    local format="syslog"
    local logfile="${PWD}/${format}_relayed_message.log"
    local pcapfile="${PWD}/${format}_message_forwarding.pcap"

    setup_relayed_format_test "${format}" "${logfile}" "${pcapfile}"

    atf_check -s exit:0 -o match:"${REGEX_RFC5424_LOGFILE}" cat "${logfile}"
    atf_check -s exit:0 -e ignore -o match:"${REGEX_RFC5424_PAYLOAD}" \
        tcpdump -A -r "${pcapfile}"
}
O_flag_syslog_relayed_cleanup()
{
    syslogd_stop_on_ports \
        "${SYSLOGD_UDP_PORT_1}" \
        "${SYSLOGD_UDP_PORT_2}" \
        "${SYSLOGD_UDP_PORT_3}"
}

atf_test_case "O_flag_rfc5424_relayed" "cleanup"
O_flag_rfc5424_relayed_head()
{
    atf_set descr "rfc5424 log format test on a relayed syslog message"
    set_common_atf_metadata_with_progs "logger" "tcpdump"
}
O_flag_rfc5424_relayed_body()
{
    local format="rfc5424"
    local logfile="${PWD}/${format}_relayed_message.log"
    local pcapfile="${PWD}/${format}_message_forwarding.pcap"

    setup_relayed_format_test "${format}" "${logfile}" "${pcapfile}"

    atf_check -s exit:0 -o match:"${REGEX_RFC5424_LOGFILE}" cat "${logfile}"
    atf_check -s exit:0 -e ignore -o match:"${REGEX_RFC5424_PAYLOAD}" \
        tcpdump -A -r "${pcapfile}"
}
O_flag_rfc5424_relayed_cleanup()
{
    syslogd_stop_on_ports \
        "${SYSLOGD_UDP_PORT_1}" \
        "${SYSLOGD_UDP_PORT_2}" \
        "${SYSLOGD_UDP_PORT_3}"
}

atf_init_test_cases()
{
    atf_add_test_case "O_flag_bsd_relayed"
    atf_add_test_case "O_flag_rfc3164_relayed"
    atf_add_test_case "O_flag_strict_relayed"
    atf_add_test_case "O_flag_rfc3164strict_relayed"
    atf_add_test_case "O_flag_syslog_relayed"
    atf_add_test_case "O_flag_rfc5424_relayed"
}
