#
# Regular cron jobs for the fsvalue package
#
0 4	* * *	root	[ -x /usr/bin/fsvalue_maintenance ] && /usr/bin/fsvalue_maintenance
