<?php

// Time to sleep between checks
$sleeptime = 60;

// Command to run
$command = './build.sh';

$latestBuild = 0;
if (file_exists('latest')) {
	$latestBuild = file_get_contents('latest');
}

function logmessage($message) {
	echo "INFO: " . date('Y-m-d H:i:s') . ' ' . $message . PHP_EOL;
}

while(true) {
	$now = date('Ymd');

	logmessage('Checking if new daily build is required');

	if ($now > $latestBuild) {
		logmessage('Time for a new daily build!');

		exec($command, $output, $result);

		logmessage('Daily build done!');

		$latestBuild = $now;
		file_put_contents('latest', $now);
	} else {
		logmessage('No new build is required yet, time to sleep!');
	}

	sleep($sleeptime);
}


