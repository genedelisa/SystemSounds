
# Logging

Logging via os.log


## Basic


### Set log level 

```
sudo log config --mode "level:debug" --subsystem com.rockhoppertech.SystemSounds
```

### Check log level
```
sudo log config --status --subsystem com.rockhoppertech.SystemSounds
```


### Check log level of a category
```
sudo log config --status --subsystem com.rockhoppertech.SystemSounds --category Audio
```

## Streaming

Log all processes at the default level.
--source means show source file and line-number.
```
log stream --level default --source 
```

Restrict to one process.
```
log stream --source --process SystemSounds
```

## Predicates

Checking a value.
```
--predicate 'subsystem == "com.rockhoppertech.SystemSounds"
```

Multiple checks.
```
--predicate '(subsystem == "com.rockhoppertech.SystemSounds") && (category == "Audio")'   
```

Default level. Uses a predicate to show just messages containing a specified string.
```
log stream --level default --source --predicate 'eventMessage contains "play"'   
```

## Show

log show --predicate '(subsystem == "com.rockhoppertech.SystemSounds") && (category == "Audio")'
log show --info --debug --predicate '(subsystem == "com.rockhoppertech.SystemSounds") && (category == "Audio")'   

log show  --predicate 'subsystem == "com.rockhoppertech.SystemSounds" --info --debug --style json

log show --predicate '(subsystem == "com.rockhoppertech.SystemSounds") && (category == "testlog")'

log config -- mode level:debug and then -system com.mycorp.myapp and

log stream --predicate '(subsystem == "com.rockhoppertech.SystemSounds") && (category == "testlog")' --debug --info

log stream --predicate 'subsystem = "com.apple.network"' --info --debug
log show --predicate 'subsystem = "com.apple.network"' --info --debug --last 5m --color always --style syslog

log show --predicate 'subsystem = "com.apple.network"' --info --debug --last 1m --color always --style json

### CloudKit

CloudKit logs to see operations on the cloudd process for your container.
```
$ log stream --info --debug --predicate 'process = "cloudd" and message
contains[cd] "containerID=iCloud.com.rockhoppertech.Plantz"'
```
Core Data logs to see information about the mirroring delegate’s setup, exports, and imports for your process.
```
$ log stream --info --debug --predicate 'process = "Plantz" and 
(subsystem = "com.apple.coredata" or subsystem = "com.apple.cloudkit")'
```

log stream --info --debug --predicate ' 
(subsystem = "com.apple.coredata" or subsystem = "com.apple.cloudkit")'


monitor both CloudKit and Core Data logs at the same time.
```
$ log stream --info --debug --predicate '(process = "myprocess" and
(subsystem = "com.apple.coredata" or subsystem = "com.apple.cloudkit")) or
(process = "cloudd" and message contains[cd] "container=iCloud.com.rockhoppertech.Plantz")'
```

## Links

[OSLogging-homepage-url]:https://developer.apple.com/documentation/os/logging

[WWDC-2016-url]:https://developer.apple.com/videos/play/wwdc2016/721/



