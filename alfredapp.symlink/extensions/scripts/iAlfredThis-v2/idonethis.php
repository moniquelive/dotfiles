<?php
$argumentCount = count($argv);

$sender = $argv[1];
$headers = 'From: ' . $sender . "\r\n";

if($argumentCount > 3) {
  $to = str_replace(' ', '-', strtolower($argv[2])). '@team.idonethis.com';
  $subjectIdentifier = $argv[2];
  $message = $argv[3];
} else {
  $to = 'today@idonethis.com';
  $subjectIdentifier = 'Personal';
  $message = $argv[2];
}

$subject = 'Re: '. $subjectIdentifier . ' digest for ' . date("F d");

mail($to, $subject, $message, $headers);
