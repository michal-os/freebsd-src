PACKAGE=	tests

ATF_TESTS_SH=	syslogd_basic_format_test \
		syslogd_forwarded_format_test \
		syslogd_relayed_format_test \
		syslogd_test

# Several syslogd listening on the same port prevent parallel operation
TEST_METADATA+=	is_exclusive="true"

${PACKAGE}FILES=syslogd_format_test_common.sh \
		syslogd_test_common.sh

.include <bsd.test.mk>
