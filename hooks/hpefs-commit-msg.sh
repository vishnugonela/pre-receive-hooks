#!/usr/bin/env ruby
message_file = ARGV[0]
message = File.read(message_file)

$regex = /HPEFS-(\d+)/

if !$regex.match(message)
  puts "[POLICY] Your commit message is not formatted correctly, Please make sure your commit message starts with JIRA issue # for example HPEFS-XXXX."
  exit 1
end
